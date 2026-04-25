---
name: "tech-stack-evaluation"
description: "Evaluate technology options and produce Architecture Decision Records"
version: "1.0.0"
category: "architecture"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Deepest knowledge of technology tradeoffs, framework maturity, and ecosystem health"
    - id: "google/gemini-3.1-pro"
      reason: "Strong research capability for comparing technologies with current market data"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model methodically evaluates multi-dimensional tradeoffs"
triggers: ["evaluate tech stack", "technology choice", "compare frameworks", "should we use", "ADR"]
input_artifacts: ["prd", "system_design"]
output_artifacts: ["tech_stack_decision"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "curl", "npm install"]
max_iterations: 2
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Tech Stack Evaluation

## Context Constraints

### [L6] Architect Bounds
- Evaluate technologies relevant to the current project scope
- Must present at least 3 options for each decision
- Must quantify tradeoffs (cost, performance, team expertise, ecosystem maturity)
- Produce a formal ADR for each decision

## Instructions

1. **Identify the decision** — what technology choice needs to be made and why
2. **Define evaluation criteria** weighted by project priorities:
   - Performance (latency, throughput, resource usage)
   - Developer experience (learning curve, documentation, tooling)
   - Ecosystem maturity (community size, package ecosystem, LTS status)
   - Cost (licensing, hosting, operational overhead)
   - Scalability (horizontal/vertical, data volume limits)
   - Security (CVE history, auth patterns, compliance certifications)
   - Team expertise (does the team know this already?)
3. **Research 3+ options** — gather concrete data points, not opinions
4. **Score each option** against criteria using a weighted matrix
5. **Recommend** with explicit rationale
6. **Document as ADR** using the template

## Output Format

```yaml
artifact_type: tech_stack_decision
decision_area: "database|framework|language|hosting|auth|messaging"
options_evaluated:
  - name: "PostgreSQL"
    scores: { performance: 8, dx: 7, maturity: 10, cost: 9, scalability: 7, security: 9 }
    pros: ["ACID", "Rich query language", "Excellent tooling"]
    cons: ["Vertical scaling limits", "Schema migrations"]
  - name: "MongoDB"
    scores: { performance: 8, dx: 8, maturity: 8, cost: 8, scalability: 9, security: 7 }
    pros: ["Flexible schema", "Horizontal scaling"]
    cons: ["No ACID across documents", "Query limitations"]
  - name: "CockroachDB"
    scores: { performance: 7, dx: 6, maturity: 6, cost: 5, scalability: 10, security: 8 }
    pros: ["Distributed SQL", "Global replication"]
    cons: ["Cost", "Smaller ecosystem", "Learning curve"]
recommendation: "PostgreSQL"
rationale: "Best balance of maturity, cost, and team expertise for our scale"
adr:
  id: "ADR-001"
  title: "Database selection: PostgreSQL"
  status: "proposed"
  context: "We need a primary database for user data and transactions"
  decision: "Use PostgreSQL 16 with pgvector extension"
  consequences: "Need schema migration tooling, limited horizontal scaling past 10TB"
```
