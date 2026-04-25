# Bootstrap Guide: Autonomous AI Software Factory

**Purpose:** Everything an LLM (Haiku or any model) needs to set up and run the factory.
**One-click:** Edit `factory.conf` → run `bash setup.sh` → done.

---

## What This Is

An autonomous software factory on OpenClaw. A human CEO gives an idea (via Telegram or the web portal), and 14 AI agents organized as a company build, test, deploy, market, and maintain it — with the CEO approving at 6 gates.

---

## Quick Start (3 commands)

```bash
cd /path/to/factory
nano factory.conf          # Set FACTORY_TARGET, API keys, Telegram token
bash setup.sh              # Validates system, installs everything, starts factory
```

---

## Two Deployment Options

| | Local Rack | Cloud VPS |
|---|---|---|
| **Config** | `FACTORY_TARGET=local` | `FACTORY_TARGET=aws\|azure\|gcp\|hetzner\|digitalocean` |
| **Compose file** | `infrastructure/docker-compose.local-rack.yml` | `infrastructure/docker-compose.cloud.yml` |
| **Local LLMs** | Yes (Ollama on GPU, $0/token) | No (all API calls) |
| **Product deploy** | Coolify on rack | Decided at design time |
| **Access** | `http://localhost:18789` | `https://factory.yourdomain.com` |
| **Cost** | Electricity + API for L5+ | $7-140/mo + API for all |

---

## Agent Roster (14 agents, L3-L8)

| Agent | Level | Primary Model | Department |
|---|---|---|---|
| orchestrator | L8 | Opus 4.6 | Executive — pipeline execution, CEO comms |
| cpo | L7 | Opus 4.6 | Executive — product strategy, PRD/GTM review |
| cto | L7 | Opus 4.6 | Executive — technical strategy, architecture |
| tech-lead | L6 | Sonnet 4.6 | Engineering — code review, resource allocation |
| product-manager | L6 | Sonnet 4.6 | Product — PRDs, backlog, user research |
| marketing-lead | L6 | Sonnet 4.6 | Marketing — campaigns, SEO |
| sales-lead | L6 | Sonnet 4.6 | Sales — competitive analysis, pricing, pitch |
| senior-dev | L5 | Sonnet 4.6 | Engineering — code, review, debug, API design |
| ux-designer | L5 | Sonnet 4.6 | Product — user flows, wireframes |
| junior-dev | L3 | Haiku 4.5 | Engineering — simple tasks, tests |
| qa-engineer | L4 | Haiku 4.5 | QA — test plans, execution, bugs |
| devops-engineer | L4 | Haiku 4.5 | DevOps — deploy, CI/CD, monitoring |
| content-specialist | L4 | Haiku 4.5 | Marketing — blogs, social, emails |
| sales-dev-rep | L3 | Haiku 4.5 | Sales — cold outreach |

Each skill specifies 3 LLMs ranked by quality: 2 frontier + 1 open-source.

---

## Directory Structure

