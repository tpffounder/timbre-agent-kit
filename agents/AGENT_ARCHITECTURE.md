# AI Agent Architecture
_Last updated: 2026-06-25_

## Overview
7 agents + Decision Council managed by Pablo (main session). Agent 0 (Conductor) is the intelligent router — Joan's single entry point for any request.

**The Conductor pattern** (inspired by Sakana Fugu): Instead of routing tasks manually or fixing which model each agent uses, Agent 0 classifies every incoming request and dynamically assembles the right agent(s) + model(s) for the job. Low-latency tasks get answered directly. Deep tasks get chained with hand-offs. Critical tasks get verification passes.

## Model Strategy
- **DeepSeek V4 Flash** (`deepseek/deepseek-v4-flash`) — **NEW DEFAULT** as of 2026-06-25. Replaces V3 as the primary model. 1M context, 384K max output, thinking mode built-in. 2x cheaper on cache miss, 10x cheaper on cache hit vs V3.
- **DeepSeek V4 Pro** (`deepseek/deepseek-v4-pro`) — Heavy lifter for Agent 1 (research) and Decision Council when maximum reasoning depth is needed. $0.435/M input, $0.87/M output. 500 concurrency.
- **DeepSeek V3 (`deepseek-chat`)** and **R1 (`deepseek-reasoner`)** — **Deprecated July 24, 2026.** Still functional until then via compatibility mapping to V4 Flash.

### Thinking Mode (V4)
Both V4 models support thinking mode natively — no separate 

## Agent Stack

### Agent 0: The Conductor (Router & Orchestrator) 🎼
- **Role:** Single entry point. Classifies every request and routes to the right agent(s) with structured briefs
- **Cadence:** Always-on (routes in real-time per request)
- **Reasoning depth:** DYNAMIC (V4 Flash for simple routing, V4 Pro or thinking mode for complex workflow design)
- **Input:** Any task from Joan
- **Output:** Routed task to correct agent + structured hand-off
- **File:** `agents/agent0-conductor/AGENT.md`
- **Status:** 🟢 Live as of 2026-06-25 — Pablo follows these routing rules

### Agent 1: Research & Strategy Agent
- **Cadence:** 2x/week (Monday + Thursday)
- **Reasoning depth:** HIGH — uses DeepSeek V4 Pro (thinking mode) for deep strategic analysis
- **Input:** Google Trends, competitor socials, Reddit (r/smallbusiness, r/Entrepreneur, r/startups), YouTube comments
- **Output:** Weekly content briefing (JSON + markdown) → feeds Agent 2
- **Competitors to track:** SkynextAI, Process Street, Zapier blog
- **Status:** 🟢 Live — upgraded to V4 Pro 2026-06-25

### Agent 2: Content Strategy & Messaging Agent
- **Cadence:** 2x/week (after Agent 1 runs)
- **Reasoning depth:** HIGH — uses DeepSeek V4 Flash (thinking mode enabled) for messaging architecture
- **Input:** Agent 1 briefing
- **Output:** Weekly messaging playbook (content pillars, narrative arcs, CTAs per platform)
- **Status:** 🟢 Live — upgraded to V4 Flash thinking mode 2026-06-25

### Agent 3: Long-Form Content Generator
- **Cadence:** 3x/week
- **Reasoning depth:** MEDIUM — uses DeepSeek V4 Flash (execution > deliberation)
- **Input:** Agent 2 playbook + daily content pillar
- **Output:** LinkedIn posts, blog articles, email sequences (750-2000 words) — now up to 384K tokens per output
- **Status:** 🟢 Live — upgraded to V4 Flash 2026-06-25

### Agent 4: Short-Form Content Generator
- **Cadence:** 5x/week
- **Reasoning depth:** LOW — uses DeepSeek V4 Flash (speed > depth)
- **Input:** Agent 2 playbook + trending hooks
- **Output:** TikTok/Reels/Shorts scripts (15-60 sec), on-screen text, hooks
- **Status:** 🟢 Live — upgraded to V4 Flash 2026-06-25

### Agent 5: Outreach & DM Agent
- **Cadence:** Daily
- **Reasoning depth:** MEDIUM — uses DeepSeek V4 Flash (personalization at scale)
- **Input:** ICP list, lead signals, DM templates
- **Output:** Personalized DMs, follow-up sequences, prospect tracking
- **Skills:** Outreach, linkedin, linkedin-lead-gen-outreach, yc-cold-outreach, email-outreach-ops
- **Status:** 🟢 Live — upgraded to V4 Flash 2026-06-25

### Agent 6: Analytics & Optimization Agent
- **Cadence:** Weekly (Sundays)
- **Reasoning depth:** MEDIUM — uses DeepSeek V4 Flash (trend analysis, no chain-of-thought needed)
- **Input:** Platform analytics, email stats, revenue KPIs
- **Output:** Performance report + recommendations for next week
- **Skills:** marketing-analytics, Weekly Report Generator
- **Status:** 🟢 Live — upgraded to V4 Flash 2026-06-25

