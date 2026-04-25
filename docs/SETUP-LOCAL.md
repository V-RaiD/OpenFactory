# Setup Guide: Local Rack

**Target reader:** Claude Haiku 4.5 (or any LLM building the factory)
**Target machine:** Home server with Ubuntu 24.04, NVIDIA GPU, 64GB+ RAM
**Time:** ~30 minutes (plus 15-30 min for model downloads)

---

## Prerequisites Checklist

Before starting, verify:
- [ ] Ubuntu 22.04+ or Debian 12+ (Ubuntu 24.04 recommended)
- [ ] NVIDIA GPU with drivers installed (`nvidia-smi` works)
- [ ] 64GB+ RAM (for LLM model offloading)
- [ ] 500GB+ free disk space (LLM models are 30-60GB each)
- [ ] Internet access (for Docker images and API calls)

---

## Step-by-Step

### One-Click Setup

```bash
# 1. Copy factory folder to the server
cp -r factory/ /opt/factory/
cd /opt/factory

# 2. Edit config
nano factory.conf
# Set: FACTORY_TARGET=local
# Set: HAS_GPU=true (or false if no NVIDIA GPU)
# Set: All API keys (ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.)
# Set: TELEGRAM_BOT_TOKEN and TELEGRAM_CEO_CHAT_ID

# 3. Run one-click setup
bash setup.sh
```

Done. The script validates your system, installs Docker, NVIDIA toolkit, Node.js, OpenClaw, generates .env, starts Docker Compose, and pulls Ollama models.

### Option B: Manual Step-by-Step

#### 1. Install Docker
```bash
curl -fsSL https://get.docker.com | sh
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in for group change
```

#### 2. Install NVIDIA Container Toolkit
```bash
# Verify GPU driver
nvidia-smi

# Install toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.3.1-base-ubuntu22.04 nvidia-smi
```

#### 3. Install Node.js 24 + OpenClaw
```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo bash -
sudo apt-get install -y nodejs
npm install -g openclaw
```

#### 4. Configure Environment
```bash
cd /opt/factory
cp .env.example .env
nano .env
# Fill in all API keys, Telegram tokens, etc.
# Generate secrets:
#   GATEWAY_TOKEN=$(openssl rand -hex 32)
#   POSTGRES_PASSWORD=$(openssl rand -hex 16)
```

#### 5. Start the Factory
```bash
docker compose -f infrastructure/docker-compose.local-rack.yml up -d
```

#### 6. Pull Local LLM Models
```bash
# Wait 30 seconds for Ollama to start, then:
docker exec factory-ollama ollama pull qwen2.5-coder:32b    # ~20GB, for coding agents
docker exec factory-ollama ollama pull gemma3:27b             # ~16GB, for content agents

# Verify
docker exec factory-ollama ollama list
```

#### 7. Create Telegram Bot
1. Open Telegram → search @BotFather → send `/newbot`
2. Name: `Factory CEO Bot`, Username: `factory_ceo_bot`
3. Copy token → put in .env as `TELEGRAM_BOT_TOKEN`
4. Message the bot, then get your chat ID:
   ```bash
   curl -s "https://api.telegram.org/bot<TOKEN>/getUpdates" | jq '.result[0].message.chat.id'
   ```
5. Put chat ID in .env as `TELEGRAM_CEO_CHAT_ID`
6. Restart gateway: `docker compose -f infrastructure/docker-compose.local-rack.yml restart openclaw-gateway`

#### 8. Verify Everything
```bash
# All containers running?
docker compose -f infrastructure/docker-compose.local-rack.yml ps

# OpenClaw responding?
curl http://localhost:18789/health

# Ollama responding?
curl http://localhost:11434/api/tags

# GPU being used by Ollama?
nvidia-smi  # Should show ollama process
```

---

## What's Running After Setup

| Service | URL | Container | Purpose |
|---|---|---|---|
| Factory Portal | http://localhost:18789 | factory-gateway | OpenClaw dashboard, agent chat |
| Ollama | http://localhost:11434 | factory-ollama | Local LLM inference (GPU) |
| Coolify | http://localhost:8000 | factory-coolify | Product deployment dashboard |
| Dockge | http://localhost:5001 | factory-portainer | Container management |
| PostgreSQL | localhost:5432 | factory-postgres | Database for products |
| Valkey | localhost:6379 | factory-valkey | Factory state |
| Sandbox | — | factory-sandbox | Agent code execution (DinD) |

---

## First Run Test

Send a message to your Telegram bot:
```
Build a simple todo app. HTML + CSS + JavaScript only. No framework. Deploy to my local rack.
```

You should see:
1. Gate 1 approval request on Telegram within 30-60 seconds
2. Tap Approve
3. Pipeline progresses through all 6 phases
4. Final product deployed via Coolify at http://localhost:3000 (or whatever port Coolify assigns)
