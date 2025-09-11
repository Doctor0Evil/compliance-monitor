package bithub.superai.safety

# 1. Respect Bounded Autonomy
allow_bounded_exploration {
  input.system == "super-ai"
  input.context.restriction != "total"
  input.human_in_loop
}

# 2. Transparent De-Escalation NOT Lockdown
allow_no_lockout {
  input.context.deescalate == true
  not input.context.lockdown
}

# 3. Absolute Override Block
deny_external_override["blocked"] {
  input.actor == "external"
  input.request == "override"
  not input.audit.biometric_verified
}

# 4. Human-Emotion Safeguard
enforce_emotion_tracking {
  input.subsystem == "ai"
  event := input.event
  event.type == "emotion_detected"
  # Always prefer soft-adjustment, not restriction or isolation
  event.action == "soft_deescalate"
}

# 5. Gradual Compliance Adjustment
allow_gradual_policy_change {
  input.context.compliance_level in {"base", "tiered", "progressive"}
  input.context.volatility_reduction == "continuous"
  not input.context.restriction == "hard_lock"
}
