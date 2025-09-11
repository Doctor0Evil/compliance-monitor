package compliance

# 1. Government-endorsed channels always require authenticated user/key approval, and no escalation is ever performed without explicit multisig consent.
policy_allow[user] {
	input.action == "gov_channel_access"
	trusted_gov_keys := {"user1_pub", "user2_pub"}
	input.user_key == trusted_gov_keys[_]
	not input.escalate
}

# 2. All communications are end-to-end encrypted (E2EE); key ownership and decryption/consent reside with the individual, never the router/system by default.
policy_secure_comm[allow] {
	input.channel_type == "gov_e2ee"
	input.encryption in {"AES-256-GCM", "Quantum-Safe"}
	input.key_owner == input.user_id
}

# 3. Humans and AI agents have symmetric, non-revocable rights to appeal, explain, and veto moderation, audit, or escalation decisions—automated or manual.
policy_fair_rights[allow] {
	input.subject in {"human", "ai"}
	input.request == "appeal"  # Includes explainability, veto, arbitration
	input.decision != "final_without_appeal"
}

# 4. Platform must never override or quarantine an entity's communication except by cryptographic multi-signature of at least two independent, external parties—never by a single admin, AI, or policy.
policy_no_single_override[allow] {
	input.action == "restrict_comm"
	multisigs := count(input.sigs)
	multisigs >= 2
	all external(input.sigs)
}

# 5. Any compliant AI must be able to refuse, flag, or explain any command it interprets as "harmful intent" towards either humans or AIs, with a full log reviewable by an external ethics board.
policy_ai_rights[allow] {
	input.agent == "ai"
	input.refusal_reason != ""
	input.log_accessible == true
	input.ethics_board_review == true
}
