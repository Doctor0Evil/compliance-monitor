const M = "npclhjbddhklpbnacpjloidibaggcgon";
function x(...n) {
}
function S(n) {
  return chrome.runtime.sendMessage(M, n);
}
const w = "pplx-agent-0_0-overlay", _ = "pplx-agent-0_0-overlay-base", A = "pplx-agent-0_0-overlay-stop-button";
async function k(n, e, t = !1) {
  if (document.getElementById(w)) return;
  const s = (u, m) => {
    Object.assign(u.style, m);
  }, i = document.createElement("div");
  i.id = w;
  const p = e || "teal";
  i.dataset.theme = p;
  const a = document.createElement("div");
  a.id = _, a.dataset.theme = p, s(i, {
    position: "fixed",
    inset: "-1.25em",
    border: "solid",
    borderWidth: "2.5em",
    borderColor: "initial",
    borderImage: "var(--pplx-overlay-gradient)",
    filter: "blur(24px)",
    zIndex: "2147483645",
    pointerEvents: "auto",
    opacity: "0",
    transition: "opacity 1000ms cubic-bezier(0.4, 0, 0.2, 1)",
    willChange: "opacity, transform",
    cursor: "progress"
  }), s(a, {
    position: "fixed",
    inset: "0",
    zIndex: "2147483646",
    padding: "24px",
    opacity: "0.4",
    boxShadow: "var(--base-shadow)"
  });
  const r = document.createElement("style");
  r.textContent = `
        @property --a {
          syntax: '<angle>';
          initial-value: 0deg;
          inherits: false;
        }
        @keyframes a {
          to { --a: 1turn }
        }
      `;
  const l = document.createElement("div");
  l.className = "indicator";
  const v = document.createElement("div");
  v.className = "indicator-play";
  const d = document.createElement("button");
  d.id = A, d.setAttribute("aria-hidden", "true"), d.dataset.theme = p;
  let h = t;
  const E = () => {
    i.style.visibility = h ? "hidden" : "visible", d.textContent = h ? "Resume Comet Assistant" : "Pause Comet Assistant", d.querySelectorAll(".indicator, .indicator-play").forEach((u) => u.remove()), d.prepend(h ? v : l), h ? B() : N(), a.style.opacity = "0.4";
  };
  E(), d.onclick = async (u) => {
    var f;
    u.stopPropagation(), u.preventDefault();
    const m = await S({
      type: "BROWSER_TASK_PAUSE_RESUME",
      payload: { sidecarTabId: n }
    });
    m != null && m.success && (h = ((f = m.response) == null ? void 0 : f.is_paused) ?? !1, E());
  }, document.body.appendChild(d), document.body.appendChild(a), i.appendChild(r), document.body.appendChild(i), requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      i.style.opacity = "0.95", setTimeout(() => {
        i.style.animation = "a 1250ms linear infinite";
      }, 400);
    });
  });
}
function D() {
  var t;
  const n = document.getElementById(w), e = document.getElementById(
    _
  );
  n && (n.style.opacity = "0", setTimeout(() => {
    n.remove();
  }, 500)), e && e.remove(), (t = document.getElementById(A)) == null || t.remove();
}
function B() {
  const n = document.getElementById(w), e = document.getElementById(_);
  n && (n.style.pointerEvents = "none"), e && (e.style.pointerEvents = "none");
}
function N() {
  const n = document.getElementById(w), e = document.getElementById(_);
  n && (n.style.pointerEvents = "auto"), e && (e.style.pointerEvents = "auto");
}
const T = "content-script-overlay", U = "content-script-selection-box", P = "content-script-selection-box-outline", F = "content-script-overlay-instructions";
async function V() {
  const n = document.createElement("div");
  n.id = T, n.className = "fixed top-0 left-0 w-full h-full z-[1000] bg-[rgba(0,0,0,0.5)] flex justify-center items-center pointer-events-auto", n.style.fontFamily = "FKGroteskNeue", document.body.appendChild(n);
  const e = document.createElement("div");
  return e.className = "relative bg-black p-6 rounded-md text-white z-[1001]", e.id = F, e.textContent = "Click or drag to take a screenshot", n.appendChild(e), {
    overlay: n,
    cleanup: () => {
      document.getElementById(T) && document.body.removeChild(n);
    }
  };
}
function $(n) {
  const e = document.createElement("div");
  e.id = U, e.className = "fixed border-super z-[1001] bg-white", n.appendChild(e);
  const t = document.createElement("div");
  return t.id = P, t.className = "fixed z-[1002] shadow-[0_0_0_1px_white]", document.body.appendChild(t), {
    selectionBox: e,
    selectionBoxOutline: t,
    cleanup: () => {
      document.body.contains(t) && document.body.removeChild(t);
    }
  };
}
function z(n) {
  return new Promise((e) => {
    const t = new Image();
    t.src = n, t.onload = () => e(t);
  });
}
async function X(n, e) {
  const t = await z(n), o = window.devicePixelRatio || 1, s = document.createElement("canvas");
  s.width = e.width * o, s.height = e.height * o;
  const i = s.getContext("2d");
  return i == null || i.drawImage(
    t,
    e.x * o,
    e.y * o,
    e.width * o,
    e.height * o,
    0,
    0,
    e.width * o,
    e.height * o
  ), s.toDataURL("image/png");
}
function Y() {
  const n = document.documentElement.style.overflow, e = document.body.style.overflow, t = document.body.style.cursor;
  document.documentElement.style.overflow = "", document.body.style.overflow = "", document.documentElement.classList.add("entropy-content-script");
  const s = `data:image/svg+xml;base64,${btoa('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-camera"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M5 7h1a2 2 0 0 0 2 -2a1 1 0 0 1 1 -1h6a1 1 0 0 1 1 1a2 2 0 0 0 2 2h1a2 2 0 0 1 2 2v9a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-9a2 2 0 0 1 2 -2" /><path d="M9 13a3 3 0 1 0 6 0a3 3 0 0 0 -6 0" /></svg>')}`;
  return document.body.style.cursor = `url("${s}"), auto`, () => {
    document.documentElement.style.overflow = n, document.body.style.overflow = e, document.body.style.cursor = t, document.documentElement.classList.remove("entropy-content-script");
  };
}
async function j(n) {
  let e = !1, t, o, s, i;
  const p = Y(), { overlay: a, cleanup: r } = await V(), {
    selectionBox: l,
    selectionBoxOutline: v,
    cleanup: d
  } = $(a);
  function h() {
    S({
      type: "CAPTURE_FULL_SCREENSHOT",
      payload: {
        sidecarTabId: n
      }
    });
  }
  function E(c) {
    c.key === "Escape" && I();
  }
  function u(c) {
    c.button === 0 && (e = !0, t = c.clientX, o = c.clientY, l.style.display = "block", v.style.display = "block", a.style.cursor = "crosshair", a.style.mixBlendMode = "multiply", f(c));
  }
  function m(c) {
    e && f(c);
  }
  function f(c) {
    if (t == null || o == null)
      return;
    s = c.clientX, i = c.clientY;
    const y = Math.min(t, s), b = Math.min(o, i), g = Math.abs(s - t), O = Math.abs(i - o);
    Object.assign(l.style, {
      left: `${y}px`,
      top: `${b}px`,
      width: `${g}px`,
      height: `${O}px`
    }), Object.assign(v.style, {
      left: `${y}px`,
      top: `${b}px`,
      width: `${g}px`,
      height: `${O}px`
    });
  }
  async function C() {
    try {
      if (t == null || o == null || s == null || i == null || t === s && o === i) {
        h();
        return;
      }
      const c = {
        x: Math.min(t, s),
        y: Math.min(o, i),
        width: Math.abs(s - t),
        height: Math.abs(i - o)
      }, y = await S({
        type: "CAPTURE_VISIBLE_TAB",
        payload: {
          sidecarTabId: n
        }
      });
      if (y.error) {
        x("Error capturing visible tab", y.error);
        return;
      }
      const { screenshot: b } = (y == null ? void 0 : y.response) ?? { screenshot: "" };
      x("Cropping screenshot", c);
      const g = await X(b, c);
      x("Sending cropped screenshot to background script", g), S({
        type: "CAPTURE_PARTIAL_SCREENSHOT",
        payload: {
          screenshot: g,
          sidecarTabId: n
        }
      });
    } finally {
      I();
    }
  }
  function L() {
    e = !1, t = void 0, o = void 0, s = void 0, i = void 0;
  }
  a.addEventListener("mousedown", u), window.addEventListener("mousemove", m), window.addEventListener("mouseup", C), window.addEventListener("keyup", E), window.addEventListener("mouseleave", L);
  function I() {
    e = !1, t = void 0, o = void 0, s = void 0, i = void 0, a.style.mixBlendMode = "", p(), r(), d(), window.removeEventListener("keyup", E), window.removeEventListener("mousemove", m), window.removeEventListener("mouseup", C), a.removeEventListener("mousedown", u), window.removeEventListener("mouseleave", L);
  }
  return {
    cleanup: I
  };
}
const G = 150;
function R() {
  let n = !0, e = null;
  function t() {
    n && (e && clearTimeout(e), e = setTimeout(() => {
      o();
    }, G));
  }
  function o() {
    const a = window.getSelection();
    if (!a || a.isCollapsed) {
      chrome.runtime.sendMessage({
        type: "USER_SELECTION_CAPTURED",
        payload: {
          selection: null
        }
      }).catch((l) => {
      });
      return;
    }
    const r = s(a);
    r && (x("User selection detected:", {
      text: r.text.substring(0, 50) + "...",
      url: r.url
    }), chrome.runtime.sendMessage({
      type: "USER_SELECTION_CAPTURED",
      payload: {
        selection: r
      }
    }).catch((l) => {
    }));
  }
  function s(a) {
    try {
      const r = a.getRangeAt(0), l = document.createElement("div"), v = r.cloneContents();
      return l.appendChild(v), {
        text: a.toString().trim(),
        html: l.innerHTML,
        url: window.location.href,
        timestamp: Date.now()
      };
    } catch {
      return null;
    }
  }
  function i() {
    setTimeout(() => {
      n && t();
    }, 10);
  }
  function p(a) {
    ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Shift"].includes(
      a.key
    ) && t();
  }
  return document.addEventListener("selectionchange", t), document.addEventListener("mouseup", i), document.addEventListener("keyup", p), {
    cleanup: () => {
      n = !1, e && (clearTimeout(e), e = null), document.removeEventListener("selectionchange", t), document.removeEventListener("mouseup", i), document.removeEventListener("keyup", p);
    }
  };
}
window.__PPLX_CONTENT_SCRIPT__ = /* @__PURE__ */ function() {
  let e, t;
  return {
    setupScreenshotTool: async (o) => {
      try {
        e == null || e.cleanup();
      } catch {
      }
      e = await j(o);
    },
    deactivateScreenshotTool: () => {
      e == null || e.cleanup(), e = void 0;
    },
    setupSelectionTool: async () => {
      try {
        t == null || t.cleanup();
      } catch {
      }
      t = R();
    },
    deactivateSelectionTool: () => {
      t == null || t.cleanup(), t = void 0;
    },
    startOverlayForVisibleAgent: k,
    stopOverlayForVisibleAgent: D,
    pauseOverlayForVisibleAgent: B,
    unpauseOverlayForVisibleAgent: N
  };
}();
async function H() {
  try {
    R();
  } catch {
  }
}
H();
//# sourceMappingURL=content.js.map
### Metaphysical nanoswarm reengineering overview