```
factory/
├── factory.conf                       # One config file for setup
├── setup.sh                           # One-click setup (reads factory.conf)
├── validate.sh                        # Pre-flight system checks
├── .env.example                       # Environment template (setup.sh generates .env)
├── .gitignore                         # Excludes workspaces/, .env, secrets
├── openclaw.json                      # 14 agents, models (API + Ollama), bindings
├── SOUL.md                            # Base identity (7 principles)
├── AGENTS.md                          # Operating manual (8 sections, 3 HITL modes)
│
├── infrastructure/
│   ├── docker-compose.local-rack.yml  # Local: OpenClaw + Ollama + Coolify + Valkey + Postgres
│   ├── docker-compose.cloud.yml       # Cloud: OpenClaw + Caddy + Mission Control + Valkey
│   └── Caddyfile.cloud                # HTTPS reverse proxy (cloud only)
│
├── roles/
│   ├── level_matrix.yaml              # L3-L8 definitions, models, budgets, permissions
│   ├── org_chart.yaml                 # 14 agents, directed communication graph
│   └── permissions.yaml               # Hierarchical RBAC
│
├── skills/                            # 30 skills across 9 categories
│   ├── engineering/ (5)               # code-gen, review, debug, test, api-design
│   ├── product/ (3)                   # prd, user-research, backlog
│   ├── architecture/ (2)             # system-design, tech-stack
│   ├── qa/ (2)                        # test-plan, test-execution
│   ├── devops/ (3)                    # deployment, monitoring, ci-cd
│   ├── management/ (6)               # disputes, resources, budget, scope, product-lifecycle, product-registry
│   ├── marketing/ (4)                # campaign, content, seo, email
│   ├── sales/ (4)                     # outreach, pitch, competitive, pricing
│   └── platform/ (1)                 # observability contract
│
├── pipelines/                         # 7 Lobster workflows
│   ├── idea-to-launch.lobster         # Main: 6 phases, 6 CEO gates
│   ├── feature-development.lobster    # Per-task dev loop
│   ├── gtm-campaign.lobster           # Marketing + Sales
│   ├── code-review-loop.lobster       # Reusable review cycle
│   ├── bug-fix.lobster                # Quick fix pipeline
│   ├── product-iteration.lobster      # Add features to existing products
│   └── product-maintain.lobster       # Pull-based health monitoring + maintenance
│
├── templates/ (5)                     # PRD, system-design, ADR, campaign-brief, pitch-deck
│
├── docs/
│   ├── TECHNOLOGY-MAP.md              # Every technology, why, cost comparison
│   ├── SYSTEM-REQUIREMENTS.md         # Hardware/software specs, RAM/storage breakdowns
│   ├── PLATFORM-STANDARDS.md          # Product health contract (APIs products must expose)
│   ├── SETUP-LOCAL.md                 # Detailed local rack setup guide
│   └── SETUP-CLOUD.md                # Detailed cloud setup guide (all 5 providers)
│
└── workspaces/ (14 dirs)             # Agent workspaces (gitignored, created at runtime)
```

---

## Pipeline Reference

### Build Pipeline: `idea-to-launch.lobster`
```
Idea → Market Research → [Gate 1] → PRD → [Gate 2] → Architecture → [Gate 3]
  → Development (parallel) → QA → [Gate 4] → GTM + Staging → [Gate 5]
  → Production Deploy → Launch → [Gate 6: Post-Launch Review]
```

### Lifecycle Pipelines (post-launch)
- `product-iteration.lobster` — Add features, update GTM, bump version, update registry
- `product-maintain.lobster` — Pull health from `/status` APIs, triage issues, update registry
- `bug-fix.lobster` — Triage, reproduce, fix, verify, deploy

### Factory ↔ Product Monitoring (pull-based, decoupled)
Products expose `/health`, `/health/ready`, `/status` APIs. Factory polls them every 15 min.
Products push P0 incidents to factory's Telegram channel. See `docs/PLATFORM-STANDARDS.md`.

---

## Setup Details

### What `setup.sh` Does

1. Reads `factory.conf`
2. Runs `validate.sh` (checks CPU, RAM, GPU, disk, Docker, Node, API keys)
3. Installs missing software (Docker, Node 24, OpenClaw)
4. Installs NVIDIA Container Toolkit (local rack with GPU only)
5. Generates `.env` from factory.conf values + random secrets
6. For cloud: provisions VM, copies files via rsync, runs remote setup
7. Starts Docker Compose (local or cloud compose file)
8. Pulls Ollama models (local rack with GPU only)
9. Prints access URLs

### What `validate.sh` Checks

| Check | Local Minimum | Cloud Minimum |
|---|---|---|
| CPU | 4 cores | 2 cores |
| RAM | 32 GB | 4 GB |
| Storage | 256 GB free | 50 GB free |
| GPU (if HAS_GPU=true) | NVIDIA with 12GB+ VRAM | N/A |
| Docker | 24.0+ | 24.0+ |
| Node.js | 24.0+ | 24.0+ |
| Internet | Connected | Connected |
| ANTHROPIC_API_KEY | Set | Set |
| TELEGRAM_BOT_TOKEN | Set | Set |

---

## Technology Stack (all open source)

| Technology | License | Purpose |
|---|---|---|
| OpenClaw | Open source | Agent orchestration |
| Lobster | Ships with OpenClaw | YAML workflow engine |
| Node.js 24 | MIT | Runtime |
| Docker + Compose | Apache 2.0 | Containers |
| Valkey 8 | BSD-3 (Linux Foundation) | State, sessions (Redis fork) |
| Ollama | MIT | Local LLM inference |
| Coolify | Apache 2.0 | Self-hosted PaaS (local rack) |
| Dockge | MIT | Docker Compose manager |
| PostgreSQL 16 | PostgreSQL License | Database for products |
| Caddy | Apache 2.0 | Reverse proxy (cloud only) |
| Gitea | MIT | Git hosting + bug tracking |
