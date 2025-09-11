package cybernetics.rights.web5

allow_equal_dignity[entity] {
  entity in input.affected_parties
  input.rights.equal_dignity == true
}

deny_irreversible_block[entity] {
  input.action == "permanent_deactivation"
  input.dual_reasoning_missing == true
}

audit_required[action] {
  input.context in {"override","restriction","escalation"}
}

require_dynamic_consent[entity] {
  input.entity == entity
  input.rights.revocable == true
  input.region_compliant == true
}

explainability_required[action] {
  input.action in {"restrict","override","enforce"}
  input.explanation.provided == true
}
