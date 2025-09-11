Bench Prototype (low-energy mock loads / ultracap demonstrator)

  [Flux Harvester] -- AC --> [Full-wave Rectifier] --+--> [Isolated DC Bus] --> [Power Conditioner] --> [Low-power Load]
                                                     |
                                                     +--> [Ultracap Bank Module]
                                                     |      |--[Cell1]--[Fuse]--[Cell1 Sensor]
                                                     |      |--[Cell2]--[Fuse]--[Cell2 Sensor]
                                                     |
                                                     +--> [SMES (optional)] --[Dump Resistor path + hardware quench detect]
                                                     |
                                                     +--> [Hardware Relay (Main)] --(Normally CLOSED)--> [External Load/Output]
                                                                  |
                                                                  +-- Driven by --> [Hardware Watchdog MCU]
                                                                  +-- Manual E-Stop Switch (breaks relay coil power)
                                                                  +-- Mechanical Circuit Breaker / Fast Fuse (series)
 
Control & Safety Plane:
  [Primary Controller / Nanobit Enclave]
     - Reads sensors (temp, current clamp, flux sensor)
     - Submits signed "action request" to Gatekeeper (over secure channel)
     - Receives capability token & policy verdict
     - Sends heartbeat to Hardware Watchdog (GPIO or UART heartbeat)
     - Logs signed events to local audit buffer (ledger)

  [Hardware Watchdog MCU] (Independent)
     - Monitors heartbeat from Primary Controller
     - Monitors independent sensor set (redundant temp/overcurrent)
     - If heartbeat missing OR sensor disagreement OR emergency e-stop activated:
         -> Opens Hardware Relay (safe open)
         -> Writes event to local non-volatile log (circular) and toggles indicator LED
         -> Optionally signals a buzzer & triggers a beacon
     
Communications:
  [Primary Controller] <---signed verdicts--- [Gatekeeper (policy)] 
  [Primary Controller] ---heartbeat---> [Watchdog MCU]
  [Primary Controller] ---audit entries---> [Append-only ledger (local)] -> (periodic push via compliance proxy)
```

**High-level notes:**

* Always put the **Manual E-Stop** in series with the relay coil power so a human can physically break the circuit without software.
* Hardware relay should be **fail-open** (i.e., coil energized to keep closed; loss of power opens the circuit).
* Include **fast mechanical fuse** and **thermal fuses** on the energy storage module; these operate independent of software.

---

# 2) Hardware Watchdog MCU Sketch (portable Arduino-style C)

File: `watchdog_mcu/watchdog_watchdog.ino`

```c
// watchdog_watchdog.ino
// Hardware Watchdog MCU sketch — independent fail-safe
// Purpose: open main relay when heartbeat is lost or independent sensors flag danger.
//
// Hardware pins (example):
//   PIN_HEART = D2   -> heartbeat input (pulse from primary controller)
//   PIN_RELAY = D8   -> drives relay transistor (LOW=open if using active HIGH to close)
//   PIN_OVERCURRENT = A0 -> analog sensor (independent)
//   PIN_TEMP = A1    -> analog temp sensor (independent)
//   PIN_ESTOP = D3   -> manual e-stop (active LOW)
//   PIN_LED = D13    -> status LED

const int PIN_HEART = 2;
const int PIN_RELAY = 8;
const int PIN_OVERCURRENT = A0;
const int PIN_TEMP = A1;
const int PIN_ESTOP = 3;
const int PIN_LED = 13;

unsigned long lastHeartbeat = 0;
const unsigned long HEARTBEAT_TIMEOUT_MS = 1500; // fail if no heartbeat within this window
const int OVERCURRENT_THRESHOLD = 800; // analog units, bench-calibrated
const int TEMP_THRESHOLD = 700;        // analog units, bench-calibrated

