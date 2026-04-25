---
name: "system-design"
description: "Create comprehensive system architecture documents from product requirements"
version: "1.0.0"
category: "architecture"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best architectural reasoning — handles complex tradeoffs, produces coherent multi-component designs"
    - id: "openai/gpt-5.4"
      reason: "Strong system design with good distributed systems knowledge"
    - id: "deepseek/deepseek-r1"
      reason: "Deep reasoning model excels at evaluating architectural tradeoffs methodically"
triggers: ["design system", "architect", "system architecture", "technical design", "design doc"]
input_artifacts: ["prd"]
output_artifacts: ["system_design_document", "task_breakdown"]
allowed_commands: ["cat", "ls", "rg", "git log"]
blocked_commands: ["rm", "git push", "sudo", "curl"]
max_iterations: 3
token_budget: 250000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: System Design

## Context Constraints

### [L6] Tech Lead / Architect Bounds
- Design systems within the scope of the PRD
- Must produce: architecture overview, component diagram, data models, API contracts, tech stack, task breakdown
- Must evaluate at least 2 alternative approaches before recommending one
- Must document decisions as ADRs (Architecture Decision Records)
- Escalate to CTO if the design requires new infrastructure or exceeds $50 estimated monthly cost

## Instructions

### Step 0: Architecture Mode Decision (CRITICAL)

Before designing anything, decide the deployment architecture. This is a Gate 3 (Live Meeting) decision:

- **Monolith** — Single codebase, single deployment. Best for: MVPs, simple products, tight timelines. One repo, one pipeline.
- **Modular Monolith** — Single codebase with strict module boundaries. Best for: medium products that may need to scale later. One repo, modules can be extracted into services.
- **Multi-Service** — Multiple codebases, independent deployments. Best for: complex products with distinct scaling needs, multiple teams, or different tech stacks per component.

**Decision criteria:**
- Under 20 requirements and 1 deployment target → Monolith
- 20-50 requirements with potential scale needs → Modular Monolith
- 50+ requirements, multiple scaling profiles, or CEO requests services → Multi-Service

For Multi-Service, produce a **Service Map** that defines each service, its repo, tech stack, deployment target, and inter-service connections. Each service gets its own feature-development.lobster pipeline run.

### Step 1: PRD Analysis
Read the PRD thoroughly — extract every functional and non-functional requirement.

### Step 2: System Boundaries
Identify what's in scope, what's external (third-party APIs, existing services, SaaS dependencies).

### Step 3: Architecture Design

**For Monolith/Modular Monolith:**
- Break into components/modules with clear responsibilities
- Define module interfaces (function calls, internal APIs)
- Draw a component diagram (Mermaid syntax)

**For Multi-Service:**
- Define each service: name, responsibility, tech stack, repo, deploy target
- Define inter-service communication: REST, gRPC, message queue, event bus
- Define shared infrastructure: database per service vs shared, cache, CDN
- Draw a service architecture diagram (Mermaid syntax)
- Define API gateway / routing layer
- Plan for: service discovery, health checks, circuit breakers, distributed tracing

### Step 4: Data Models
- Define all entities, attributes, relationships
- Choose storage per service (SQL, NoSQL, cache, file storage, vector DB)
- Plan data migration strategy
- For multi-service: define data ownership boundaries (which service owns which entity)

### Step 5: API Contracts
- Every endpoint: request/response schema, auth requirements
- For multi-service: both external (user-facing) and internal (service-to-service) APIs
- Use OpenAPI 3.1 format

### Step 6: Technology Stack
- Evaluate at least 2 options for each major decision
- Document each choice as an ADR
- For multi-service: each service can have its own tech stack if justified

### Step 7: Sequence Diagrams
- 3-5 most important user flows (Mermaid syntax)
- For multi-service: show cross-service calls, async flows, queue processing

### Step 8: Task Breakdown
- Each task completable by a single developer in 1-3 days
- Define dependencies (which must complete before others start)
- Estimate complexity (S/M/L/XL)
- **For multi-service: group tasks by service, identify cross-service integration tasks**
- Mark which tasks can run in parallel across different agent teams

### Step 9: Deployment Strategy
- For monolith: single Dockerfile, single deploy target
- For multi-service: per-service Dockerfiles, independent CI/CD, staged rollout order
- Define infrastructure provisioning needs (databases, queues, CDN, DNS)

### Step 10: Risk Assessment
- What could go wrong, what's the mitigation
- For multi-service: distributed system risks (network partitions, eventual consistency, cascading failures)

## Output Format

Use the template at `templates/system-design.md`. The output must include:

```yaml
artifact_type: system_design_document
prd_id: "{referenced PRD ID}"
components:
  - name: "component-name"
    responsibility: "What this component does"
    technology: "language/framework"
    interfaces:
      - type: "REST API|gRPC|message queue|direct"
        connects_to: "other-component"
data_models:
  - entity: "User"
    storage: "PostgreSQL"
    fields: [{ name: "id", type: "uuid", constraints: "PK" }]
tech_stack:
  language: "TypeScript"
  framework: "Next.js"
  database: "PostgreSQL"
  cache: "Redis"
  hosting: "AWS ECS"
  ci_cd: "GitHub Actions"
task_breakdown:
  - id: "TASK-001"
    title: "Setup project scaffold"
    description: "Initialize Next.js project with TypeScript, ESLint, Prettier"
    complexity: "S"
    depends_on: []
    assignee_level: "L3"
  - id: "TASK-002"
    title: "Implement User data model"
    depends_on: ["TASK-001"]
    complexity: "M"
    assignee_level: "L4"
risks:
  - risk: "Third-party API rate limits"
    probability: "medium"
    impact: "high"
    mitigation: "Implement caching + exponential backoff"
adrs:
  - id: "ADR-001"
    title: "Use PostgreSQL over MongoDB"
    decision: "PostgreSQL"
    reason: "Relational data with complex queries, ACID compliance needed"
```