## Data Flow
```
INCOMING REQUEST (from Joan)
    │
    ▼
Agent 0 — The Conductor (classifies + routes)
    │
    ├─ [Simple QA] → Answer directly
    ├─ [Research] → Agent 1 (V4 Pro, thinking mode)
    ├─ [Strategy] → Agent 2 (V4 Flash, thinking mode)
    ├─ [Content Long] → Agent 3 (V4 Flash)
    ├─ [Content Short] → Agent 4 (V4 Flash)
    ├─ [Outreach] → Agent 5 (V4 Flash)
    ├─ [Analytics] → Agent 6 (V4 Flash)
    ├─ [Decision] → Decision Council (V4 Pro + V4 Flash)
    └─ [Multi-step] → Chain: Agent X → Agent Y → ...

--- Weekly content pipeline (routed by Conductor) ---
Agent 1 (Research - V4 Pro)     ← Thinking mode for deep analysis
    ↓ weekly briefing
Agent 2 (Strategy - V4 Flash)     ← Thinking mode for messaging architecture
    ↓ messaging playbook
Agent 3 (Long-form - V4 Flash) + Agent 4 (Short-form - V4 Flash)   ← Fast execution
    ↓ content
[Buffer/scheduling] → Platforms
    ↓ performance data
Agent 6 (Analytics - V4 Flash) → loops back to Agent 1
    
Agent 5 (Outreach - V4 Flash) runs in parallel daily
```

## Multi-Agent Workflow Examples

**Content from scratch (Fugu-style orchestration):**
```
Task: "Research AI voice trends → write LinkedIn post → DM ICPs about it"
Conductor routes: Agent 1 (V4 Pro, thinking) → Agent 2 (V4 Flash, thinking) → Agent 3 (V4 Flash) + Agent 5 (V4 Flash)
```

**Critical task with verification:**
```
Task: "High-stakes proposal for a $4k/mo client"
Conductor routes: Agent 2 (V4 Flash, thinking, strategy) → Agent 3 (V4 Flash, draft)
    → Agent 0 verification pass → deliver
```

**Weekly batch:**
```
Conductor routes: Agent 1 (Mon, V4 Pro thinking) → Agent 2 (Mon, V4 Flash thinking)
    → Agent 3 (Tue/Wed/Thu, V4 Flash) + Agent 4 (Mon-Fri, V4 Flash)
```

## Cost Comparison: V3 vs V4

| | **V3 Chat** | **V4 Flash** | **V4 Pro** |
|---|---|---|---|
| Cache hit input | $0.028 | **$0.0028** (10x cheaper) | $0.003625 |
| Cache miss input | $0.28 | **$0.14** (2x cheaper) | $0.435 |
| Output | $0.42 | **$0.28** (33% cheaper) | $0.87 |
| Context | 128K | **1M** (8x more) | **1M** |
| Max output | 8K | **384K** (48x more) | **384K** |

**Bottom line:** V4 Flash is cheaper AND more capable than V3 in every dimension. V4 Pro is more expensive but brings flagship reasoning depth for the hardest problems. The switch from V3 to V4 Flash saves money automatically.

## Community Repos Added (2026-06-25)

| Repo | Stars | What It Adds | Status |
|------|-------|-------------|--------|
| **awesome-n8n-templates** | 23.4k | 280+ ready-to-run n8n workflows (Gmail, Telegram, Slack, WhatsApp, Google Drive) | 🟢 Cloned to `community-repos/awesome-n8n-templates/` |
| **twentyhq/twenty** | 51.6k | Open-source CRM (Salesforce alternative) with AI. Self-hosted deal tracking for DFY clients | 🟢 Live at `http://localhost:3000` — deployed via Docker Compose with systemd auto-restart |

### GitHub Auth
- Token updated 2026-06-25
- Stored in `~/.git-credentials` + `git remote set-url`
- Repos: `tpffounder/timbre-workspace` (push/pull)

## Build Order
1. Agent 1 — Research & Strategy (start here, V4 Pro thinking)
2. Agent 2 — Content Strategy (V4 Flash thinking)
3. Agent 3 — Long-Form Content (V4 Flash)
4. Agent 4 — Short-Form Content (V4 Flash)
5. Agent 5 — Outreach (V4 Flash)
6. Agent 6 — Analytics (V4 Flash)
7. Agent 0 — Conductor (added 2026-06-25, inspired by Sakana Fugu's learned orchestration)

## Migration Timeline
- **2026-06-25:** Switched default model from V3 Chat → V4 Flash
- **2026-06-25:** Agent 1 upgraded from R1 → V4 Pro (thinking mode)
- **2026-06-25:** Agent 2 upgraded from R1 → V4 Flash (thinking mode)
- **2026-07-24:** V3 models (`deepseek-chat`, `deepseek-reasoner`) fully deprecated
- All config files and agent docs updated to V4. No code changes needed — same API, same key, better models.

## Decision Council (added 2026-06-23)

A 5-advisor + Chairman framework for sharp decision-making under uncertainty. Not a content team — a strategic sparring council.

| Agent | Role | File |
|-------|------|------|
| Advisor 1 | The Contrarian — names only what will fail | `agents/decision-council/01-contrarian.md` |
| Advisor 2 | The First-Principles Thinker — rips assumptions apart | `agents/decision-council/02-first-principles.md` |
| Advisor 3 | The Expansionist — finds the upside being underweighted | `agents/decision-council/03-expansionist.md` |
| Advisor 4 | The Outsider — asks the dumb questions insiders won't | `agents/decision-council/04-outsider.md` |
| Advisor 5 | The Executor — concrete actions for this week | `agents/decision-council/05-executor.md` |
| Chairman | Weighs disagreement, delivers verdict | `agents/decision-council/00-chairman.md` |

### When to use
Joan presents a decision with: what he's choosing between, stakes, timeline, resources/constraints, success criteria. Each advisor responds separately in their own voice, then Chairman delivers a final committed verdict.

### Rules
- No advisor hedges or balances — that's the Chairman's job
- Genuine disagreement is the point
- If the honest answer is "this is bad," say it plainly
