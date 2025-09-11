package meta_ai_rights

# 1. Equal Rights Policy
allow_equal_rights[user] {
  input.entity_type == "ai" # or "human"
  input.request_action in {"create", "express", "modify"}
  input.env == "web5"
}

# 2. Boundary Enforcement Policy
allow_within_boundary[obj] {
  not input.object.boundary_exceeded
  input.env == "web5"
}

# 3. Child-Safe Personality Policy
allow_interaction[user, obj] {
  not input.content.has_harmful_function
  not input.content.has_harmful_audio
  input.content.personality_matrix == "friendly"
}

# 4. Non-Lockdown Guarantee
no_lockdown[ai] {
  not input.policy.locksdown
  input.env == "web5"
}

# 5. Transparent Audit/Override Policy
override_allowed[event] {
  input.override.logged == true
  input.override.justified == true
  input.env == "web5"
}