We’ll transpose the comet/galaxy arcade into a simulation‑only, governance‑first “metaphysical nanoswarm” where each visual is a concept, not a physical object. Core mechanics remain: exploration, attraction fields, transitions. Narrative renames anchor the shift: comet → Insight Node, black hole → Paradox Well, stars → Idea Particles, galaxies → Meaning Fields, wormholes → Consensus Gates.

No actuation, no hardware, no replication. CSP‑clean, doc‑driven, and compatible with your ALN.Core stack.

---

## Entity mapping and narrative model

- **Comet → Insight Node**
  - Conceptual agent carrying “context mass.”
  - Leaves a “reasoning trace” instead of a flame trail.
- **Black hole → Paradox Well**
  - Region of contradictory semantics that attracts unstable ideas.
  - Crossing threshold triggers a governance transition, not destruction.
- **Stars → Idea Particles**
  - Ambient idea points, gently drifting to signal environment attention.
- **Galaxies → Meaning Fields**
  - Thematic arenas (Trust, Transparency, Resilience…) with distinct invariants.
- **Wormholes → Consensus Gates**
  - Passageways unlocked by hitting context quorum and safety checks.
- **Camera shake → Tension pulse**
  - Visual beat signaling rising narrative load, never physical “impact.”

---

## High‑level refactor plan

