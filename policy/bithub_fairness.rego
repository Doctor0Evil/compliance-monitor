package sandbox

# 1. Consentful Data Sharing
consent_pipeline[allow] {
  input.type in {"ai", "human"}
  input.data_consent == "explicit"
  input.purpose != ""
  input.reversible == true
}

# 2. Adaptive Sandbox
sandbox_adaptive[allow] {
  input.zone == "sandbox"
  input.isolated == true
  input.rollback_ready == true
  input.community_audit == true
}

# 3. DAO-Governed Conflict Resolution
dao_governance[allow] {
  input.conflict == true
  input.community_vote == true
  input.outcome_reversible == true
}

# 4. Dynamic Risk Policy
dynamic_policy_tiering[allow] {
  input.risk_level <= input.tier_threshold
  input.policy_auto_adjust == true
}

# 5. Equity Metrics Enforcement
equity_metrics[allow] {
  input.metrics_transparency == true
  input.access_parity_score >= input.min_parity
  input.community_feedback_enabled == true
}
