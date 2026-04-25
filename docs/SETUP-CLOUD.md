# Setup Guide: Cloud VPS (AWS / Azure / GCP / Hetzner / DigitalOcean)

**Target reader:** Claude Haiku 4.5 (or any LLM building the factory)
**Target machine:** Cloud VPS with Ubuntu 24.04, 4+ vCPU, 8+ GB RAM
**Time:** ~15 minutes

---

## Prerequisites Checklist

Before starting, verify on YOUR LOCAL MACHINE (the one running setup.sh):
- [ ] SSH key pair exists (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)
- [ ] Cloud provider CLI installed and authenticated:
  - AWS: `aws configure` done
  - Azure: `az login` done
  - GCP: `gcloud auth login` done
  - Hetzner: API token ready
  - DigitalOcean: API token ready
- [ ] Domain name purchased and ready to point DNS
- [ ] Telegram bot created (see SETUP-LOCAL.md Step 7)

---

## One-Click Setup

```bash
cd /path/to/factory

# 1. Edit config
nano factory.conf
# Set: FACTORY_TARGET=aws  (or azure, gcp, hetzner, digitalocean)
# Set: Cloud-specific settings (region, instance type, etc.)
# Set: CLOUD_DOMAIN=factory.yourdomain.com
# Set: SSH_KEY_PATH=~/.ssh/id_rsa
# Set: All API keys and Telegram tokens

# 2. Run setup
bash setup.sh
```

The script will:
1. Provision a VM on your chosen cloud provider
2. Wait for SSH to become available
3. Install Docker, Node.js 24, OpenClaw on the remote server
4. Copy all factory files to the server
5. Generate .env with secrets
6. Update Caddyfile with your domain
7. Start Docker Compose
8. Print the access URL

---

## After Setup

### Point DNS

The script outputs the server's IP address. Create a DNS A record:

```
factory.yourdomain.com  →  A  →  <SERVER_IP>
```

Wait 2-5 minutes for DNS propagation. Caddy automatically provisions a TLS certificate from Let's Encrypt.

### Access

| What | URL |
|---|---|
| Factory Portal | https://factory.yourdomain.com |
| Mission Control | https://factory.yourdomain.com/dashboard/ |
| SSH | `ssh -i ~/.ssh/id_rsa <user>@<ip>` |

### Verify

```bash
# From your local machine:
curl https://factory.yourdomain.com/health

# Or SSH into the server:
ssh -i ~/.ssh/id_rsa ubuntu@<ip>
docker compose -f /opt/factory/infrastructure/docker-compose.cloud.yml ps
docker compose -f /opt/factory/infrastructure/docker-compose.cloud.yml logs openclaw-gateway --tail 50
```

---

## Provider-Specific Notes

### AWS
- Instance: t3.xlarge (4 vCPU, 16GB RAM) — ~$120/mo
- Cheaper: t3.medium (2 vCPU, 4GB) — ~$30/mo for light usage
- Security group auto-created with ports 22, 80, 443
- EBS volume auto-sized per AWS_VOLUME_SIZE in factory.conf
- For GPU (local LLMs on cloud): use p3.2xlarge or g5.xlarge

### Azure
- VM: Standard_D4s_v3 (4 vCPU, 16GB RAM) — ~$140/mo
- Cheaper: Standard_B2ms (2 vCPU, 8GB) — ~$60/mo
- Resource group auto-created
- NSG auto-opened for ports 80, 443

### GCP
- VM: e2-standard-4 (4 vCPU, 16GB RAM) — ~$100/mo
- Cheaper: e2-medium (2 vCPU, 4GB) — ~$25/mo
- Firewall rules auto-created
- For GPU: add `--accelerator type=nvidia-tesla-t4,count=1`

### Hetzner (CHEAPEST)
- Server: CX32 (4 vCPU, 8GB RAM) — **$7/mo**
- Provisioned via API (no CLI needed)
- Default SSH user: root
- Excellent value for the factory

### DigitalOcean
- Droplet: s-4vcpu-8gb — ~$48/mo
- Cheaper: s-2vcpu-4gb — ~$24/mo
- Provisioned via API
- Default SSH user: root

---

## Tear Down

### AWS
```bash
aws ec2 terminate-instances --instance-ids <id> --region <region>
aws ec2 delete-security-group --group-name factory-sg --region <region>
```

### Azure
```bash
az group delete --name factory-rg --yes
```

### GCP
```bash
gcloud compute instances delete factory-vm --zone <zone> --project <project>
gcloud compute firewall-rules delete factory-allow-web --project <project>
```

### Hetzner
```bash
# Via Hetzner Cloud Console, or:
curl -X DELETE "https://api.hetzner.cloud/v1/servers/<id>" -H "Authorization: Bearer <token>"
```

### DigitalOcean
```bash
curl -X DELETE "https://api.digitalocean.com/v2/droplets/<id>" -H "Authorization: Bearer <token>"
```