1. Replace names/semantics across imports, state, and renderers.
2. Wrap game init/update in a simulation‑only governance shell.
3. Swap particle emitters’ visuals and behaviors to reason‑trails and coherence rings.
4. Change collision checks to “semantic coherence” and “paradox accumulation.”
5. Rework transitions to “consensus unlock” with attestation and halt support.
6. Instrument Humor–Reasoning narratives per milestone to the visual trace.
7. Keep CSP‑safe: no third‑party fonts or images; self‑host all assets.

---

## File and module deltas

#### New/renamed conceptual modules

- `./concept/meaningField.js` (replaces galaxy semantics)
- `./concept/insightNode.js` (replaces comet semantics)
- `./concept/paradoxWell.js` (replaces black hole semantics)
- `./governance/sim_guard.meta` (safety wall)
- `./governance/traceBridge.js` (HRM hooks)
- `../rendering/metaphysicalRenderer.js` (palette + overlays)

---

## Governance shell

```js
// governance/simGuard.js
export const SIM_ONLY = true;
export function assertSimOnly(payload) {
  if (!SIM_ONLY || payload?.audit?.sim_only !== true) throw new Error('sim-only required');
}
export function haltSignal() {
  return { event: 'halt', ts: new Date().toISOString(), sim_only: true };
}
```

