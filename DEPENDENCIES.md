# Timbre Agent Kit — External Dependencies & API Reference

This document lists every external dependency, API key, binary, and service that a fresh installation needs. Use this when setting up on a new machine, troubleshooting, or auditing what touches the outside world.

---

## 1. Core API Keys

| Service | Environment Variable | Required | Where to Get |
|---------|---------------------|----------|-------------|
| **DeepSeek** | `models.deepseek/deepseek-v4-flash.apiKey` | ✅ Yes | https://platform.deepseek.com |
| **Telegram Bot** | `channels.telegram.token` | Optional | @BotFather on Telegram |

### Model Config (openclaw.json)

Default model: `deepseek/deepseek-v4-flash`
Provider plugins: `deepseek`, `telegram`

---

## 2. Optional Service API Keys

These are needed only if you enable the corresponding skill or service.

| Service | Skill / Tool | Env Var | Where to Get |
|---------|-------------|---------|-------------|
| **SocialClaw** | `socialclaw` | `SC_API_KEY` | https://getsocialclaw.com |
| **n8n** | `n8n` | `N8N_API_KEY` + `N8N_BASE_URL` | Settings → API in n8n UI |
| **ElevenLabs TTS** | `sag` (bundled) | `ELEVENLABS_API_KEY` | https://elevenlabs.io |
| **Google Places** | `goplaces` (bundled) | `GOOGLE_PLACES_API_KEY` | Google Cloud Console |
| **OpenAI Whisper** | `openai-whisper-api` (bundled) | `OPENAI_API_KEY` | https://platform.openai.com |
| **Trello** | `trello` (bundled) | `TRELLO_API_KEY` + `TRELLO_TOKEN` | https://trello.com/app-key |
| **GitHub** | `github` (bundled) | `gh auth login` | GitHub CLI (`gh`) |

---

## 3. Required System Binaries (must be installed)

| Binary | Version | Purpose | Install Command |
|--------|---------|---------|----------------|
| **Node.js** | ≥ 22.x | OpenClaw engine + npm | `nvm install 22` |
| **npm** | (ships with Node) | Package manager | — |
| **git** | latest | Clone repo + version control | `apt install git` / `brew install git` |
| **curl** | latest | HTTP requests + setup script | (preinstalled on most systems) |
| **python3** | ≥ 3.8 | SkillGuard + automation scripts | `apt install python3` / `brew install python3` |
| **Docker** | latest | n8n + Twenty CRM containers | https://docs.docker.com/engine/install |
| **jq** | latest | JSON parsing (Trello skill, scripts) | `apt install jq` / `brew install jq` |
| **go** | latest | (optional, for Go-based tools) | `apt install golang` / `brew install go` |

---

## 4. Docker Services (auto-deployed by setup.sh)

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| **n8n** | `n8nio/n8n:latest` | `5678` | Workflow automation (UI at http://localhost:5678) |
| **Twenty CRM** | `twentycrm/twenty:latest` | `3000` | Customer relationship management |
| Twenty DB | `postgres:16` | `5432` | PostgreSQL for Twenty |
| Twenty Redis | `redis` | `6379` | Cache for Twenty |

---

## 5. npm Global Packages

| Package | Purpose | Install |
|---------|---------|---------|
| **openclaw** | Agent engine | `npm i -g openclaw` |
| **clawhub** | Skill marketplace CLI | `npm i -g clawhub` (optional) |

---

## 6. Skills That Phone Home

Some third-party skills make external API calls as part of normal operation. These are safe by design but require network access:

| Skill | External Calls | Requires |
|-------|---------------|----------|
| **socialclaw** | calls `getsocialclaw.com` API to schedule/publish posts | `SC_API_KEY` |
| **n8n** | calls n8n API (`N8N_BASE_URL`) to manage workflows | `N8N_API_KEY` + URL |
| **sag** (bundled) | calls `api.elevenlabs.io` for text-to-speech | `ELEVENLABS_API_KEY` |
| **openai-whisper-api** | calls `api.openai.com` for transcription | `OPENAI_API_KEY` |
| **goplaces** | calls Google Places API | `GOOGLE_PLACES_API_KEY` |
| **trello** | calls Trello API | `TRELLO_API_KEY` + `TRELLO_TOKEN` |
| **github** | calls GitHub API via `gh` CLI | `gh` auth |
| **tts** (image_generate) | calls configured AI provider for image gen | via model config |

**All other skills are self-contained.** No data leaves the machine.

---

## 7. Skills That Use Browser Automation

| Skill | Needs | Notes |
|-------|-------|-------|
| **email-composer** | OpenClaw browser plugin (v2026.3.22+) | Used for Gmail/Outlook |

---

## 8. VPN / Tunneling (optional)

If running on a home server behind NAT, you'll need one of:
| Service | Purpose |
|---------|---------|
| **Tailscale** | Secure mesh VPN (currently in use for Mac sync) |
| **Cloudflare Tunnel** | Public-facing endpoints without opening ports |
| **ngrok** | Quick dev tunnels |

---

## 9. Custom Scripts & Cron Jobs

These run on the VPS and don't need manual setup — they're part of the system:

| Script | Schedule | Purpose |
|--------|----------|---------|
| `timbre-live-data/cron-update.sh` | Every 30 min | Updates dashboard data |
| `sync-to-mac.sh sessions` | Every 5 min | Syncs sessions to Mac over Tailscale |
| `sync-to-mac.sh memory` | Every 5 min | Syncs memory to Mac |
| `sync-to-mac.sh agents-config` | Daily 3:17 AM | Syncs agent configs |
| `auto-backup.sh` | Every 2 hours | Git backup (local + GitHub) |
| `reminder-yappers.sh` | Daily 5:30 PM ET | Telegram reminder ping |
| `dashboard-manager.sh` | @reboot | Dashboard server |

All log to `~/scripts/logs/`.

---

## Quick Install Checklist

```
[ ] Node.js ≥ 22 (node --version)
[ ] npm (ships with Node)
[ ] git
[ ] Python 3.8+
[ ] Docker + docker compose
[ ] jq
[ ] DeepSeek API key
[ ] (optional) Telegram bot token
[ ] (optional) SC_API_KEY for social posting
[ ] (optional) N8N_API_KEY for workflow management
[ ] (optional) Tailscale for multi-machine sync
```

On a fresh VPS: `bash <(curl -fsSL https://raw.githubusercontent.com/tpffounder/timbre-agent-kit/main/setup.sh)`
