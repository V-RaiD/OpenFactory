# Technology Map — What Runs Where

This document maps every technology in the factory to its purpose, which deployment target uses it, and why it was chosen.

---

## Common Stack (Both Local Rack and Cloud)

| Technology | Version | Purpose | Why This |
|---|---|---|---|
| **OpenClaw** | latest | Agent orchestration, routing, sessions, skills, Telegram/WhatsApp bindings | User requirement. 360k stars, battle-tested, native multi-agent support |
| **Lobster** | ships with OpenClaw | Deterministic YAML workflow engine with approval gates, loops, sub-pipelines | OpenClaw-native. DAG-like pipelines with HITL |
| **Node.js** | 24 LTS | OpenClaw runtime | OpenClaw requires Node 24+ |
| **Docker** | 27+ | Container runtime for all services | Industry standard, required for sandboxing |
| **Docker Compose** | V2 | Multi-container orchestration | Simple, no Kubernetes needed |
| **Docker-in-Docker** | 27-dind | Sandboxed code execution by agents | Agents run npm test, cargo build, etc. inside containers — never on host |
| **Valkey** | 8 Alpine | Session state, approval tracking, pub/sub between agents | Linux Foundation fork of Redis. Fully open source (BSD-3). Drop-in Redis replacement, same API. Replaced Redis due to SSPL relicensing |
| **SKILL.md files** | — | Agent capability definitions (YAML frontmatter + Markdown) | OpenClaw-native skill format |
| **SOUL.md / AGENTS.md** | — | System prompt composition | OpenClaw-native identity files |
| **Telegram Bot API** | — | Primary CEO communication (approvals, discussions, meetings) | Free, rich inline keyboards, no 24-hour window restriction |

---

## Local Rack Only

| Technology | Version | Purpose | Why This |
|---|---|---|---|
| **Ollama** | latest | Local LLM inference server on GPU | Native OpenClaw integration, one-command setup, serves Llama/Qwen/Gemma at $0/token |
| **NVIDIA Container Toolkit** | latest | GPU passthrough from host to Ollama container | Required for Ollama to use the GPU inside Docker |
| **Coolify** | latest | Self-hosted PaaS — products the factory builds deploy HERE | Self-hosted Vercel alternative. Git-push deploys, web UI at :8000, 280+ one-click services |
| **Dockge** | 1 | Docker Compose stack manager (MIT license) | Simpler than Portainer, purpose-built for Compose stacks. By the Uptime Kuma creator. Web UI at :5001 |
| **PostgreSQL** | 16 Alpine | Shared database for products the factory builds | Standard relational DB. Each product gets its own database |
| **qwen2.5-coder:32b** | GGUF Q4 | Local LLM for L3-L4 coding agents | Best open-source coding model that fits in 24GB VRAM |
| **gemma3:27b** | GGUF Q4 | Local LLM for L3-L4 content/marketing agents | Good general-purpose model that fits in 24GB VRAM |

### Local Rack Ports

| Port | Service | Access |
|---|---|---|
| 18789 | OpenClaw Gateway (factory portal) | http://localhost:18789 |
| 11434 | Ollama (local LLM API) | http://localhost:11434 |
| 8000 | Coolify (product deployment dashboard) | http://localhost:8000 |
| 5001 | Dockge (Docker Compose manager) | http://localhost:5001 |
| 5432 | PostgreSQL | localhost:5432 |
| 6379 | Redis | localhost:6379 |

### Local Rack Minimum Hardware

| Component | Minimum | Recommended |
|---|---|---|
| CPU | 4 cores (Intel i5 / Ryzen 5) | 8+ cores (Ryzen 9 / i9) |
| RAM | 32 GB | 64-128 GB (for LLM offloading) |
| GPU | RTX 3090 (24GB VRAM) | RTX 4090 (24GB VRAM, faster) |
| Storage | 500GB NVMe | 2TB NVMe (models are 30-60GB each) |
| OS | Ubuntu 22.04+ / Debian 12+ | Ubuntu 24.04 LTS |

---

## Cloud Only

| Technology | Version | Purpose | Why This |
|---|---|---|---|
| **Caddy** | 2 Alpine | Reverse proxy with automatic TLS via Let's Encrypt | Zero-config HTTPS, simpler than Nginx/Traefik |
| **Mission Control** | latest | CEO web dashboard (agent activity, approvals, pipeline state) | OpenClaw community project, connects to gateway |

### Cloud — No Ollama

