---
title: "Building My Homelab: From Scattered Docker Containers to Production-Grade Infrastructure"
date: 2025-12-26T21:30:00.000Z
lastmod: 2025-12-26T21:30:00.000Z
draft: true
author: "Italo Vietro"
authorLink: "https://italovietro.com"
description: "How I built a production-grade homelab using Docker Swarm, Ansible, and Infrastructure-as-Code principles to run everything from media streaming to home automation—and what I learned along the way."
resources:
- name: "featured-image"
  src: ""

tags:
  - homelab
  - infrastructure
  - docker
  - ansible
  - automation
  - self-hosting

categories: ["Infrastructure"]

lightgallery: true
---

For years, I've been tinkering with self-hosted services at home. It started small—a Raspberry Pi running Pi-hole, maybe a Plex server on an old laptop. But like most engineers, what begins as "I'll just host this one thing" quickly spirals into "I need a proper infrastructure."

Today, my homelab runs 15+ services across a 3-node Docker Swarm cluster, all managed through Ansible with full Infrastructure-as-Code. It handles everything from media streaming and photo management to home automation and monitoring. More importantly, it's become my personal production environment where I experiment, learn, and break things without the stakes of a company depending on it.

Here's how I built it, what I learned, and why you might want to consider building your own.

## Why Build a Homelab?

Before diving into the technical details, let me address the elephant in the room: **Why bother?** Cloud services are cheap, convenient, and someone else's problem when they break.

Fair point. But here's why I went down this path:

### 🎓 Learning by doing

There's a massive difference between managing infrastructure at work (where you have constraints, compliance, and existing patterns) and building your own from scratch. My homelab is where I truly learned Ansible, Docker Swarm, secrets management, and networking—not from tutorials, but from making mistakes at 2 AM and fixing them.

### 🔒 Data ownership

Call me paranoid, but I like knowing where my family photos live. Services like Google Photos, iCloud, and Dropbox are great, but I wanted full control over my data. Running Immich for photo management means I own everything—backups, access patterns, and privacy.

### 💰 Cost control

Once you get past the initial hardware investment, running your own infrastructure is surprisingly cheap. My entire 3-node cluster draws about 80W at idle and costs me around €15/month in electricity. Compare that to equivalent cloud resources, and the ROI is clear within a year.

### 🛠️ The joy of building

Let's be honest—this is the real reason. There's something deeply satisfying about building a system that just works, automating away manual tasks, and having full control over your digital life.

## The Hardware: Starting Simple

I didn't start with a 3-node cluster. Like most homelabs, mine evolved organically as I outgrew what I had.

### Generation 1: The humble beginning

- **1x Intel NUC** (i5, 16GB RAM, 512GB SSD)
- Running Docker with docker-compose
- About 5-6 services

This worked fine for a while, but I quickly hit limitations. No redundancy, no load balancing, and every deployment meant potential downtime.

### Generation 2: The current setup

Today, my cluster consists of three nodes:

**Oracle** (Main Swarm Manager + Worker)
- Intel NUC 11 Pro
- i7-1165G7, 32GB RAM
- 1TB NVMe SSD
- Runs critical services and acts as the Swarm manager

**Tank** (Worker Node)
- Custom build, AMD Ryzen 5
- 16GB RAM, 512GB SSD
- Handles heavy workloads like media transcoding

**Cypher** (ARM Worker)
- Raspberry Pi 5 (8GB)
- 256GB MicroSD + USB SSD
- Runs ARM-compatible services and acts as an edge node

All three are connected to my home network and can access a Synology NAS (192.168.50.2) for shared storage via NFS.

**Total cost:** Around €1,200 spread over 3 years. Not cheap, but less than a decent laptop.

## The Software Stack: Docker Swarm + Ansible

Here's where things get interesting. I chose Docker Swarm over Kubernetes, and I know some of you are judging me already. Let me explain.

### Why Docker Swarm?

**Kubernetes is overkill for a homelab.** There, I said it.

Don't get me wrong—I use Kubernetes at work, and it's fantastic for large-scale deployments. But for a 3-node homelab? The operational overhead isn't worth it. Docker Swarm gives me:

- **Built-in orchestration** without the complexity
- **Service discovery and load balancing** out of the box
- **Secrets management** that actually works
- **Rolling updates** for zero-downtime deployments
- **Simple YAML configs** that anyone can understand

Here's what a typical service looks like:

```yaml
services:
  traefik:
    image: traefik:latest
    command:
      - --api.dashboard=true
      - --providers.docker=true
      - --providers.docker.swarmMode=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
    networks:
      - traefik-ingress
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-certs:/letsencrypt
    deploy:
      placement:
        constraints:
          - node.role == manager
```

Clean, simple, and it works.

### Infrastructure-as-Code with Ansible

The real game-changer was automating everything with Ansible. No more SSH-ing into boxes and running commands manually. No more "it works on my machine" debugging.

My Ansible setup has **8 modular roles**:

1. **system_packages** - Keeps all nodes updated
2. **users** - SSH keys and user management
3. **dotfiles** - My personal config across all nodes
4. **networking** - Firewall rules, NAS mounts, DNS
5. **docker_install** - Docker Engine setup
6. **docker_services** - Traditional docker-compose services
7. **docker_swarm** - Swarm cluster management
8. **docker_github_runner** - Self-hosted CI/CD runners

Deploying the entire stack is a single command:

```bash
make deploy-swarm
```

Under the hood, that runs:

```bash
ansible-playbook -i inventories/swarm.ini site.yml --tags swarm
```

The playbook handles everything:
- Initializing the Swarm cluster
- Creating overlay networks
- Deploying secrets
- Rolling out 15 service stacks
- Health checks and validation