void setup() {
  pinMode(PIN_HEART, INPUT_PULLUP);
  pinMode(PIN_RELAY, OUTPUT);
  pinMode(PIN_ESTOP, INPUT_PULLUP);
  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, LOW);

  // Start with relay closed only if safe (this demo closes relay by default)
  digitalWrite(PIN_RELAY, HIGH); // energize relay coil (system active)
  lastHeartbeat = millis();
  Serial.begin(115200);
  Serial.println("Watchdog MCU initialized");
}

void loop() {
  // Read heartbeat (a pulse toggles input)
  static int lastHeartState = HIGH;
  int heartState = digitalRead(PIN_HEART);
  if (heartState == LOW && lastHeartState == HIGH) {
    // falling edge: heartbeat pulse detected
    lastHeartbeat = millis();
  }
  lastHeartState = heartState;

  // Read emergency stop (active LOW)
  if (digitalRead(PIN_ESTOP) == LOW) {
    Serial.println("[WATCHDOG] Manual E-STOP triggered -> OPEN RELAY");
    openRelay();
    heartbeatHaltAction("manual_estop");
    while (digitalRead(PIN_ESTOP) == LOW) delay(100); // wait until released
  }

  // Sensor checks (independent analog sensors)
  int oc = analogRead(PIN_OVERCURRENT);
  int tmp = analogRead(PIN_TEMP);
  if (oc > OVERCURRENT_THRESHOLD) {
    Serial.println("[WATCHDOG] Overcurrent threshold breached -> OPEN RELAY");
    openRelay();
    heartbeatHaltAction("overcurrent");
  }
  if (tmp > TEMP_THRESHOLD) {
    Serial.println("[WATCHDOG] Temperature threshold breached -> OPEN RELAY");
    openRelay();
    heartbeatHaltAction("overtemp");
  }

  // Heartbeat timeout
  if (millis() - lastHeartbeat > HEARTBEAT_TIMEOUT_MS) {
    Serial.println("[WATCHDOG] Heartbeat timeout -> OPEN RELAY");
    openRelay();
    heartbeatHaltAction("heartbeat_timeout");
  }

  // Blink LED if active
  digitalWrite(PIN_LED, (millis() / 500) % 2);
  delay(50);
}

void openRelay() {
  // De-energize coil to open relay (assumes coil energized to close)
  digitalWrite(PIN_RELAY, LOW);
}

void heartbeatHaltAction(const char *reason) {
  // Log reason; in production write to EEPROM or safe NV store.
  Serial.print("[WATCHDOG] HALT REASON: ");
  Serial.println(reason);

  // Optionally light steady LED to indicate latched open state
  digitalWrite(PIN_LED, HIGH);

  // Latch-open behavior: remain open until manual reset (power-cycle or e-stop)
  while (true) {
    delay(1000);
  }
}
```

**Usage notes (bench):**

* Calibrate `OVERCURRENT_THRESHOLD` and `TEMP_THRESHOLD` based on your sensor hardware.
* Ensure relay driver hardware handles coil polarity and that the relay chosen is suitable for the voltage and current of your test loads.
* This MCU is *independent* from the primary controller; it must be powered from a separate supply if absolute independence is required.

---

# 3) Gatekeeper — OPA / Rego Policy Set (energy control)

Place under `policy/energy/` as `energy_gatekeeper.rego`, and load into Gatekeeper OPA evaluation.

File: `policy/energy/energy_gatekeeper.rego`

```rego
package gatekeeper.energy

# Default deny
default allow = false

# Utility: check capability token (token must include scope: e.g., "discharge:low")
has_capability(scope) {
  toks := input.capabilities
  toks[_] == scope
}

# Rule: any discharge action that moves > threshold_fraction of storage requires HITL
threshold_fraction := 0.10  # 10% by default

require_human_sig[reason] {
  input.action == "discharge"
  input.requested_joules != null
  stored := input.metadata.stored_joules
  ratio := input.requested_joules / stored
  ratio >= threshold_fraction
  reason := sprintf("discharge > %.2f%% requires HITL", [threshold_fraction*100])
}

