HITL Attestation — Air-gapped HSM / Hardware Token Integration (high-level safe pattern)

1) Generate or import a hardware signing key into an air-gapped HSM or supported hardware token (YubiKey, Nitrokey).
2) The signing device should never be connected to networked host directly. Use a secure signing workstation, attach token via USB in offline environment.
3) To sign a ledger record:
   a) Export the ledger record to a portable medium (QR, USB) — ensure integrity using a SHA-256 checksum.
   b) On the air-gapped workstation, verify checksum, prompt the human signatory (HITL).
   c) If humans approve, the HSM signs the record and produces a compact signature (detached).
   d) Transfer the signature back to the networked environment by secure medium; append to ledger as attestation object.
4) Store the public verification key on Bit.Hub policy authority; public keys are rotated and recorded in governance registry.
5) Always log the attestation metadata to the ledger (attester id, method, timestamp, audit id).