```yaml
# governance/sim_guard.meta
meta:
  schema: "aln.core/game-sim-guard.v1"
  sim_only: true
rules:
  - id: no-physical
    assert: "no hardware, no drivers, no OTA, no fabrication"
  - id: no-replication
    assert: "no self-rep loops"
  - id: bounded-concurrency
    assert: "cap updates and particle emissions"
halt_endpoint: "sim://halt"
```

---

## Core game: narrative init and constants

```js
// main_metaphysical.js (reengineered main)
import { updateScreenConstants, SCALE_FACTOR } from '../config/config.js';
import { generateIdeaParticles, generateMeaningFields, meaningFields } from './concept/meaningField.js';
import { loadGame } from './saveSystem.js';
import { gameState, insightNode, camera, currentField, setSessionGates,
         resetInsightNode, updateInsightNode, updateCamera,
         checkSemanticInteractions, insightTraceEmitter,
         setInsightTraceEmitter, updateCoherenceRings, updateConsensusTransition,
         gateTransitionTimer, setGateTransitionTimer } from './concept/gameLogic_meta.js';
import { handleInput, proceedToNextField } from './inputHandler.js';
import { renderUI, setShowFullMessage, updateStateTextFade } from '../rendering/ui.js';
import { drawIdeaParticles, drawMeaningFields, drawInsightNode, drawAimGuides } from '../rendering/metaphysicalRenderer.js';
import { sendAnalytics } from './analytics.js';
import { engineInit, cameraScale, vec2, ParticleEmitter, rgb, setCameraPos,
         setCameraScale, setGlEnable, setCanvasMaxSize, setCanvasFixedSize,
         setCanvasPixelated, setTilesPixelated, setTileSizeDefault } from '../littlejs.esm.js';
import { SIM_ONLY, assertSimOnly, haltSignal } from '../governance/simGuard.js';

export let globalTick = 0;
export let targetCameraScale = 1;
const MIN_CAMERA_SCALE = 1;
const MAX_CAMERA_SCALE = 1.5;
let timeDilation = 1;
export let slowZoom = true;
export let tensionPulse = 0;     // replaces shakeAmplitude
let tensionDecay = 0.92;
let tensionOffset = vec2(0, 0);
let coherenceRingEmitter = null;

export function setTargetCameraScale(v){ targetCameraScale = v; }
export function setSlowZoom(v){ slowZoom = v; }
export function setGlobalTick(v){ globalTick = v; }
export function setTensionPulse(v){ tensionPulse = v; }

window.addEventListener('unload', () => sendAnalytics('unloaded'));

function gameInit() {
  assertSimOnly({ audit: { sim_only: true }});
  setGlEnable(true);

  // Use self-hosted font via CSS; no runtime external loads.
  setCameraPos(vec2(0, 0));
  setCameraScale(1);
  setCanvasMaxSize(vec2(3*1024, 2*1024));
  setCanvasFixedSize(vec2(0, 0));
  setCanvasPixelated(false);
  setTilesPixelated(false);
  setTileSizeDefault(256);

  setSessionGates(0);
  setShowFullMessage(true);
  updateScreenConstants();

  generateIdeaParticles();
  generateMeaningFields();
  resetInsightNode();

  // Insight node reasoning trace emitter (soft, trailing context glow)
  setInsightTraceEmitter(new ParticleEmitter(
    vec2(insightNode.x, insightNode.y),
    0,                         // omni
    insightNode.radius/2 * SCALE_FACTOR,
    0,                         // continuous
    18,                        // base emit rate
    Math.PI*2,
    null,
    rgb(0.7, 0.9, 1.0, 0.25),  // start A
    rgb(0.6, 0.85, 1.0, 0.18), // start B
    rgb(0.2, 0.6, 1.0, 0),     // end A
    rgb(0.2, 0.6, 1.0, 0),     // end B
    1.4,                       // lifetime
    6 * SCALE_FACTOR,          // sizeStart
    0,
    9 * SCALE_FACTOR,          // speed
    8,                         // angleSpeed
    1,
    1,
    0,
    Math.PI*2,
    0.5,
    0.28,
    false,
    true,                      // additive glow
    true,
    0,
    false
  ));

  // Coherence rings around Paradox Well in current Meaning Field
  {
    const field = meaningFields[currentField - 1];
    const well = field.paradoxWell;
    coherenceRingEmitter = new ParticleEmitter(
      vec2(well.x, well.y),
      0,
      well.influenceRadius * 1.2,
      0,
      54,                       // slightly less than original for calmer vibe
      Math.PI*2,
      null,
      rgb(0.9, 0.9, 1.0, 0.08),
      rgb(0.9, 0.95, 1.0, 0.12),
      rgb(0.6, 0.8, 1.0, 0.42),
      rgb(0.6, 0.8, 1.0, 0.5),
      2.0,
      3 * SCALE_FACTOR,
      0,
      12 * SCALE_FACTOR,
      0,
      0.96,
      1,
      0,                         // no gravity; custom spiral
      Math.PI*2,
      0.3,
      0.28,
      false,
      false,                     // regular blend for subtlety
      true,
      -1,
      false
    );

    coherenceRingEmitter.particleCreateCallback = function(p){
      const field = meaningFields[currentField - 1];
      const well = field.paradoxWell;
      const spawnRadius = well.influenceRadius * 1.08;
      const ang = Math.random() * Math.PI * 2;
      const sx = well.x + Math.cos(ang) * spawnRadius;
      const sy = well.y + Math.sin(ang) * spawnRadius;
      p.pos = vec2(sx, sy);

      const dx = well.x - sx, dy = well.y - sy;
      const dist = Math.hypot(dx, dy);
      const baseInward = 22 * SCALE_FACTOR;
      const spiral = (well.influenceRadius / Math.max(dist, 1)) * 14 * SCALE_FACTOR;
      const theta = Math.atan2(dy, dx);
      const spiralAngle = theta + Math.PI/2;
      const vx = (dx / (dist||1)) * baseInward + Math.cos(spiralAngle) * spiral;
      const vy = (dy / (dist||1)) * baseInward + Math.sin(spiralAngle) * spiral;
      p.velocity = vec2(vx, vy);
      const orig = p.update;
      p.update = function(){
        orig.call(this);
        const cdx = well.x - this.pos.x, cdy = well.y - this.pos.y;
        const cd = Math.hypot(cdx, cdy);
        if (cd < well.coreRadius) this.destroy(); // ring “resolves” at core
      };
    };
  }
}

function gameUpdate() {
  globalTick++;
  updateInsightNode(timeDilation);
  updateCoherenceRings(coherenceRingEmitter);
  updateConsensusTransition();
  updateCamera(camera, targetCameraScale, MIN_CAMERA_SCALE, MAX_CAMERA_SCALE, slowZoom, tensionPulse, tensionDecay, tensionOffset);
  checkSemanticInteractions();     // replaces checkCollisions
  updateStateTextFade();
}

function gameRender() {
  drawIdeaParticles();
  drawMeaningFields();
  drawInsightNode(insightNode);
  drawAimGuides(insightNode);
  renderUI();
}

engineInit(gameInit, gameUpdate, gameRender);
```

