# OpenFactory

**OpenFactory** is an enterprise-grade, autonomous software factory driven by AI agent orchestration. 

It acts as a literal "company-in-a-box," deploying a roster of 14 distinct AI agents across Engineering, Product, Marketing, and Sales departments. A human acts exclusively as the **CEO**, passing high-level directives via a Telegram webhook and signing off on 6 critical pipeline gates. The factory handles the rest—writing PRDs, developing code, running QA tests, and writing marketing copy.

---

## 🏭 Core Architecture

### The L-Factor Matrix
OpenFactory utilizes a FAANG-inspired leveling system to control agent autonomy and manage API token costs:
*   **L3-L4 (Junior / Execution):** Highly constrained sandboxed execution (e.g., unit testing, simple components). Configured to use cheap models (Haiku) or `$0/token` local GPU models (Ollama).
*   **L5 (Senior):** High constraint. Generates and connects entire modules. Enforces design patterns and evaluates tech-debt trade-offs.
*   **L6-L8 (Directors / C-Suite):** Powered by pure reasoning frontier models (Claude 4.6 / GPT-5.4). They dictate macro-architecture, allocate compute resources, and break deadlocks automatically using strict management skills (like `dispute-resolution`).

### The Agent Roster
The factory deploys a full org chart, including:
*   `orchestrator` (L8) - Your proxy and executive pipeline manager.
*   `cpo` & `cto` (L7) - Strategy and architectural sign-off.
*   `product-manager` (L6) - Writing Jira-style epics and PRDs.
*   `tech-lead` (L6) - Conducting code reviews and allocating SDE agents.
*   `sales-dev-rep` (L3) - Formulating cold outreach.

### Deterministic AgentSkills
Agents in OpenFactory do not take raw LLM prompts. They execute strict, YAML-configured `AgentSkills`. Each skill maps exact bash command allowances, explicitly blacklisted actions (e.g., `rm -rf /*`), and distinct behavioral bounds based on the agent's L-Factor level.

---

## 🚀 Quick Start (One-Click Setup)

OpenFactory is designed to be instantly provisioned either on a high-end local GPU rack or in the cloud.

1. **Configure your target**
   Edit `factory.conf` to set your target (Local, AWS, GCP, Azure, Hetzner) and provide your LLM API keys.
   ```bash
   nano factory.conf
   ```

2. **Run the provisioner**
   The setup script validates your system, installs Docker/Node, generates secure `.env` secrets, and spins up the orchestration cluster automatically.
   ```bash
   bash setup.sh
   ```

3. **Start the Factory**
   Message your designated Telegram Bot with a product idea. The `orchestrator` agent will catch the webhook and trigger the `idea-to-launch` pipeline.

---

## 🌐 Deployment Targets

| Setup | Recommended Hardware | Monthly Cost | Use Case |
| :--- | :--- | :--- | :--- |
| **Local Rack** | 64GB+ RAM, NVIDIA GPU (RTX 4090) | Electricity + L7 APIs | Zero-cost execution for L3/L4 agents via local Ollama weights. |
| **Cloud (AWS/Hetzner)**| 4 vCPU, 8GB-16GB RAM | $7 - $100/mo | Pure API execution. Instantly deployable from any laptop. |
