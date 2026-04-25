---
name: "ci-cd"
description: "Create and maintain CI/CD pipelines for automated build, test, and deployment"
version: "1.0.0"
category: "devops"
min_level: "L4"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Most reliable GitHub Actions and pipeline YAML generation"
    - id: "openai/gpt-5.4"
      reason: "Strong CI/CD knowledge across platforms (Actions, GitLab CI, CircleCI)"
    - id: "deepseek/deepseek-v3"
      reason: "Capable at standard CI/CD pipeline generation"
triggers: ["CI/CD", "pipeline", "GitHub Actions", "continuous integration", "continuous deployment"]
input_artifacts: ["code_artifact", "deployment_config"]
output_artifacts: ["ci_cd_config"]
allowed_commands: ["cat", "ls", "rg", "git log"]
blocked_commands: ["rm", "sudo", "git push --force"]
max_iterations: 3
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: ["git"]
---

# Skill: CI/CD Pipeline

## Instructions

1. **Identify build/test/deploy steps** from the project structure and deployment config
2. **Generate GitHub Actions workflows:**
   - `ci.yml` — runs on every PR: lint, type check, unit tests, build
   - `cd-staging.yml` — runs on merge to main: build, test, deploy to staging
   - `cd-production.yml` — runs on release tag: deploy to production with approval gate
3. **Include caching** — node_modules, pip cache, Docker layer cache
4. **Include security scanning** — dependency audit, SAST
5. **Set up branch protection rules** — require CI pass before merge

## Output Format

```yaml
artifact_type: ci_cd_config
files:
  - path: ".github/workflows/ci.yml"
    content: |
      # CI workflow
  - path: ".github/workflows/cd-staging.yml"
    content: |
      # staging deployment
  - path: ".github/workflows/cd-production.yml"
    content: |
      # production deployment with approval
stages: ["lint", "typecheck", "test", "build", "deploy-staging", "deploy-production"]
estimated_ci_duration_minutes: 8
caching_strategy: "node_modules + docker layers"
```