Standard cloud VMs don't have GPUs. All LLM calls go through APIs (Anthropic, OpenAI, etc.). If you want local inference on cloud, use a GPU instance:
- AWS: `p3.2xlarge` (V100, ~$3/hr) or `g5.xlarge` (A10G, ~$1/hr)
- Azure: `Standard_NC6s_v3` (V100) or `Standard_NC4as_T4_v3` (T4)
- GCP: `n1-standard-4` + `nvidia-tesla-t4`
- Lambda Labs: `gpu_1x_a10` ($0.75/hr)

---

## Per Cloud Provider

### AWS EC2

| Resource | Configuration | Monthly Cost |
|---|---|---|
| EC2 Instance | t3.xlarge (4 vCPU, 16GB RAM) | ~$120/mo |
| EBS Volume | 100GB gp3 | ~$8/mo |
| Security Group | Ports 22, 80, 443 inbound | Free |
| Elastic IP | Static IP for DNS | ~$3.65/mo |
| **Total** | | **~$132/mo** |

**Cheaper alternative:** t3.medium (2 vCPU, 4GB) at ~$30/mo works for light usage.

| Technology | Detail |
|---|---|
| AMI | Ubuntu 24.04 LTS (ami-0c7217cdde317cfec for us-east-1) |
| CLI | `aws` (AWS CLI v2) |
| Provisioning | setup.sh auto-creates security group + instance |
| SSH user | `ubuntu` |

### Azure VM

| Resource | Configuration | Monthly Cost |
|---|---|---|
| VM | Standard_D4s_v3 (4 vCPU, 16GB RAM) | ~$140/mo |
| OS Disk | 100GB Premium SSD | ~$15/mo |
| Public IP | Standard SKU | ~$3.65/mo |
| NSG | Ports 22, 80, 443 | Free |
| **Total** | | **~$159/mo** |

**Cheaper alternative:** Standard_B2ms (2 vCPU, 8GB) at ~$60/mo.

| Technology | Detail |
|---|---|
| Image | Canonical Ubuntu 24.04 LTS |
| CLI | `az` (Azure CLI) |
| Provisioning | setup.sh auto-creates resource group + VM + NSG |
| SSH user | `azureuser` |

### GCP Compute Engine

| Resource | Configuration | Monthly Cost |
|---|---|---|
| VM | e2-standard-4 (4 vCPU, 16GB RAM) | ~$100/mo |
| Boot Disk | 100GB SSD | ~$17/mo |
| External IP | Ephemeral (free) or Static ($3/mo) | ~$3/mo |
| Firewall | Ports 80, 443 | Free |
| **Total** | | **~$120/mo** |

**Cheaper alternative:** e2-medium (2 vCPU, 4GB) at ~$25/mo.

| Technology | Detail |
|---|---|
| Image | ubuntu-2404-lts-amd64 |
| CLI | `gcloud` (Google Cloud SDK) |
| Provisioning | setup.sh auto-creates instance + firewall rules |
| SSH user | Your local username |

### Hetzner Cloud (CHEAPEST)

| Resource | Configuration | Monthly Cost |
|---|---|---|
| Server | CX32 (4 vCPU, 8GB RAM) | **~$7/mo** |
| Storage | 80GB SSD (included) | Included |
| Public IP | Included | Included |
| Firewall | Ports 80, 443 | Free |
| **Total** | | **~$7/mo** |

| Technology | Detail |
|---|---|
| Image | Ubuntu 24.04 |
| CLI | HTTP API (via curl in setup.sh) |
| Provisioning | setup.sh auto-creates server via API |
| SSH user | `root` |

### DigitalOcean

| Resource | Configuration | Monthly Cost |
|---|---|---|
| Droplet | s-4vcpu-8gb | ~$48/mo |
| Volume | 100GB (if needed) | ~$10/mo |
| **Total** | | **~$48/mo** |

**Cheaper alternative:** s-2vcpu-4gb at ~$24/mo.

| Technology | Detail |
|---|---|
| Image | Ubuntu 24.04 x64 |
| CLI | HTTP API (via curl in setup.sh) |
| Provisioning | setup.sh auto-creates droplet via API |
| SSH user | `root` |

---

## Cost Comparison Summary

| Option | Infra Cost | LLM Cost (typical project) | Total |
|---|---|---|---|
| **Local Rack** | $0/mo (electricity only) | $5-50 per project (L5+ API only, L3-L4 free via Ollama) | **$5-50/project** |
| **Hetzner** | $7/mo | $15-100 per project (all API) | **$22-107/project** |
| **DigitalOcean** | $24-48/mo | $15-100 per project | **$39-148/project** |
| **GCP** | $25-120/mo | $15-100 per project | **$40-220/project** |
| **AWS** | $30-132/mo | $15-100 per project | **$45-232/project** |
| **Azure** | $60-159/mo | $15-100 per project | **$75-259/project** |
