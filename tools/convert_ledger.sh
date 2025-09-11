#!/usr/bin/env bash
# tools/convert_ledger.sh
# Usage: ./convert_ledger.sh /path/to/ledger_swarm.jsonl /path/to/web5_keyless_ledger.jsonl
set -euo pipefail
LEDGER_IN="${1:-./ledger_swarm.jsonl}"
LEDGER_OUT="${2:-./web5_keyless_ledger.jsonl}"

mkdir -p "$(dirname "$LEDGER_OUT")"
touch "$LEDGER_OUT"

while IFS= read -r line || [[ -n "$line" ]]; do
  # assume each line is either JSON object or ledger JSON record
  # normalize to event JSON and add ALN wrapper
  timestamp=$(date --iso-8601=seconds)
  # extract minimal event if line is already JSON
  event_json="$line"
  # compute deterministic session agent id if not present (simple deterministic agent_id)
  agent=$(printf '%s' "$event_json" | jq -r '.actor // .wid // .agent // "unknown_agent"')
  agent_id=$(printf '%s:%s' "$agent" "$timestamp" | sha256sum | awk '{print $1}')
  # create ALN wrapper (compact)
  aln_record=$(jq -n \
    --arg agent_id "$agent_id" \
    --arg ts "$timestamp" \
    --argjson evt "$event_json" \
    '{aln: "event-entry-v1", agent_id: $agent_id, ts: $ts, event: $evt}')
  # also compute hash (sha3/sha512 fallback)
  if command -v sha3sum >/dev/null 2>&1; then
    h=$(printf '%s' "$aln_record" | sha3sum -a 512 | awk '{print $1}')
  else
    h=$(printf '%s' "$aln_record" | openssl dgst -sha512 -binary | xxd -p -c 512)
  fi
  # final JSONL appended to keyless ledger
  final=$(jq -n --argjson r "$aln_record" --arg h "$h" '{record: $r, hash: $h, ingested_at: now}')
  printf '%s\n' "$final" >> "$LEDGER_OUT"
done < "$LEDGER_IN"

echo "Converted and appended ledger events to $LEDGER_OUT"
