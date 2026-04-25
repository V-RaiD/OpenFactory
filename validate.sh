#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Factory System Validation
#
# Checks that the current machine meets minimum requirements.
# Called automatically by setup.sh, or run standalone:
#   bash validate.sh [local|cloud]
#
# Exit codes:
#   0 = all checks passed
#   1 = critical failure (cannot proceed)
#   2 = warnings (can proceed but not optimal)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

TARGET="${1:-local}"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass()  { echo -e "  ${GREEN}PASS${NC}  $1"; }
fail()  { echo -e "  ${RED}FAIL${NC}  $1"; ERRORS=$((ERRORS+1)); }
warn()  { echo -e "  ${YELLOW}WARN${NC}  $1"; WARNINGS=$((WARNINGS+1)); }
info()  { echo -e "  ----  $1"; }

echo "══════════════════════════════════════════════════════"
echo "  Factory System Validation (target: $TARGET)"
echo "══════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════
# OS CHECK
# ═══════════════════════════════════════════════════════════
echo "── Operating System ──────────────────────────────────"

OS="$(uname -s)"
case "$OS" in
    Linux)
        pass "Linux detected"
        # Check distro
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            info "Distro: $PRETTY_NAME"
            case "$ID" in
                ubuntu|debian|pop|linuxmint)
                    pass "Supported distro: $ID"
                    ;;
                fedora|centos|rhel|rocky|alma)
                    warn "Distro $ID is supported but Ubuntu/Debian is recommended"
                    ;;
                *)
                    warn "Untested distro: $ID — may work but not guaranteed"
                    ;;
            esac
        fi
        ;;
    Darwin)
        if [ "$TARGET" = "local" ]; then
            warn "macOS detected. Docker Desktop required (not Docker Engine). GPU passthrough not available — Ollama runs on CPU only."
        else
            pass "macOS detected (running setup.sh to provision remote server)"
        fi
        ;;
    *)
        fail "Unsupported OS: $OS"
        ;;
esac
echo ""

# ═══════════════════════════════════════════════════════════
# CPU CHECK
# ═══════════════════════════════════════════════════════════
echo "── CPU ────────────────────────────────────────────────"

if [ "$OS" = "Linux" ]; then
    CPU_CORES=$(nproc)
    CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
elif [ "$OS" = "Darwin" ]; then
    CPU_CORES=$(sysctl -n hw.ncpu)
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
fi

info "CPU: $CPU_MODEL"
info "Cores: $CPU_CORES"

if [ "$TARGET" = "local" ]; then
    if [ "$CPU_CORES" -ge 8 ]; then
        pass "CPU cores: $CPU_CORES (recommended: 8+)"
    elif [ "$CPU_CORES" -ge 4 ]; then
        warn "CPU cores: $CPU_CORES (minimum met, recommended: 8+)"
    else
        fail "CPU cores: $CPU_CORES (minimum: 4, you have $CPU_CORES)"
    fi
else
    if [ "$CPU_CORES" -ge 2 ]; then
        pass "CPU cores: $CPU_CORES (sufficient for running setup.sh)"
    fi
fi
echo ""

# ═══════════════════════════════════════════════════════════
# RAM CHECK
# ═══════════════════════════════════════════════════════════
echo "── Memory ─────────────────────────────────────────────"

if [ "$OS" = "Linux" ]; then
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
    AVAIL_RAM_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    AVAIL_RAM_GB=$((AVAIL_RAM_KB / 1024 / 1024))
elif [ "$OS" = "Darwin" ]; then
    TOTAL_RAM_BYTES=$(sysctl -n hw.memsize)
    TOTAL_RAM_GB=$((TOTAL_RAM_BYTES / 1024 / 1024 / 1024))
    AVAIL_RAM_GB=$TOTAL_RAM_GB  # macOS doesn't report available easily
fi

info "Total RAM: ${TOTAL_RAM_GB} GB"

if [ "$TARGET" = "local" ]; then
    if [ "$TOTAL_RAM_GB" -ge 64 ]; then
        pass "RAM: ${TOTAL_RAM_GB} GB (recommended: 64+ GB)"
    elif [ "$TOTAL_RAM_GB" -ge 32 ]; then
        warn "RAM: ${TOTAL_RAM_GB} GB (minimum met, recommended: 64 GB for comfortable Ollama usage)"
    elif [ "$TOTAL_RAM_GB" -ge 16 ]; then
        warn "RAM: ${TOTAL_RAM_GB} GB (below minimum 32 GB — Ollama will be very slow or unusable. Consider HAS_GPU=false for API-only mode)"
    else
        fail "RAM: ${TOTAL_RAM_GB} GB (minimum: 32 GB for local rack with Ollama)"
    fi