**Deployment time:** About 5 minutes for the full stack. Compare that to doing it manually.

## The Services: What Actually Runs

Here's what my homelab powers day-to-day:

### 🌐 Networking & Access
- **Traefik** - Reverse proxy with automatic SSL via Let's Encrypt
- **NetBird** - Mesh VPN for secure remote access (no port forwarding!)
- **AdGuard Home** - Network-wide ad blocking and DNS

### 📺 Media & Entertainment
- **Jellyfin** - Self-hosted streaming (goodbye Netflix subscriptions)
- **Jellyseerr** - Request management for movies/TV shows
- **Sonarr, Radarr, Prowlarr, Lidarr, Bazarr** - The full *arr stack with VPN routing

### 📸 Personal Services
- **Immich** - Photo and video management (Google Photos replacement)
- **PocketID** - Identity management and SSO
- **Homepage** - Unified dashboard for all services

### 🔧 Operations & Monitoring
- **Portainer** - Docker management UI
- **Beszel** - System resource monitoring
- **Backrest** - Automated backups
- **GitHub Runner** - Self-hosted CI/CD

### 🤖 Automation
- **n8n** - Workflow automation (IFTTT/Zapier alternative)

Total: **15 service stacks** running across 3 nodes with automatic failover and load balancing.

## The Learnings: What I Wish I Knew Earlier

Building this wasn't smooth sailing. Here are the biggest lessons I learned the hard way:

### 1. Start with automation from day one

My first iteration was all manual Docker commands and docker-compose files scattered across nodes. Every change meant SSH-ing, editing files, and praying nothing broke.

**Switching to Ansible was transformative.** Now, everything is version-controlled, repeatable, and documented. I can rebuild my entire cluster from scratch in under an hour.

**Lesson:** Don't wait until you have 20 services to start automating. Start with Ansible (or Terraform, or whatever) from the beginning.

### 2. Secrets management is not optional

I initially stored secrets in environment files, scattered across nodes. Then I read them in plaintext in my git repo (yep, rookie mistake). Eventually, I got serious:

- **Ansible Vault** for infrastructure secrets (encrypted at rest)
- **Docker Secrets** for runtime secrets (never touch the filesystem)
- **`.vault_pass`** file for automated deployments (secured with proper permissions)

**Lesson:** Treat your homelab like production. Use proper secrets management from the start.

### 3. Networking is harder than you think

Docker overlay networks, NFS mounts, firewall rules, mesh VPNs—networking is where I spent most of my debugging time. Some hard-won tips:

- **Use explicit IP ranges** for overlay networks to avoid conflicts
- **Document firewall rules** (I use UFW and track everything in Ansible)
- **Test network connectivity** between nodes before deploying services
- **Mesh VPN > Port forwarding** for remote access (NetBird changed my life)

**Lesson:** Invest time upfront to understand your network architecture. Draw diagrams. Document everything.

### 4. Monitoring saves you at 2 AM

Nothing teaches you the value of monitoring like a service dying at 2 AM and you having no idea why.

I run **Beszel** for basic resource monitoring and have health checks built into my Ansible playbooks:

```bash
make health
```

This validates:
- Swarm cluster is healthy
- All expected services are running
- Networks and secrets are properly configured

**Lesson:** Build observability in from the start. Future you will thank present you.

### 5. Backups are insurance you hope to never use

I learned this lesson the expensive way when a failed NVMe SSD took out my entire media library. Now I have:

- **Automated daily backups** via Backrest
- **Off-site backups** to an external drive (rotated weekly)
- **Configuration backups** (Ansible repo is version-controlled and backed up)

**Lesson:** 3-2-1 backup strategy. Three copies, two different media, one off-site. No exceptions.

## The Day-to-Day: What It's Actually Like

Here's the reality: my homelab doesn't need much attention. On a typical week, I spend maybe 30 minutes updating services or tweaking configurations. Most of the time, it just works.

When I do make changes, the workflow is:

1. Edit Ansible playbooks locally
2. Run `make deploy-swarm-check` (dry-run)
3. Review changes, commit to git
4. Run `make deploy-swarm` (apply changes)
5. Validate with `make health`

Everything is version-controlled, tested, and reproducible. No cowboy SSH sessions, no "let me just quickly fix this" that breaks everything.

## Should You Build One?

Not everyone needs a homelab, and that's fine. Cloud services exist for a reason. But if you find yourself:

- **Wanting to learn** infrastructure without the pressure of production systems
- **Caring about data privacy** and self-hosting
- **Enjoying building things** more than just using them
- **Having the time** to invest upfront (it's a project, not a product)

Then yes, absolutely build a homelab.

Start small. Don't buy three servers on day one. Begin with a single machine, Docker, and a few services you actually use. Let it grow organically as you learn and need more.

## What's Next?

My homelab is never "done" (is any engineer's project ever done?). Here's what's on my roadmap:

- **Kubernetes migration** (maybe, just to learn)
- **Better monitoring** with the LGTM stack (Loki, Grafana, Tempo, Mimir)
- **More automation** (because you can never have too much automation)
- **Hardware refresh** (Tank is getting old)

---

If you're interested in the nitty-gritty details, all my Ansible code is on GitHub: [italolelis/homelab](https://github.com/italolelis/homelab). Feel free to steal ideas, configs, or the entire thing. That's the beauty of open source.

And if you're building your own homelab, I'd love to hear about it. What are you running? What did you learn? Hit me up on [LinkedIn](https://linkedin.com/in/italolelis) or [GitHub](https://github.com/italolelis).

See you in the next article 👋
