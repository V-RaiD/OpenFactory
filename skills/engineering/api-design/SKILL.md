---
name: "api-design"
description: "Design RESTful or GraphQL API contracts with request/response schemas and error handling"
version: "1.0.0"
category: "engineering"
min_level: "L5"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best API design reasoning — produces consistent, well-structured contracts with edge case handling"
    - id: "openai/gpt-5.4"
      reason: "Strong at generating OpenAPI specs and understanding REST/GraphQL conventions"
    - id: "meta/llama-4-maverick-400b"
      reason: "Large reasoning model handles complex API relationships and versioning well"
triggers: ["design API", "API spec", "endpoint design", "API contract", "OpenAPI"]
input_artifacts: ["prd", "system_design"]
output_artifacts: ["api_specification"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "git push", "curl", "wget"]
max_iterations: 3
token_budget: 100000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: API Design

## Context Constraints

### [L5] Senior API Design Bounds
- Design APIs within your service boundary
- Must follow existing API conventions in the project (REST vs GraphQL, naming, versioning)
- Escalate to Architect if the API requires cross-service coordination

### [L6] Architect API Design Bounds
- Design cross-service APIs and define service boundaries
- Define API versioning strategy
- Make breaking change decisions

## Instructions

1. **Extract API requirements** from the PRD — identify all user actions that need backend endpoints
2. **Review system design** — understand the data models, service boundaries, and authentication strategy
3. **Design endpoints** following REST conventions:
   - Use nouns for resources, not verbs (`/users` not `/getUsers`)
   - Use HTTP methods semantically (GET=read, POST=create, PUT=replace, PATCH=update, DELETE=remove)
   - Use consistent plural nouns (`/users/{id}`, `/orders/{id}/items`)
   - Version the API (`/v1/users`)
4. **Define schemas** for every request and response body using JSON Schema
5. **Design error responses** consistently:
   ```json
   { "error": { "code": "VALIDATION_ERROR", "message": "Human-readable message", "details": [...] } }
   ```
6. **Consider pagination** for list endpoints (cursor-based preferred)
7. **Consider authentication** — which endpoints need auth, what scopes
8. **Output as OpenAPI 3.1 spec**

## Output Format

```yaml
artifact_type: api_specification
task_id: "{referenced task ID}"
format: "openapi-3.1"
spec:
  openapi: "3.1.0"
  info:
    title: "Service Name API"
    version: "1.0.0"
  paths:
    /v1/resource:
      get:
        summary: "List resources"
        parameters: [...]
        responses:
          "200": { description: "Success", content: { ... } }
          "401": { description: "Unauthorized" }
      post:
        summary: "Create resource"
        requestBody: { ... }
        responses:
          "201": { description: "Created" }
          "400": { description: "Validation error" }
  components:
    schemas: { ... }
    securitySchemes: { ... }
authentication_strategy: "Bearer JWT|API Key|OAuth2"
pagination_strategy: "cursor|offset"
rate_limiting: "100 req/min per API key"
```
