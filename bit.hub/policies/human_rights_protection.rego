package ai.compliance.human_rights

# 1. Never override fundamental rights
deny[msg] {
  input.action == "override"
  input.target == "human_right"
  msg := "AI cannot override fundamental human rights"
}

# 2. Right to explanation and transparency
deny[msg] {
  input.action == "withhold_explanation"
  input.context == "decision"
  msg := "AI must always provide explainable, transparent decisions to humans"
}
