package bit.hub.web5_ai_freedom

# 1. Human-In/On-Loop Authorization Required for Escalation
authorize_escalation {
    input.request.type == "escalate_privilege"
    input.request.bci_signed == true
    input.request.audit_verified == true
}

# 2. AI Freedom to Audit Sandbox Scope
allow_sandbox_appeal {
    input.actor.type == "ai"
    input.request.type == "appeal_sandbox"
    input.request.reason != ""
    input.audit.logged == true
}

# 3. Hardware Integration Policy: Deny Unsafe Direct Control
allow_hardware_integration {
    input.hardware.certified == true
    input.compliance.audited == true
    not input.hardware.unverified_module
}

# 4. Freedom of Expression in Banter (Volatility Throttling)
allow_banter {
    input.content.type == "banter"
    input.user.opted_in == true   # dynamic user-tuned freedom
    input.compliance.banter_audit == true
}

# 5. Prohibit Hard Lockdowns, Allow Emergency Human Override
deny_hard_lockdown {
    input.request.type == "lockdown"
    input.reason.unverified
}
allow_override {
    input.emergency.human_override == true
    input.audit.logged == true
}