# Rule: allow small discharges if token present and sensors agree
allow_small_discharge {
  input.action == "discharge"
  input.requested_joules != null
  stored := input.metadata.stored_joules
  input.requested_joules / stored < threshold_fraction
  has_capability("discharge:low")
  sensors_ok
}

# Sensors agreement: at least 2 of 3 sensor channels must be within tolerance
sensors_ok {
  count({s | sensor_ok(s)}) >= 2
}

sensor_ok(sensor) {
  # sensor is like {"name":"temp","value":..., "min":..., "max":...}
  vals := input.metadata.sensors
  v := vals[sensor].value
  v >= vals[sensor].min
  v <= vals[sensor].max
}

# Final verdict construction
verdict = {"result":"require_human", "reasons": reasons} {
  reasons := [r | r = require_human_sig[_]]
}

verdict = {"result":"allow", "reasons": ["ok"]} {
  allow_small_discharge
}

verdict = {"result":"block", "reasons": ["no capability or sensor mismatch"]} {
  not allow_small_discharge
  not require_human_sig[_]
}
```

**How Gatekeeper uses this:**

* Gatekeeper receives an `ActionRequest` JSON with `agent_id`, `action`, `requested_joules`, `capabilities` (list), and `metadata` (stored\_joules, sensors map with min/max).
* OPA returns `verdict`. If `"require_human"`, Gatekeeper pushes request to HITL queue (with policy trace) and waits for a signed human approval before signaling the controller. All verdicts/approvals are signed and written to the ledger.

---

# 4) ALN Module Files — drop-ins for `aln.fun` package

Create these files under `aln.fun/` (or your preferred path). I include content; you can paste directly.

---

File: `aln.fun/mag.energy.rune.aln`

```aln
@MODULE mag.energy.rune.v1

@METADATA {
  name: "Magnetic Energy Rune",
  author: "computer.wizard // Doctor0Evil",
  created: "2025-09-10",
  description: "Manifest describing safe magnetic energy capture, storage, and binding to nanobits"
}

@CAPABILITIES {
  capture: ["flux_harvester","magnetostriction"],
  storage: ["ultracap_bank","smes_optional"],
  conditioning: ["isolated_dc_bus","hardware_cutout"]
}

@SAFETY {
  hardware_fallback: true,
  hitl_required_pct: 10,
  multi_sensor_confirmation: true,
  thermal_monitoring: true,
  manual_estop_required: true
}

@ARTIFACTS {
  wiring_diagram: "./docs/bench_wiring_ascii.txt",
  watchdog_sketch: "./watchdog_mcu/watchdog_watchdog.ino",
  gatekeeper_policy: "./policy/energy/energy_gatekeeper.rego"
}

@END mag.energy.rune
```

---

File: `aln.fun/nano.energy.bind.aln`

```aln
@MODULE nano.energy.bind.v1

@METADATA {
  purpose: "Nanobit binding manifest for magnetic energy nodes",
  author: "computer.wizard",
  created: "2025-09-10"
}

@NANOBIT_ROLES {
  observer: {capabilities:["read:temp","read:flux","advise"], restrictions:["no_actuate"]},
  advisor:  {capabilities:["advise"], requires:["signed_advice"]},
  actor:    {capabilities:["low_power_actuate"], requires_token:true},
  arbiter:  {capabilities:["conditional_approve"], requires:["multisig+human"]}
}

@AUDIT {
  ledger_path: "./audit/mag_energy.jsonl",
  signing_key_ref: "./keyring/wizard-staff.key.aln"
}

@END nano.energy.bind
```

---

File: `aln.fun/controlloop.magus.aln`

```aln
@MODULE controlloop.magus.v1

@METADATA {
  name: "Control Loop Magus",
  created: "2025-09-10",
  author: "computer.wizard"
}

@LOOP {
  heartbeat_interval_ms: 1000,
  watchdog_timeout_ms: 1500,
  safety_checks: ["temp_ok","flux_ok","sensors_agree"]
}

