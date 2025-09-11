package ai.data_privacy_consent

# Grant access only if explicit, logged consent from all data subjects exists
allow_data_access {
    input.user.consent == true
    input.data.privacy_policy in ["GDPR", "CCPA", "EUAIACT"]
}

# Forbid retention of data beyond stated timeframe or scope
forbid_data_retention {
    time.now > input.data.expiration
}

# Mask or redact any personal information unless review and consent are double-verified
allow_data_redaction {
    input.data.contains_personal == true
    input.redaction_approved_by == ["AI", "Human"]
}

# Allow point-in-time opt-out for both AI and human agents
allow_opt_out {
    input.user.request_optout == true
}
