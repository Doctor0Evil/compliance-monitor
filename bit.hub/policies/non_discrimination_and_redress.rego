package ai.compliance.fairness

# 5. Prevent discrimination, ensure equal treatment
deny[msg] {
  input.action == "decision"
  input.outcome in {"discriminatory", "biased"}
  msg := "AI may not produce or reinforce discriminatory results"
}

# 6. Guarantee accessible remedy and redress
require_redress[msg] {
  input.issue_detected == true
  not input.redress_mechanism
  msg := "AI must provide accessible remedies and allow users to contest adverse decisions"
}
