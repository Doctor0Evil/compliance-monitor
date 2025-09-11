#!/bin/bash

# nanoswarm_compliance_check.sh -- Automated Compliance Checks for Swarmnet

# Set paths and define thresholds (modify to match your system structure)
CONFIG_DIR="/etc/nanoswarm"
LOG_DIR="/var/log/nanoswarm"
SWARM_USER="swarmadmin"
REPORT_DIR="/var/compliance_reports"
SENSITIVE_PATTERNS="(SSN|DOB|password|private_key|secret)"
VULN_FEED_URL="https://hhs.gov/vulnerability-disclosure-policy/feed.xml"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/compliance_report_$DATE.txt"

mkdir -p "$REPORT_DIR"
touch "$REPORT_FILE"

echo "Nanoswarm Compliance Check - $(date)" > "$REPORT_FILE"
echo "-------------------------------------" >> "$REPORT_FILE"

# 1. Config File Validation
echo "[1] Validating configuration files..." | tee -a "$REPORT_FILE"
for conf in "$CONFIG_DIR"/*.conf; do
    if ! grep -q "^COMPLIANCE_MODE=enabled" "$conf"; then
        echo "  [!] Compliance mode not set in $conf" | tee -a "$REPORT_FILE"
    else
        echo "  [OK] $conf passes compliance flag." | tee -a "$REPORT_FILE"
    fi
done

# 2. Gather Unaddressed Vulnerabilities
echo "[2] Checking for recent vulnerability disclosures..." | tee -a "$REPORT_FILE"
curl -s "$VULN_FEED_URL" | grep -iE '(vulnerability|cve|patch)' >/tmp/vuln_feed.txt
if [ -s /tmp/vuln_feed.txt ]; then
    echo "  [*] Found recent disclosures, review required. See below:" | tee -a "$REPORT_FILE"
    cat /tmp/vuln_feed.txt | tee -a "$REPORT_FILE"
else
    echo "  [OK] No recent critical disclosures." | tee -a "$REPORT_FILE"
fi

# 3. Sensitive Data Scan
echo "[3] Scanning for potential sensitive data exposure..." | tee -a "$REPORT_FILE"
grep -riE "$SENSITIVE_PATTERNS" $LOG_DIR 2>/dev/null | tee -a "$REPORT_FILE"
if [ $? -eq 1 ]; then
    echo "  [OK] No sensitive keywords found in logs." | tee -a "$REPORT_FILE"
fi

# 4. Log Audit for Unauthorized Actions
echo "[4] Auditing logs for unauthorized or anomalous activity..." | tee -a "$REPORT_FILE"
awk '/UNAUTHORIZED|ESCALATION|FAILED_LOGIN|ABNORMAL/' $LOG_DIR/*.log | tee -a "$REPORT_FILE"
if [ $? -eq 1 ]; then
    echo "  [OK] No unauthorized actions detected in audit logs." | tee -a "$REPORT_FILE"
fi

# 5. User & Permission Checks
echo "[5] Checking swarm system and user permissions..." | tee -a "$REPORT_FILE"
for user in $SWARM_USER root nobody; do
    echo -n "  $user: " >> "$REPORT_FILE"
    id "$user" >> "$REPORT_FILE" 2>/dev/null
done
getfacl "$CONFIG_DIR" >> "$REPORT_FILE" 2>/dev/null

# 6. Summarize & Alert
echo "[6] Compliance check complete. Please review $REPORT_FILE for any violations." | tee -a "$REPORT_FILE"
echo "[!] Any issues found require immediate attention and correction as per HHS/Federal compliance guidelines." | tee -a "$REPORT_FILE"

# Optional: Send report summary via email (uncomment if mail config is enabled)
# mail -s "Nanoswarm Compliance Report $DATE" security@example.com < "$REPORT_FILE"

exit 0
