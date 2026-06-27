<div align="center">
  <h1>🔔 Timbre Agent Kit</h1>
  <p><strong>AI Automation Agency — 7-Agent Architecture</strong></p>
  <p>One command. Any machine. Full system.</p>
</div>

---

## What You Get

| Component | What It Does |
|-----------|-------------|
| **Agent 0 — Conductor** | Intelligent router — classifies tasks, assembles agent teams |
| **Agent 1 — Research** | Market intel, competitor tracking, trend analysis |
| **Agent 2 — Strategy** | Weekly messaging playbook, content pillars |
| **Agent 3 — Long-Form** | LinkedIn posts, blog articles, email sequences |
| **Agent 4 — Short-Form** | TikTok/Reels/Shorts scripts, hooks |
| **Agent 5 — Outreach** | DM templates, email sequences, prospect tracking |
| **Agent 6 — Analytics** | Weekly KPI reports, performance trends |
| **Decision Council** | 5-advisor + Chairman strategy framework |

## Skills Installed

### Core (always installed)
`market-research-agent` · `copywriting-pro` · `tiktok-growth` · `outbound-prospecting` · `cold-email-writer` · `yc-cold-outreach` · `email-outreach-ops` · `weekly-report-generator` · `memory-setup-openclaw`

### Niche Skills (select during install)
| Industry | Skills |
|----------|--------|
| 🏘️ Real Estate | `real-estate-skill` — property decisions, buying/selling, investing |
| 🔨 Contractors | `afrexai-roofing-contractor` + `afrexai-painting-contractor` — estimating, materials, compliance |
| 📒 Bookkeeping | `bookkeeping-basics` + `accountant` — expenses, reconciliation, financial reports |
| 🏥 Medical | `medical` — local-first health records, strict privacy |
| 🌐 Website Design | `website` — fast, accessible, SEO-friendly sites |
| 📊 Marketing Teams | `eb-marketing` + `marketing-analytics` + `marketing-plan` — full-stack marketing execution |

## Prerequisites

- **Any OS:** macOS · Linux · Windows (Git Bash/WSL) · VPS
- **One API key:** DeepSeek (get at [platform.deepseek.com](https://platform.deepseek.com))
- **Optional:** Telegram bot token (get at @BotFather)

## Quick Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tpffounder/timbre-agent-kit/main/setup.sh)
```

The script will:
1. Detect your OS
2. Install Node.js if needed
3. Clone the agent kit
4. Install OpenClaw + all 9 skills
5. Configure DeepSeek V4 models
6. Set up Telegram bot (if you provide a token)
7. Start the gateway
8. Optionally deploy Docker services (Twenty CRM, n8n)
9. Print a ✅ checklist

## Install Types

| Mode | Includes | Time |
|------|----------|------|
| **Minimal** (1) | OpenClaw + agents + skills only | ~2 min |
| **Standard** (2) | Everything + Twenty CRM + n8n | ~5 min |
| **Full Stack** (3) | Standard + Puppeteer/Chrome | ~8 min |

## What You Need to Provide

Just the API keys — everything else is in the repo:

```
DeepSeek API key  →  required (all AI agents)
Telegram token    →  optional (bot messaging)
Docker            →  optional (Twenty CRM + n8n)
```

## Architecture

```
Incoming Request
      │
      ▼
  Agent 0 ─── Conductor (classifies + routes)
      │
      ├── Simple QA  →  Answer directly
      ├── Content    →  Agent 2 → Agent 3/4
      ├── Research   →  Agent 1
      ├── Outreach   →  Agent 5
      └── Critical   →  Debate mode (Council)
```

## After Install

```bash
# Check status
openclaw status

# Talk to your AI
openclaw chat

# View agent files
ls ~/timbre-agent-kit/agents/

# Restart gateway
openclaw gateway restart
```

## Business Documents

The kit includes full business framework:

- Brand identity & positioning
- Financial model template
- Content calendar
- Email sequence templates
- Outreach targets framework
- Performance dashboard spec
- Investor prep checklist

## License

MIT — Use it. Modify it. Sell it. Build your agency.
