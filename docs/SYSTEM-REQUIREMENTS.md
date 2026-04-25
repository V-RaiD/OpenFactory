# System Requirements — Local Rack & Cloud

This document defines the minimum and recommended hardware/software for running the factory AND the products it builds. The setup script validates these before proceeding.

---

## Local Rack

The local rack runs the factory, Ollama (local LLMs), Coolify (product deployment), and the deployed products themselves — all on the same machine.

### Hardware

| Component | Minimum | Recommended | What Uses It |
|---|---|---|---|
| **CPU** | 4 cores (Intel i5-12400 / Ryzen 5 5600) | 8+ cores (Ryzen 9 7900X / i9-13900) | OpenClaw orchestration, Docker containers, build processes |
| **RAM** | 32 GB | 64-128 GB | Ollama model loading (biggest consumer), Docker containers, deployed products |
| **GPU** | RTX 3060 12GB (for Ollama) | RTX 4090 24GB | Local LLM inference. Without GPU: Ollama runs on CPU (10x slower) or skip Ollama entirely (API-only) |
| **Storage** | 256 GB NVMe SSD | 2 TB NVMe SSD | Ollama models (30-60GB each), Docker images, product data, PostgreSQL |
| **Network** | 50 Mbps internet | 100+ Mbps | LLM API calls, Docker image pulls, npm/pip package downloads |

### RAM Breakdown (Why 32GB Minimum)

| Service | Idle RAM | Active RAM | Notes |
|---|---|---|---|
| OS + Docker | 1.5 GB | 2 GB | Ubuntu 24.04 + Docker daemon |
| OpenClaw Gateway | 300 MB | 800 MB | Spikes during agent orchestration |
| Valkey | 100 MB | 512 MB | Grows with session/approval state |
| Ollama (no model loaded) | 200 MB | 200 MB | Just the server process |
| Ollama (qwen2.5-coder:32b loaded) | — | 20 GB | Q4 quantization in VRAM + RAM offload |
| Ollama (gemma3:27b loaded) | — | 16 GB | Only one model loaded at a time by default |
| Docker-in-Docker sandbox | 500 MB | 2 GB | Spikes during npm install, cargo build |
| Coolify | 500 MB | 1 GB | PaaS overhead |
| Dockge | 100 MB | 200 MB | Lightweight |
| PostgreSQL | 200 MB | 1 GB | Depends on product data |
| **Per deployed product** | 200 MB | 500 MB-2 GB | Each Next.js/Express app running |
| **Total (factory + 1 model + 2 products)** | — | **~28-30 GB** | Why 32 GB is the minimum |

### Storage Breakdown (Why 256GB Minimum)

| What | Size | Notes |
|---|---|---|
| OS + Docker engine | 10 GB | Base Ubuntu + Docker |
| Docker images (factory stack) | 15 GB | OpenClaw, Valkey, Coolify, Dockge, Postgres, sandbox |
| Ollama model: qwen2.5-coder:32b Q4 | 20 GB | Primary coding model |
| Ollama model: gemma3:27b Q4 | 16 GB | Content/general model |
| Docker build cache | 10 GB | Grows with products built |
| Product code + dependencies | 5-20 GB per product | node_modules, cargo target, etc. |
| PostgreSQL data | 1-50 GB per product | Depends on product scale |
| Headroom | 20% free | Docker needs free space for image layers |
| **Total (2 models + 3 products)** | **~120-180 GB** | Why 256 GB is minimum |

### GPU Requirements for Ollama

| GPU | VRAM | What It Can Run | Inference Speed |
|---|---|---|---|
| **No GPU** | 0 | CPU-only inference (very slow) | 1-3 tok/s |
| RTX 3060 | 12 GB | Small models only (8B-14B params) | 15-25 tok/s |
| RTX 3090 | 24 GB | qwen2.5-coder:32b Q4, gemma3:27b | 15-20 tok/s |
| **RTX 4090** | 24 GB | Same models, faster | **25-40 tok/s** |
| 2x RTX 3090 | 48 GB | Llama 4 Scout Q2_K | 10-15 tok/s |

**No GPU option**: Set `HAS_GPU=false` in factory.conf. Ollama is skipped entirely. All agents use API models (Anthropic/OpenAI). Higher API cost but zero hardware requirement.

