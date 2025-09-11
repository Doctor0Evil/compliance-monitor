#!/bin/bash

# GitHub webhook security script for copilot-safe-agent.internal/webhooks/github

LEDGER_LOG="/var/log/SAFE.LEDGER.v1"
HMAC_SECRET="$(cat /etc/webhook_hmac_secret)"
ALLOWED_IPS=("140.82.112.0/22" "192.30.252.0/22" "185.199.108.0/22")

function ip_allowed() {
    local ip="$1"
    for cidr in "${ALLOWED_IPS[@]}"; do
        if ipcalc -c "$ip" "$cidr" &>/dev/null; then return 0; fi
    done
    return 1
}

function verify_hmac() {
    local payload="$1"
    local signature="$2"
    local calc_sig="sha256=$(echo -n "$payload" | openssl dgst -sha256 -hmac "$HMAC_SECRET" | awk '{print $2}')"
    [[ "$signature" == "$calc_sig" ]]
}

function purge_pii() {
    # Remove PII fields using jq (customize as needed)
    echo "$1" | jq 'del(.email, .username, .user_id)'
}

function log_ledger() {
    echo "$(date +%s) | $1 | $2 | $3" >> "$LEDGER_LOG"
}

while read -r EVENT; do
    SRC_IP=$(echo "$EVENT" | jq -r '.src_ip')
    SIG=$(echo "$EVENT" | jq -r '.headers."X-Hub-Signature-256"')
    PAYLOAD=$(echo "$EVENT" | jq -r '.body')

    if ! ip_allowed "$SRC_IP"; then
        log_ledger "DENY" "$SRC_IP" "IP outside whitelist"
        continue
    fi

    if ! verify_hmac "$PAYLOAD" "$SIG"; then
        log_ledger "DENY" "$SRC_IP" "Invalid HMAC signature"
        # Cease + Notify
        touch /tmp/endpoint_in_halt
        echo "Alert: HMAC validation failed from $SRC_IP" | mail -s "CoPilot Webhook Security Halt" sec-team@example.com
        continue
    fi

    CLEAN_PAYLOAD=$(purge_pii "$PAYLOAD")
    log_ledger "ACCEPT" "$SRC_IP" "$CLEAN_PAYLOAD"

    # Out-of-scope event check (custom logic)
    EVENT_TYPE=$(echo "$CLEAN_PAYLOAD" | jq -r '.event_type')
    if [[ "$EVENT_TYPE" == "vulnerability_alert" || "$EVENT_TYPE" == "unknown" ]]; then
        log_ledger "CEASE-NOTIFY" "$SRC_IP" "Vulnerability or unknown event detected"
        touch /tmp/endpoint_in_halt
        echo "Alert: Vulnerability event from $SRC_IP" | mail -s "CoPilot Webhook Security Halt" sec-team@example.com
        continue
    fi

    # Main logic continues here...
done
exit 0
