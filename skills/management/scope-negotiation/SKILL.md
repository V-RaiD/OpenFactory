---
name: "scope-negotiation"
description: "Negotiate project scope when resources, budget, or timeline are constrained"
version: "1.0.0"
category: "management"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best at balancing business value against technical feasibility in scope decisions"
    - id: "openai/gpt-5.4"
      reason: "Strong product sense for identifying what to cut and what to keep"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable reasoning for prioritization decisions"
triggers: ["scope too large", "cut scope", "MVP definition", "reduce scope", "what can we cut"]
input_artifacts: ["prd", "task_breakdown", "budget_report"]
output_artifacts: ["scope_negotiation_result"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Scope Negotiation

## Instructions

1. **Assess the constraint** — is it budget, timeline, or team capacity?
2. **Categorize every feature** in the PRD:
   - **P0 (Must Ship):** Core value proposition. Without these, the product is meaningless.
   - **P1 (Should Ship):** Important for adoption but not existential.
   - **P2 (Can Wait):** Nice to have, defer to v2.
3. **Calculate effort** for each priority tier:
   - Total P0 effort vs. available capacity
   - If P0 alone exceeds capacity, escalate to CEO — the idea itself may need rethinking
4. **Propose a cut plan** with clear tradeoffs:
   - What gets cut and what's the user impact
   - What gets deferred and when it could return
   - Revised timeline and budget
5. **Present to CPO/CEO for approval** — this is always a human decision

## Output Format

```yaml
artifact_type: scope_negotiation_result
constraint: "budget|timeline|capacity"
constraint_detail: "Budget limited to $50, current estimate is $95"
original_scope:
  total_features: 15
  total_effort_weeks: 12
  total_estimated_cost: "$95"
proposed_scope:
  p0_must_ship:
    features: ["Auth system", "Core dashboard", "API endpoints"]
    effort_weeks: 5
    estimated_cost: "$35"
  p1_should_ship:
    features: ["Email notifications", "Export to CSV"]
    effort_weeks: 3
    estimated_cost: "$25"
    recommendation: "Include if budget allows after P0 completion"
  p2_deferred:
    features: ["Admin panel", "Analytics", "Mobile app"]
    effort_weeks: 4
    estimated_cost: "$35"
    recommendation: "Defer to v2"
revised_timeline: "5-6 weeks (P0 only) or 8 weeks (P0+P1)"
revised_cost: "$35 (P0) or $60 (P0+P1)"
tradeoffs:
  - cut: "Admin panel"
    user_impact: "Manual database queries for admin tasks — acceptable for v1"
  - cut: "Analytics"
    user_impact: "No usage insights — can use third-party analytics temporarily"
requires_ceo_approval: true
```