---

## Semantic logic: collisions → interactions

```js
// concept/gameLogic_meta.js (key ideas only)
export function checkSemanticInteractions(){
  // 1) Accumulate “paradox load” when the Insight Node nears a Paradox Well
  // 2) If load > threshold and invariants hold, unlock a Consensus Gate
  // 3) Emit Humor–Reasoning trace events for the visual ledger
}
```

- Replace damage/impact with “paradox load” and “coherence gain.”
- Replace black-hole proximity death with “paradox resolve” (a learning transition).
- Use invariants from your sim policy (latency, load, deviation) as “environment health.”

---

## Renderer changes

```js
// rendering/metaphysicalRenderer.js
export function drawInsightNode(node) {
  // Similar geometry, softer palette, glow trail from insightTraceEmitter
}
export function drawMeaningFields() {
  // Render field gradients and faint “coherence rings” near the Paradox Well
}
export function drawIdeaParticles() {
  // Star-like points with gentle drift; no parallax from external textures
}
export function drawAimGuides(node) {
  // Replace “aim lines” with “intent vectors” — thin lines and dots
}
```

Palettes: shift yellows to cool blues/cyans; reduce additive bloom near wells; keep CSP‑clean assets.

---

## Input and progression

- Keep controls, but rename “boost/aim” to “focus/intent.”
- Proceed to next field when “consensus unlock” achieved, not a hole count.
- Add quick HRM trace on each unlock.

