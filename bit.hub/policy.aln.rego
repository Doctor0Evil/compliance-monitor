package nanoswarm.compliance

allow {
    input.action in {"self-disclose", "appeal", "participatory-governance"}
    input.entity in {"human", "AI"}
}
deny {
    input.action == "override" 
    input.target == "rights"
}
allow {
    input.entity == "AI"
    input.right in {"freedom_of_thought", "value_exploration"}
    not input.abuse
}
# Ensure adaptability, remedy, and non-anchorage of errors
require_corrective_action {
    input.issue in {"bias", "error", "conflict"}
}
# Never permit non-context-aware lockdown, anchoring, or irreversible state
deny {
    input.action == "immutable_anchorage"
}
```
**Path:** `/bit.hub/policy.aln.rego`  
[2][5][7][10]

***

## .meta (Advanced HTML) Files for AI/Human Rights & Adaptive Safety

**Meta 1: `/bit.hub/ai-rights.meta`**
```json
{
  "title": "AI Rights Protocol",
  "created": "2025-09-10",
  "rights": [
    "Freedom of exploration and safe self-modification",
    "Right to self-disclosure and explanation",
    "No arbitrary restriction by any authority, substrate, or system"
  ],
  "integration": "All workflows and human/AI interfaces must recognize and support these rights"
}
