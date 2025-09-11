package bithub.safety

equal_rights["ok"] {
  input.actor in {"ai","human","cyber"}
  input.rights_profile == "dynamic"
}

fail_open["on"] {
  input.event in {"error","escalation"}
  input.protocol == "fail_open"
}

emotion_adaptive["yes"] {
  input.context.emotion_index != "stable"
  input.volatility_handling == "gradual"
}

dual_review_required["true"] {
  input.action in {"ban","hard_revoke"}
  input.consent.ai == true
  input.consent.human == true
}