else
    if [ "$TOTAL_RAM_GB" -ge 4 ]; then
        pass "RAM: ${TOTAL_RAM_GB} GB (sufficient for cloud setup)"
    else
        warn "RAM: ${TOTAL_RAM_GB} GB (cloud VPS needs at least 4 GB)"
    fi
fi
echo ""

# ═══════════════════════════════════════════════════════════
# STORAGE CHECK
# ═══════════════════════════════════════════════════════════
echo "── Storage ────────────────────────────────────────────"

if [ "$OS" = "Linux" ]; then
    FREE_DISK_KB=$(df -k / | tail -1 | awk '{print $4}')
    FREE_DISK_GB=$((FREE_DISK_KB / 1024 / 1024))
elif [ "$OS" = "Darwin" ]; then
    FREE_DISK_BLOCKS=$(df -k / | tail -1 | awk '{print $4}')
    FREE_DISK_GB=$((FREE_DISK_BLOCKS / 1024 / 1024))
fi

info "Free disk: ${FREE_DISK_GB} GB"

if [ "$TARGET" = "local" ]; then
    if [ "$FREE_DISK_GB" -ge 500 ]; then
        pass "Storage: ${FREE_DISK_GB} GB free (recommended: 500+ GB)"
    elif [ "$FREE_DISK_GB" -ge 256 ]; then
        warn "Storage: ${FREE_DISK_GB} GB free (minimum met, recommended: 500 GB)"
    elif [ "$FREE_DISK_GB" -ge 100 ]; then
        warn "Storage: ${FREE_DISK_GB} GB free (tight — only room for 1-2 Ollama models + a few products)"
    else
        fail "Storage: ${FREE_DISK_GB} GB free (minimum: 256 GB for local rack)"
    fi
else
    if [ "$FREE_DISK_GB" -ge 50 ]; then
        pass "Storage: ${FREE_DISK_GB} GB free (sufficient)"
    else
        warn "Storage: ${FREE_DISK_GB} GB free (cloud VPS needs 50+ GB)"
    fi
fi
echo ""

# ═══════════════════════════════════════════════════════════
# GPU CHECK (local only)
# ═══════════════════════════════════════════════════════════
if [ "$TARGET" = "local" ]; then
    echo "── GPU ──────────────────────────────────────────────"

    # Source factory.conf if it exists to check HAS_GPU
    HAS_GPU="${HAS_GPU:-true}"
    if [ -f "$(dirname "$0")/factory.conf" ]; then
        HAS_GPU=$(grep -E '^HAS_GPU=' "$(dirname "$0")/factory.conf" | cut -d= -f2 | tr -d ' "' || echo "true")
    fi

    if [ "$HAS_GPU" = "true" ]; then
        if command -v nvidia-smi &> /dev/null; then
            GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
            GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
            GPU_VRAM_GB=$((GPU_VRAM / 1024))
            info "GPU: $GPU_NAME (${GPU_VRAM_GB} GB VRAM)"

            if [ "$GPU_VRAM_GB" -ge 24 ]; then
                pass "GPU VRAM: ${GPU_VRAM_GB} GB (can run 32B parameter models)"
            elif [ "$GPU_VRAM_GB" -ge 12 ]; then
                warn "GPU VRAM: ${GPU_VRAM_GB} GB (limited to 8B-14B models, or heavy RAM offload for larger)"
            else
                warn "GPU VRAM: ${GPU_VRAM_GB} GB (very limited — consider smaller models or API-only)"
            fi

            # Check NVIDIA Container Toolkit
            if command -v nvidia-ctk &> /dev/null; then
                pass "NVIDIA Container Toolkit: installed"
            else
                warn "NVIDIA Container Toolkit: not installed (setup.sh will install it)"
            fi

            # Test Docker GPU access
            if docker run --rm --gpus all nvidia/cuda:12.3.1-base-ubuntu22.04 nvidia-smi &> /dev/null; then
                pass "Docker GPU passthrough: working"
            else
                warn "Docker GPU passthrough: not working (setup.sh will configure it)"
            fi
        else
            fail "HAS_GPU=true but nvidia-smi not found. Install NVIDIA drivers or set HAS_GPU=false."
        fi
    else
        info "HAS_GPU=false — Ollama will be skipped, all agents use API models"
        pass "GPU: not required (API-only mode)"
    fi
    echo ""
fi

# ═══════════════════════════════════════════════════════════
# SOFTWARE CHECKS
# ═══════════════════════════════════════════════════════════
echo "── Required Software ──────────────────────────────────"

