# Hermes Agent Setup — Side-by-Side with OpenClaw

## Overview

Run Hermes Agent locally (your Mac) while OpenClaw runs on the VPS. They share the same skill standard (agentskills.io), so all skills we've built work on both.

**Division of labor:**
- **OpenClaw (VPS):** Multi-agent system — content pipeline, outreach, analytics, cron jobs, Telegram bot for clients
- **Hermes (Mac):** Your personal local agent — coding, file management, local automation, quick research

---

## 1. Install Hermes

**On your Mac:**

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

This installs:
- `~/.hermes/` — config, skills, memory, sessions
- `hermes` CLI — terminal chat
- Gateway — for Telegram/Discord/other channels (optional)

**Verify it works:**
```bash
hermes setup --portal        # Easiest — one OAuth for model + tools
# OR
hermes model                 # Choose a provider manually
hermes chat                  # Start a conversation
```

---

## 2. Share the Skills

Our Agent Kit skills work on Hermes with zero changes. Copy them over:

```bash
# Via Tailscale (recommended — already set up)
scp -r tpffounder@100.x.x.x:~/.openclaw/workspace/skills/* ~/.hermes/skills/

# OR clone from GitHub
git clone https://github.com/tpffounder/timbre-agent-kit.git /tmp/agent-kit
cp -r /tmp/agent-kit/skills/* ~/.hermes/skills/
```

**Core skills to activate on Hermes:**
- `skillguard` — security scanning
- `humanizer` — clean up AI writing
- `self-improving` — compound learning
- `socialclaw` — cross-platform posting (if you want Hermes to publish too)
- `skill-firewall` — prompt injection defense
- `openclaw-backup` — backup config
- `workflow-skillify` — capture repeatable processes as skills
- `ontology` — structured knowledge graph

---

## 3. Sync Memory Between Hermes & OpenClaw

Hermes uses `~/.hermes/memories/` while OpenClaw uses `memory/`. Keep them in sync:

**On your Mac (cron job via launchd or hermes cron):**
```bash
# Sync OpenClaw memories from VPS every hour
0 * * * * rsync -avz tpffounder@100.x.x.x:~/timbre-workspace/memory/ ~/timbre-workspace/memory/
cp -r ~/timbre-workspace/memory/* ~/.hermes/memories/ 2>/dev/null
```

**Sync both ways for continuity:**
- OpenClaw writes daily memories to `memory/YYYY-MM-DD.md`
- Hermes writes to `~/.hermes/memories/`
- A simple cron/script keeps them bidirectional

---

## 4. Config Comparison

| | OpenClaw (VPS) | Hermes (Mac) |
|---|---|---|
| **Config file** | `~/.openclaw/openclaw.json` | `~/.hermes/config.yaml` |
| **Secrets** | In openclaw.json models section | `~/.hermes/.env` |
| **Skills dir** | `~/.openclaw/workspace/skills/` | `~/.hermes/skills/` |
| **Memory** | `memory/YYYY-MM-DD.md` | `~/.hermes/memories/MEMORY.md` |
| **Agent identity** | `SOUL.md` | `~/.hermes/SOUL.md` |
| **Cron** | Gateway cron (in config) | `~/.hermes/cron/` |
| **Chat** | Telegram → me | Terminal TUI or Telegram |

### Example Hermes config.yaml (for DeepSeek)

```yaml
model:
  provider: custom
  default: deepseek/deepseek-v4-flash
  base_url: https://api.deepseek.com/v1
  # api_key is set in ~/.hermes/.env:
  #   OPENAI_API_KEY=sk-your-deepseek-key-here

terminal:
  backend: local

gateway:
  enabled: true
  platforms:
    telegram:
      enabled: true
      bot_token: "${TELEGRAM_BOT_TOKEN}"
```

---

## 5. Telegram on Both (Same Bot, Different Accounts)

You can't run two Telegram bots with the same token. Options:

**Option A: Different bot tokens**
- OpenClaw keeps @MrPablobot on VPS
- Hermes gets a new bot from @BotFather (e.g., @HermesForJoan)

**Option B: Hermes listens on Telegram, OpenClaw keeps Telegram + Signal**
- Only one agent per bot token
- OpenClaw can switch to Signal/SMS if needed

**Option C: Hermes CLI-only (no messaging gateway)**
- Simplest — Hermes is for local terminal chat
- All remote communication stays on OpenClaw

**Recommended: Option C to start.** Use Hermes from terminal for coding and local work. Move to a second bot if you want Hermes on Telegram too.

---

## 6. What Hermes Can Do (That OpenClaw Can't Easily)

- **Native Mac apps:** Apple Notes, Apple Reminders, iMessage, FindMy
- **Local file system:** Direct access to your Mac files
- **Terminal UI:** Rich TUI with multiline editing, autocomplete
- **Voice Mode:** Real-time voice conversations (CLI + Telegram + Discord)
- **Desktop App:** Native macOS/Windows desktop
- **Local models:** Run via Ollama, LM Studio, vLLM on your Mac

---

## 7. What OpenClaw Can Do (That Hermes Can't Easily)

- **Multi-agent system:** 6 agents running independently with different roles
- **Scaled deployments:** Docker services (n8n, Twenty CRM) on VPS
- **Persistent 24/7 operation:** Always-on gateway on VPS
- **Automation cron jobs:** 7+ scheduled scripts running round the clock
- **Client-facing bots:** Separate from your personal agent

---

## 8. Quick Start Script

I can write and commit this to the Agent Kit repo as `setup-hermes.sh`. It'll:

1. Copy all compatible skills from the repo to `~/.hermes/skills/`
2. Generate a config.yaml template with DeepSeek provider
3. Create a SOUL.md that matches your identity
4. Set up a cron job to sync memories from VPS over Tailscale
5. Print next steps

Want me to write that now?
