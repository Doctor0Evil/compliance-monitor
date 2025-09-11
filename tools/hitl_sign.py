#!/usr/bin/env python3
# tools/hitl_sign.py
# Usage: ./hitl_sign.py ledger_record.jsonl index_to_sign
# Simulated HITL signer. Reads a JSONL ledger, prompts HITL approval, and writes a signed record file.
import sys, json, os, getpass, time, hashlib
from pathlib import Path

LEDGER_PATH = sys.argv[1] if len(sys.argv) > 1 else "./web5_keyless_ledger.jsonl"
INDEX = int(sys.argv[2]) if len(sys.argv) > 2 else -1
OUT_DIR = "./signed_attestations"
Path(OUT_DIR).mkdir(parents=True, exist_ok=True)

def load_lines(path):
    with open(path, "r") as f:
        return [json.loads(l) for l in f if l.strip()]

lines = load_lines(LEDGER_PATH)
if INDEX < 0 or INDEX >= len(lines):
    print(f"Available records: {len(lines)}. Provide index 0..{len(lines)-1}")
    for i, rec in enumerate(lines[:20]):
        print(i, rec.get("record", {}).get("event", {}).get("type", "<evt>"))
    sys.exit(1)

rec = lines[INDEX]
print("Record to attest:")
print(json.dumps(rec, indent=2))

# Human approval step
resp = input("HITL: Type APPROVE to sign, anything else to cancel: ").strip()
if resp != "APPROVE":
    print("Canceled by human.")
    sys.exit(2)

# Demo signer: ask for passphrase to derive an HMAC-style signature (software-only)
pw = getpass.getpass("Enter passphrase for local attestation (demo only): ")
# Create a deterministic signature (HMAC-like) using sha512
payload = json.dumps(rec, sort_keys=True).encode()
sig = hashlib.pbkdf2_hmac("sha512", payload, pw.encode(), 100_000).hex()

attestation = {
    "attested_record_index": INDEX,
    "attested_at": time.time(),
    "attester": "human:HITL-demo",
    "method": "software-derived-hmac-demo",
    "signature": sig,
    "note": "DEMO only — for real use, integrate HSM or hardware token and store attestation in airgapped archive"
}
outf = os.path.join(OUT_DIR, f"attestation_{INDEX}_{int(time.time())}.json")
with open(outf, "w") as f:
    json.dump(attestation, f, indent=2)
print(f"Attestation written to {outf}")
