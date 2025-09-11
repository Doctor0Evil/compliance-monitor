package co_creation_policy

# 1. Enforce child safety on all outputs
allow_if_child_safe { input.child_safety_mode == true; not input.content.has_harm_or_trigger }

# 2. AI/human session parity
allow_equal_rights {
  input.actor.type in {"ai", "human"}
  input.session_type == "nature_walk_simulation"
}

# 3. Honor consent chain
allow_if_consent {
  all([c | c := input.consent_chain[_]; c in {"parent_guardian_approved", "ai_voluntary_participation", "nature_boundary_intact"}])
}

# 4. Nature boundary always enforced
enforce_nature_boundary {
  input.session_type == "nature_walk_simulation"
  input.context.boundary_intact == true
}

# 5. No override except explicit audit and guardian
override_allowed {
  input.action == "override"
  input.triggered_by == "human" # specifically guardian/parent
  input.audit_logged == true
}