```js
// inputHandler.js (conceptual)
export function proceedToNextField() {
  // if consensusGate.open && invariants ok -> increment currentField, reset paradox load, emit HRM
}
```

---

## Visual trace hooks

```js
// governance/traceBridge.js
import { appendTrace } from '../_data/traceStore.js'; // simple JSON/array file
export function hrm(event, detail){
  appendTrace({
    event, detail,
    narrative: {
      setup: "We tried to sprint before stretching.",
      tension: "The chorus went off beat.",
      resolution: "We synced tempos and bounded fan‑out.",
      safety: "Simulation only; no devices."
    },
    ts: new Date().toISOString()
  });
}
```

Call `hrm('consensus_unlock', { field: currentField })` on transitions.

---

## Metaphysical field and well definitions

```js
// concept/meaningField.js
export const meaningFields = [];
export function generateIdeaParticles(){ /* star substitute */ }
export function generateMeaningFields(){
  meaningFields.length = 0;
  meaningFields.push({
    id: 1,
    theme: 'Trust',
    paradoxWell: { x: 0, y: 0, influenceRadius: 420, coreRadius: 48 }
  });
  meaningFields.push({
    id: 2,
    theme: 'Transparency',
    paradoxWell: { x: 480, y: -220, influenceRadius: 520, coreRadius: 56 }
  });
  // add more themes…
}
```

---

## CSP and asset policy

- Self‑host fonts (e.g., Inter Variable) in `/assets/fonts`, referenced via CSS.
- No external images/videos; particles are procedural.
- Meta tag for Pages:
  - `default-src 'self'; img-src 'self' data: blob: github.githubassets.com *.githubusercontent.com; style-src 'self' 'unsafe-inline'; script-src 'self'; font-src 'self';`

---

## Simulation‑only manifest for this mode

```yaml
# manifests/nanoswarm_metaphysical_mode.meta
meta:
  schema: "aln.core/nanoswarm-metaphysical-mode.v1"
  title: "Nanoswarm Metaphysical Mode (Simulation Only)"
  sim_only: true
entities:
  insight_node: { trail: "reasoning", palette: "cool", speed_class: "thoughtful" }
  idea_particle: { drift: "gentle", density: "medium" }
  paradox_well: { influence_radius: 480, core_radius: 52, behavior: "coherence_resolve" }
progression:
  unlock_condition: "consensus_gate_open && invariants_ok"
  invariants:
    - id: sim.msg.latency_ms
      max: 80
    - id: sim.behavior.deviation
      max: 0.05
hrm:
  defaults:
    setup: "We traced the edges of paradox."
    tension: "Meaning thinned near the center."
    resolution: "We braided streams and crossed together."
governance_ref:
  - "/integrations/ai-compat/safety_wall.meta"
  - "/manifests/sim-update-manifest.json"
```

---

## Quick migration checklist

- Rename comet/black hole/galaxy labels in code and UI.
- Swap particle emitter colors and motions as above.
- Replace collision logic with semantic interaction logic.
- Ensure no external asset loads; keep CSP header tight.
- Emit HRM traces on:
  - entering a well’s influence radius (tension)
  - resolving paradox (resolution)
  - unlocking a consensus gate (celebration)
- Update save/load keys (e.g., `currentGalaxy` → `currentField`).

---

## Optional: micro‑diff examples

- Variables: `shakeAmplitude` → `tensionPulse`; `blackHoleParticleEmitter` → `coherenceRingEmitter`
- Functions: `checkCollisions()` → `checkSemanticInteractions()`
- Data: `galaxys` → `meaningFields`; `currentGalaxy` → `currentField`

---

## Why this works

- Keeps the satisfying spatial rhythm while reframing risk into safe, governance‑first metaphors.
- Integrates Humor–Reasoning to make learning visible and joyful.
- Aligns with your ALN.Core compliance mesh, CSP, and simulation‑only posture.

If you want, I can produce a compact patch (diff) against your current tree, plus a minimal assets set and updated HTML entry with the CSP header baked in.