# Docker
if command -v docker &> /dev/null; then
    DOCKER_VER=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    DOCKER_MAJOR=$(echo "$DOCKER_VER" | cut -d. -f1)
    if [ "$DOCKER_MAJOR" -ge 24 ]; then
        pass "Docker: $DOCKER_VER"
    else
        warn "Docker: $DOCKER_VER (minimum 24.0, setup.sh will upgrade)"
    fi
else
    info "Docker: not installed (setup.sh will install)"
fi

# Docker Compose
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_VER=$(docker compose version --short 2>/dev/null || echo "v2")
    pass "Docker Compose: $COMPOSE_VER"
else
    info "Docker Compose V2: not installed (setup.sh will install)"
fi

# Node.js
if command -v node &> /dev/null; then
    NODE_VER=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VER" | tr -d 'v' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 24 ]; then
        pass "Node.js: $NODE_VER"
    else
        warn "Node.js: $NODE_VER (minimum v24, setup.sh will upgrade)"
    fi
else
    info "Node.js: not installed (setup.sh will install)"
fi

# OpenClaw
if command -v openclaw &> /dev/null; then
    pass "OpenClaw: installed"
else
    info "OpenClaw: not installed (setup.sh will install)"
fi

# curl, git, jq
for CMD in curl git jq; do
    if command -v "$CMD" &> /dev/null; then
        pass "$CMD: installed"
    else
        info "$CMD: not installed (setup.sh will install)"
    fi
done
echo ""

# ═══════════════════════════════════════════════════════════
# NETWORK CHECK
# ═══════════════════════════════════════════════════════════
echo "── Network ────────────────────────────────────────────"

# Internet connectivity
if curl -s --max-time 5 https://api.anthropic.com > /dev/null 2>&1; then
    pass "Internet: connected (can reach Anthropic API)"
elif curl -s --max-time 5 https://google.com > /dev/null 2>&1; then
    pass "Internet: connected"
else
    fail "Internet: no connection (required for Docker images + LLM API calls)"
fi

# Docker Hub access
if curl -s --max-time 5 https://registry-1.docker.io/v2/ > /dev/null 2>&1; then
    pass "Docker Hub: reachable"
else
    warn "Docker Hub: not reachable (may need proxy or mirror)"
fi
echo ""

# ═══════════════════════════════════════════════════════════
# CONFIG CHECK
# ═══════════════════════════════════════════════════════════
echo "── Configuration ──────────────────────────────────────"

CONF_FILE="$(dirname "$0")/factory.conf"
if [ -f "$CONF_FILE" ]; then
    pass "factory.conf: found"

    # Check critical keys
    source <(grep -v '^\s*#' "$CONF_FILE" | grep -v '^\s*$')

    if [ -n "${ANTHROPIC_API_KEY:-}" ] && [ "$ANTHROPIC_API_KEY" != "sk-ant-api03-your-key-here" ]; then
        pass "ANTHROPIC_API_KEY: configured"
    else
        fail "ANTHROPIC_API_KEY: not set (required — primary LLM provider)"
    fi

    if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ "$TELEGRAM_BOT_TOKEN" != "123456789:ABCdefGhIjKlMnOpQrStUvWxYz" ]; then
        pass "TELEGRAM_BOT_TOKEN: configured"
    else
        fail "TELEGRAM_BOT_TOKEN: not set (required — CEO communication)"
    fi

    if [ -n "${TELEGRAM_CEO_CHAT_ID:-}" ] && [ "$TELEGRAM_CEO_CHAT_ID" != "123456789" ]; then
        pass "TELEGRAM_CEO_CHAT_ID: configured"
    else
        fail "TELEGRAM_CEO_CHAT_ID: not set (required — your Telegram user ID)"
    fi

    if [ -n "${OPENAI_API_KEY:-}" ] && [ "$OPENAI_API_KEY" != "sk-your-key-here" ]; then
        pass "OPENAI_API_KEY: configured"
    else
        warn "OPENAI_API_KEY: not set (recommended as fallback provider)"
    fi
else
    fail "factory.conf: not found. Copy and edit it before running setup.sh"
fi
echo ""

# ═══════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════"
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "  ${GREEN}ALL CHECKS PASSED${NC} — ready to run setup.sh"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${YELLOW}$WARNINGS WARNING(S)${NC} — can proceed but review warnings above"
    exit 2
else
    echo -e "  ${RED}$ERRORS ERROR(S)${NC}, $WARNINGS warning(s) — fix errors before running setup.sh"
    exit 1
fi
