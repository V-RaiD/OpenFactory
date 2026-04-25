---
name: "prd-writing"
description: "Write comprehensive Product Requirements Documents from CEO ideas"
version: "1.0.0"
category: "product"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best at structured long-form documents with nuance — catches requirements gaps proactively"
    - id: "openai/gpt-5.4"
      reason: "Strong product writing with good understanding of user needs and business context"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable long-form document generation for structured requirements"
triggers: ["write PRD", "product requirements", "spec out feature", "requirements doc", "product spec"]
input_artifacts: ["ceo_idea", "market_research_report"]
output_artifacts: ["product_requirements_document"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "git push"]
max_iterations: 3
token_budget: 200000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: PRD Writing

## Context Constraints

### [L6] Product Manager Bounds
- Write PRDs for features and products within the CEO's stated scope
- Must reference market research when available
- Must define measurable success criteria
- If scope is ambiguous, send clarification request UP to CPO, not directly to CEO
- Escalate to CPO if estimated effort appears to exceed the CEO's implied budget/timeline

## Instructions

1. **Parse the CEO's idea** — extract the core value proposition, target user, and desired outcomes
2. **Reference market research** — incorporate competitive analysis, market size, user pain points
3. **Define user personas** — who are the 2-3 primary users? What are their goals and pain points?
4. **Write user stories** — "As a [persona], I want [action] so that [benefit]"
5. **List functional requirements** — numbered, prioritized P0/P1/P2:
   - **P0 (Must Have):** Without these, the product doesn't ship
   - **P1 (Should Have):** Important but can ship without in v1
   - **P2 (Nice to Have):** Future iterations
6. **Define non-functional requirements** — performance targets, security requirements, scalability needs, accessibility
7. **Set success metrics** — measurable KPIs with target values and measurement method. These MUST be instrumentable — for each metric, specify:
   - What event triggers it (e.g., "user completes onboarding step 3")
   - How it's measured (counter, gauge, histogram)
   - Target value and evaluation period
   - This section directly feeds the observability skill — vague metrics like "improve user experience" are rejected
8. **Define customer success framework** — Per `docs/PLATFORM-STANDARDS.md`, define:
   - **Activation event:** What action = "this user got value" (e.g., "created first invoice")
   - **Engagement signals:** What actions indicate healthy usage
   - **Retention window:** D1/D7/D30 targets
   - **Revenue events:** Trial conversion, upgrade, churn triggers
9. **Explicitly state what's out of scope** — prevent scope creep
9. **Identify dependencies and risks** — what could block or derail delivery
10. **Estimate timeline** — rough T-shirt sizing (weeks), not exact dates

Use the template at `templates/prd.md` for structure.

## Output Format

```yaml
artifact_type: product_requirements_document
id: "PRD-{timestamp}"
title: "Product/Feature Name"
version: "1.0.0"
status: "draft"
author: "product-manager"
sections:
  executive_summary: "2-3 sentence overview"
  problem_statement: "What problem are we solving and for whom"
  personas:
    - name: "Persona Name"
      role: "Their job/context"
      pain_points: ["Pain 1", "Pain 2"]
      goals: ["Goal 1", "Goal 2"]
  user_stories:
    - id: "US-001"
      persona: "Persona Name"
      story: "As a..., I want..., so that..."
      acceptance_criteria: ["AC1", "AC2"]
  functional_requirements:
    - id: "REQ-001"
      description: "Requirement description"
      priority: "P0"
      acceptance_criteria: ["AC1", "AC2"]
  non_functional_requirements:
    performance: "p99 < 500ms"
    security: "SOC2 compliance"
    scalability: "10,000 concurrent users"
    accessibility: "WCAG 2.1 AA"
  success_metrics:
    - metric: "DAU"
      target: "1,000 within 30 days"
      measurement: "Analytics dashboard"
  out_of_scope: ["Feature X", "Platform Y"]
  dependencies: ["External API availability"]
  risks:
    - risk: "Third-party API deprecation"
      probability: "low"
      impact: "high"
      mitigation: "Abstract behind adapter pattern"
  timeline_estimate: "6-8 weeks"
```