### Software

| Software | Minimum Version | Check Command |
|---|---|---|
| Ubuntu / Debian | 22.04 / 12 | `lsb_release -rs` |
| Docker Engine | 24.0 | `docker --version` |
| Docker Compose | V2 | `docker compose version` |
| Node.js | 24.0 | `node --version` |
| NVIDIA Driver (if GPU) | 535+ | `nvidia-smi` |
| NVIDIA Container Toolkit (if GPU) | latest | `nvidia-ctk --version` |
| curl, git, jq | any | `which curl git jq` |

---

## Cloud VPS

Cloud runs the factory only — no Ollama (no GPU on standard VPS). All LLM calls go through APIs. Products can deploy to the same VPS or to external targets (Vercel, Railway, etc.).

### Per Provider — Minimum Specs

| Provider | Instance Type | vCPU | RAM | Storage | Monthly Cost |
|---|---|---|---|---|---|
| **Hetzner** (cheapest) | CX22 | 2 | 4 GB | 40 GB | **$4/mo** |
| **Hetzner** (recommended) | CX32 | 4 | 8 GB | 80 GB | **$7/mo** |
| **DigitalOcean** min | s-2vcpu-4gb | 2 | 4 GB | 80 GB | $24/mo |
| **DigitalOcean** rec | s-4vcpu-8gb | 4 | 8 GB | 160 GB | $48/mo |
| **GCP** min | e2-medium | 2 | 4 GB | 50 GB | ~$25/mo |
| **GCP** rec | e2-standard-4 | 4 | 16 GB | 100 GB | ~$100/mo |
| **AWS** min | t3.medium | 2 | 4 GB | 50 GB | ~$30/mo |
| **AWS** rec | t3.xlarge | 4 | 16 GB | 100 GB | ~$120/mo |
| **Azure** min | Standard_B2ms | 2 | 8 GB | 64 GB | ~$60/mo |
| **Azure** rec | Standard_D4s_v3 | 4 | 16 GB | 100 GB | ~$140/mo |

### Cloud RAM Breakdown (Why 4GB Minimum)

| Service | RAM |
|---|---|
| OS + Docker | 1 GB |
| OpenClaw Gateway | 800 MB |
| Valkey | 200 MB |
| Caddy | 50 MB |
| Mission Control | 300 MB |
| Docker-in-Docker sandbox | 1 GB (during builds) |
| **Total** | **~3.5 GB** (4 GB with headroom) |

If deploying products on the same VPS, add 500MB-2GB per product. Use the "recommended" tier.

### Cloud Software

| Software | Minimum Version | Pre-installed? |
|---|---|---|
| Ubuntu | 24.04 LTS | Yes (use this AMI/image) |
| Docker Engine | 24.0 | No — setup.sh installs |
| Docker Compose V2 | latest | No — ships with Docker |
| Node.js | 24.0 | No — setup.sh installs |
| OpenClaw | latest | No — setup.sh installs |

### Cloud Network Requirements

| Port | Service | Required |
|---|---|---|
| 22 | SSH | Yes (setup + management) |
| 80 | HTTP (Caddy redirect) | Yes |
| 443 | HTTPS (Caddy + TLS) | Yes |

All other ports (Valkey, OpenClaw) are internal only — not exposed to the internet.

---

## Scaling Guide

### When to Upgrade

| Signal | What's Happening | Fix |
|---|---|---|
| Agents timing out | Not enough CPU for concurrent agent work | More CPU cores |
| Ollama slow (< 5 tok/s) | Model too large for VRAM, heavy RAM offload | Better GPU or smaller model quantization |
| Docker builds failing | Out of disk space | More storage, prune old images |
| Products slow/crashing | Not enough RAM for deployed products | More RAM or offload products to separate machine |
| Multiple products running | Single machine at capacity | Add a second node, or move products to Coolify on a separate machine |

### Multi-Node Setup (Advanced)

If one machine isn't enough:

```
Node 1: Factory Brain (8+ cores, 64GB RAM, RTX 4090)
  - OpenClaw, Ollama, Valkey, Sandbox

Node 2: Product Host (4 cores, 16-32GB RAM, no GPU)
  - Coolify, PostgreSQL, deployed products
  - Connected via Docker Swarm or just Docker Compose on each node
```
