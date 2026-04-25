---
name: "deployment"
description: "Generate deployment configurations and execute staging/production deployments"
version: "1.0.0"
category: "devops"
min_level: "L4"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Most reliable infrastructure config generation — fewest syntax errors in Dockerfiles, k8s manifests"
    - id: "openai/gpt-5.4"
      reason: "Strong DevOps knowledge, good at Terraform and cloud-native patterns"
    - id: "deepseek/deepseek-v3"
      reason: "Competent at generating standard deployment configs"
triggers: ["deploy", "deployment", "ship", "release", "push to staging", "push to production"]
input_artifacts: ["code_artifact", "test_report", "system_design"]
output_artifacts: ["deployment_config"]
allowed_commands: ["docker build", "docker compose up", "docker compose down", "docker ps", "kubectl apply", "kubectl get", "kubectl describe", "terraform plan", "terraform validate", "aws sts get-caller-identity", "aws ecs describe-services", "git tag", "cat", "ls"]
blocked_commands: ["terraform destroy", "kubectl delete namespace", "kubectl delete pv", "docker system prune -a", "aws rm", "rm -rf", "sudo"]
max_iterations: 3
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: ["docker"]
---

# Skill: Deployment

## Context Constraints

### Deployment Targets
The CEO chooses the deployment target per project. This skill must support ALL of these:

1. **Local Rack (Coolify)** — Self-hosted on CEO's home server. Deploy via Coolify API or Docker Compose push to the rack's Docker daemon. Products are accessible at `http://rack-hostname:port` or via Tailscale.
2. **Local Rack (Docker Compose)** — Direct Docker Compose deployment to the rack without Coolify. For simpler setups.
3. **Cloud PaaS (Vercel/Railway)** — For frontends (Vercel) and backends (Railway). Deploy via CLI or API.
4. **Cloud IaaS (AWS/GCP)** — For complex products needing Lambda, ECS, S3, RDS. Deploy via Terraform or CloudFormation.
5. **Hybrid** — Frontend on Vercel, backend on the local rack. Or staging on rack, production on cloud.

The deployment target is specified in the system design document's `deployment_strategy` field. Read it before generating configs.

### [L4] DevOps Engineer Bounds
- Deploy to staging only — production requires Tech Lead (L6) approval + CEO gate
- May create/modify: Dockerfiles, docker-compose.yml, GitHub Actions workflows, k8s manifests, Coolify configs
- Must NOT modify production database schemas directly
- Must tag all deployments with semantic versions

### [L6] Production Deployment Bounds (after CEO approval)
- Deploy to production with rollback plan documented
- May modify infrastructure config (Terraform, CloudFormation, Coolify)
- Must ensure zero-downtime deployment strategy

## Instructions

1. **Read the system design** — understand the deployment architecture (containers, serverless, VMs)
2. **Generate deployment artifacts:**
   - Dockerfile (multi-stage build, non-root user, minimal image)
   - docker-compose.yml (for local/staging)
   - Kubernetes manifests (if k8s) or ECS task definitions (if AWS)
   - CI/CD workflow (GitHub Actions)
3. **Include health checks** — readiness and liveness probes
4. **Configure environment variables** — use secrets manager references, never hardcode
5. **Document rollback procedure** — how to revert if deployment fails
6. **Execute deployment** to target environment
7. **Verify** — health check passes, smoke test endpoints respond

## Output Format

```yaml
artifact_type: deployment_config
target_environment: "staging|production"
version: "1.2.3"
files:
  - path: "Dockerfile"
    content: |
      # multi-stage Dockerfile
  - path: "docker-compose.yml"
    content: |
      # compose config
  - path: ".github/workflows/deploy.yml"
    content: |
      # CI/CD workflow
deployment_strategy: "rolling|blue-green|canary"
rollback_procedure: "kubectl rollout undo deployment/app-name"
health_check_url: "/health"
smoke_test_urls: ["/api/v1/status", "/api/v1/users?limit=1"]
environment_variables:
  - name: "DATABASE_URL"
    source: "secrets_manager"
    secret_id: "prod/database/url"
deployment_status: "success|failed"
```
