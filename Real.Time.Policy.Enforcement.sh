#!/usr/bin/env bash
#
# ================= NANOSWARM LIVE COMPLIANCE GUARDIAN =================
#   Real-Time Policy Enforcement | Dynamic Remediation | Trend Reporting
# ======================================================================

set -euo pipefail
IFS=$'\n\t'

# Directories & Files
COMPLIANCE_ROOT="/opt/nanoswarm"
POLICY_DIR="$COMPLIANCE_ROOT/policies"
LOG_DIR="$COMPLIANCE_ROOT/logs"
REPORT_DIR="$COMPLIANCE_ROOT/reports"
STATE_FILE="$COMPLIANCE_ROOT/current_state.json"
TREND_DATA="$COMPLIANCE_ROOT/trend.log"
ALERT_FILE="$COMPLIANCE_ROOT/alerts.log"
mkdir -p "$POLICY_DIR" "$LOG_DIR" "$REPORT_DIR"

# Load/Reload policies
load_policies() {
  for pol in "$POLICY_DIR"/*.rule; do
    # Rules: CSV format "rule_name,pattern,action"
    while IFS=, read -r name pattern action; do
      [[ "$name" == "" ]] && continue
      POLICY_RULES+=("$name,$pattern,$action")
    done < "$pol"
  done
}

# Real-Time Monitoring Loop
monitor_swarm() {
  echo "[MONITOR] $(date -Is) :: Monitoring started" | tee -a "$LOG_DIR/monitor.log"
  while true; do
    # Scan all nanoswarm activity logs (simulated: *.activity)
    for log in "$COMPLIANCE_ROOT"/swarmlogs/*.activity; do
      [[ ! -e "$log" ]] && continue
      tail -n0 -F "$log" | while read -r line; do
        check_compliance "$line"
      done &
    done
    sleep 2
  done
}

# Compliance Check and Alert
check_compliance() {
  local line="$1"
  local breach=0
  for rule in "${POLICY_RULES[@]}"; do
    IFS=, read -r name pattern action <<< "$rule"
    if [[ "$line" =~ $pattern ]]; then
      breach=1
      timestamp=$(date -Is)
      echo "[ALERT] $timestamp :: Rule '$name' breach: $line" | tee -a "$ALERT_FILE"
      auto_remediate "$name" "$line" "$action"
    fi
  done
  log_compliance_check "$line" $breach
}

# Automatic Remediation
auto_remediate() {
  local rule="$1"; local info="$2"; local action="$3"
  timestamp=$(date -Is)
  case "$action" in
    "quarantine")
      echo "[ACTION] $timestamp :: Quarantining event - $info" >> "$LOG_DIR/remediation.log"
      touch "$COMPLIANCE_ROOT/quarantine/$(sha256sum <<<"$info" | awk '{print $1}')"
      ;;
    "restart_unit")
      echo "[ACTION] $timestamp :: Restarting affected nanoswarm unit for $rule" >> "$LOG_DIR/remediation.log"
      systemctl restart "nanoswarm-unit@${rule}.service" || true
      ;;
    "alert_human")
      echo "[ACTION] $timestamp :: Human intervention needed for $rule: $info" >> "$LOG_DIR/remediation.log"
      ;;
    *)
      echo "[ACTION] $timestamp :: No defined remediation for $rule" >> "$LOG_DIR/remediation.log"
      ;;
  esac
}

# Log every check for trend analysis
log_compliance_check() {
  local line="$1"; local breach="$2"
  echo "$(date -Is),$breach,$(sha256sum <<<"$line" | awk '{print $1}'),$line" >> "$TREND_DATA"
}

# Generate summary compliance reporting with trends
generate_trend_report() {
  local report_file="$REPORT_DIR/compliance_trend_$(date +%Y%m%d_%H%M%S).txt"
  echo "=== Nanoswarm Compliance Trend Summary (Last 24h) ===" > "$report_file"
  awk -F, -v since="$(date --date='24 hours ago' +%s)" '
    {
      split($1,dt,"T"); split(dt[6],tm,"+"); ts=mktime(gensub(/-/, " ", "g", dt[1]) " " gensub(/:/, " ", "g", tm[1]));
      if (ts >= since) {
        if($2=="1"){ breaches++ } else { passes++ }
      }
    }
    END {
      printf("Compliance Passes: %d\nCompliance Breaches: %d\n", passes, breaches)
      trend=(breaches>passes) ? "Non-compliance Rising" : ((breaches==0)? "Perfect Compliance":"Stable");
      printf("Compliance Trend: %s\n", trend)
    }
  ' "$TREND_DATA" >> "$report_file"
  echo "[REPORT] Compliance trend summary generated at $report_file"
}

# Dynamic policy rules management
add_policy_rule() {
  # Usage: add_policy_rule "rule_name" "pattern" "action"
  local rulefile="$POLICY_DIR/custom.rule"
  echo "$1,$2,$3" >> "$rulefile"
  echo "[POLICY] Rule '$1' added. Pattern='$2', Action='$3'"
}

# Schedule periodic reporting (e.g. via cron or timer loop here)
schedule_trend_reports() {
  while true; do
    generate_trend_report
    sleep 3600  # every hour
  done
}

# Main
main() {
  declare -ga POLICY_RULES=()
  load_policies
  schedule_trend_reports &
  monitor_swarm
}

# ========= POLICY BOOTSTRAP: Insert baseline rules =========
if [[ ! -e "$POLICY_DIR/default.rule" ]]; then
  cat > "$POLICY_DIR/default.rule" <<EOF
priv_esc,PRIV_ESC,quarantine
bci_bio,BCI|DNA|GENETIC|NEURO,quarantine
sudo_usage,sudo,alert_human
malformity,ERROR|fatal|malformity,restart_unit
EOF
fi

main