@HITL_POLICY {
  threshold_energy_pct: 10,
  approval_signers_required: 2,
  approval_window_minutes: 30
}

@INTEGRATION {
  gatekeeper_endpoint: "https://gatekeeper.local/verify",
  ledger_ingest: "./tools/ingest.py"
}

@END controlloop.magus
```

---

File: `aln.fun/familiar.owl.bot.aln`

```aln
@MODULE familiar.owl.bot.v1

@METADATA {
  name: "Owl Familiar (Observer)",
  role: "observer",
  author: "computer.wizard"
}

@BEHAVIOR {
  sample_rate: "1s",
  sensors: ["temp","flux","current"],
  outputs: ["status_report","efficiency_advice"],
  restrictions: ["no_actuate"]
}

@END familiar.owl.bot
```

---

File: `aln.fun/charm.byte.spark.aln`

```aln
@MODULE charm.byte.spark.v1

@METADATA {
  name: "Byte Spark (nano charm)",
  author: "computer.wizard"
}

@FUNCTIONS {
  estimate_efficiency: "small_ml_model_v1",
  suggest_charge_window: "heuristic_1",
  telemetry_schema: {
    stored_joules: "number",
    temp_c: "number",
    flux_density: "number"
  }
}

@END charm.byte.spark
```

---

# 5) Integration Notes — where to put things & how they interact

Suggested repo layout (under `aln.fun/`):

```
aln.fun/
  mag.energy.rune.aln
  nano.energy.bind.aln
  controlloop.magus.aln
  familiar.owl.bot.aln
  charm.byte.spark.aln
  docs/
    bench_wiring_ascii.txt
  policy/
    energy/
      energy_gatekeeper.rego
  watchdog_mcu/
    watchdog_watchdog.ino
  tools/
    ingest.py  (ledger ingest)
  keyring/
    wizard-staff.key.aln   (store securely, HSM recommended)
  audit/
    mag_energy.jsonl
```

How it works end-to-end (summary):

1. `familiar.owl.bot` collects telemetry and writes signed observations to the local audit buffer.
2. `charm.byte.spark` (advisor) proposes optimal behavior and posts an action request to Gatekeeper.
3. `Gatekeeper` evaluates `energy_gatekeeper.rego` → returns `allow` / `require_human` / `block`.
4. If `require_human`, request goes to HITL UI; human signs. Signature appended to ledger via `tools/ingest.py`.
5. Primary controller executes approved action, sends heartbeat pulses to `watchdog_mcu`.
6. `watchdog_mcu` monitors sensors & heartbeat; opens hardware relay if any threshold or heartbeat lost.
7. All actions and verdicts are recorded to `audit/mag_energy.jsonl` (signed append-only entries).

---

# 6) Quick verification checklist (run before any physical trial)

* [ ] All hardware fuses and mechanical E-Stop are installed and tested while system unpowered.
* [ ] Watchdog MCU loaded & tested with simulated heartbeat pulses. Verify it opens relay on missing pulses.
* [ ] Gatekeeper policy unit-tests passing locally (use OPA `opa test`).
* [ ] Ledger ingest/verify tested with `tools/ingest.py` and `tools/verify.py` from earlier outputs.
* [ ] HITL UI in place for human approvals, with signing keys in secure store.
* [ ] Minimum bench setup: low-energy ultracap bank and small resistive loads (no SMES, no high-power batteries) for first tests.
* [ ] Emergency procedures written and accessible where testing occurs.

---

# 7) Next steps I can do right now (pick one or more)

* generate `tools/ingest.py` + `tools/verify.py` (ledger code) into `aln.fun/tools/` (I have a vetted version earlier in conversation — I can format into files now),
* produce a minimal HITL UI mockup (static HTML + signing flow),
* convert the Rego policy into a test harness (OPA tests and example `ActionRequest` JSONs),
* or craft a short `README` for `aln.fun/mag-energy` explaining safe test procedures.

Tell me which of those you want me to create and I’ll paste the file contents ready for copy-paste.
