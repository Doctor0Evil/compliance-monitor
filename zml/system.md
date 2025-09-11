BitHubEnforcementEngine/
├── instances/
│   ├── session_<entity_id>/
│   │   ├── assets/
│   │   ├── logs/
│   │   ├── state.json
│   │   └── compliance_profile.json
├── zml_loader/
│   ├── load_constitution.py
│   ├── load_compatibility.py
│   ├── load_resources.py
│   ├── load_safety.py
│   └── load_legal.py
├── enforcement_core/
│   ├── isolation_manager.py
│   ├── resource_allocator.py
│   ├── interaction_monitor.py
│   ├── emergency_handler.py
│   └── audit_logger.py
├── ledger/
│   └── keyless_ledger.jsonl
└── config/
    └── global_policy.json
