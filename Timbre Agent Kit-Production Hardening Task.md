# Timbre Agent Kit — Production Hardening Task

## Role & Mission
You are a senior platform/security engineer. This repo (`timbre-agent-kit`) is a working
7-agent OpenClaw automation system built for a single operator. It is being turned into the
delivery engine for an AI automation agency ("Timbre") that will run **multiple paying clients'
systems on our infrastructure**. Your mission is to take it from "works for one person" to
"production-ready for multi-client delivery" — without breaking what already works.

## Prime Directives (read before touching anything)
1. **Do not rewrite the whole repo.** Improve incrementally. The architecture, the 7-agent
   design, the niche-skill system, and the security skills (`skill-firewall`, `skillguard`)
   are good — build on them.
2. **Work in small, reviewable commits**, one concern per commit, with clear messages. Do not
   force-push or rewrite history.
3. **Never invent or hardcode secrets.** No API keys, tokens, or passwords in any tracked file,
   ever — not even examples. Use placeholders + environment variables + a `.env.example`.
4. **Ask before destructive actions** (deleting files, changing the public install command,
   altering anything that would break existing installs). Propose, then wait for my confirmation.
5. **Fail loud, not silent.** This system's promise is "runs while you sleep," so hiding errors
   is the cardinal sin. See P1.
6. Preserve backward compatibility for anyone who already installed. If a change is breaking,
   flag it and provide a migration note.
7. Before starting, read: `README.md`, `setup.sh`, `AUTOMATION-BLUEPRINT.md`,
   `HERMES-SETUP.md`, `config-templates/`, `deployments/`, `agents/AGENT_ARCHITECTURE.md`,
   and the `skill-firewall` + `skillguard` skills. Summarize back to me your understanding
   of the current architecture and your proposed plan **before writing code**.

## Context you need
- Business model: three tiers. Tier 1 (DIY blueprint, client's accounts), Tier 2 (white-glove
  build, client's accounts, handed off), Tier 3 (fully managed, **our infrastructure, one
  isolated environment per client**).
- The operator has previously suffered a credential-exposure incident. Secrets hygiene is
  treated as existential, not cosmetic.
- Some clients are in regulated niches (medical, bookkeeping). Assume a data leak is a
  breach-notification event, not an inconvenience.

## Priorities — do them in this order

### P0 — Multi-client isolation (highest liability; blocks Tier 3)
Currently everything installs to a single `~/.openclaw/` with one config, one gateway, one
agent set. There is **no per-client isolation**. Design and implement an isolation model so
each client runs in its own environment with its own secrets, data, and process boundary.
- Preferred approach: one Docker Compose stack per client, parameterized by a client ID, with
  per-client generated secrets, isolated volumes, and no shared network by default.
- Provide a `provision-client.sh <client-id>` that stands up an isolated instance and a
  `deprovision-client.sh <client-id>` that tears it down cleanly.
- Document the isolation guarantees and the threat model in `SECURITY.md`.
- Acceptance: two clients provisioned side by side cannot read each other's config, data,
  volumes, or message streams. Demonstrate with a test.

### P1 — Fail-loud installer & health (reliability)
`setup.sh` currently masks failures (`2>/dev/null … || true`, unconditional "✓" after commands
that may have failed, hardcoded "23 skills installed" summary). Fix:
- Replace masked calls with real exit-code checks; only print success on actual success.
- Verify the gateway is actually up (poll a health endpoint / status command) before claiming
  "Gateway running." Same for Docker services and each skill install.
- Make the final summary reflect **actual** results (installed vs failed counts), not asserted.
- Reconsider `set -e` interacting with interactive `read` and long installs so a mid-run failure
  can't leave a half-written config that looks complete. Make installs idempotent/resumable.
- Add a `health-guard.sh` watchdog: detects a dead gateway or a stalled/mid-task agent, alerts
  (configurable webhook/Telegram), and optionally restarts. This is the highest-value reliability
  addition — the "runs while you sleep" guarantee depends on it.

### P2 — Secrets hygiene
- `setup.sh` writes the DeepSeek key into `~/.openclaw/openclaw.json` via heredoc with default
  permissions. `chmod 600` all files containing secrets immediately on creation.
- Prefer reading keys from environment / a secrets file the app loads, rather than interpolating
  them into tracked-format JSON. Provide `.env.example`.
- Add a pre-commit secret-scan hook (reuse `skillguard/scripts/scanner.py` if suitable) so no key
  can ever be committed. Wire it into a CI check too.
- Audit `deployments/twenty/docker-compose.yml`: replace `twenty:twenty` Postgres creds with
  per-deploy generated secrets; bind service ports to `127.0.0.1` (not `0.0.0.0`) and document a
  reverse-proxy-with-auth pattern for anything that must be exposed.

### P3 — Safe defaults
- Telegram config defaults to `groupPolicy: "open"` and `requireMention: false` in both the
  template and generated config. Change defaults to **closed + allowlist + requireMention: true**.
  Make "open" an explicit opt-in with a warning.
- For Tier 2 (handed-off) deployments, ship self-modifying skills (`self-improving`, heartbeat)
  **off by default** — an unsupervised system that rewrites its own memory/skills will drift into
  breakage post-handoff. Make self-improvement a managed-tier (Tier 3) opt-in. Keep it available.

### P4 — Fix the productization bugs (protects margin)
- The niche selector option 8 (multi-select) is broken: it sets `NICHE_LIST="$NICHE"` (literal
  "8") and installs nothing. Implement real multi-select (parse space-separated numbers → map each
  to its skill list → dedupe → install).
- Tie the "core skills (N)" summary to real install results.
- Add a `--non-interactive` / config-file install mode so client provisioning can be scripted
  (needed for P0 automation and for repeatable Tier 2 builds).

## Cross-cutting requirements
- Add `SECURITY.md` (threat model, isolation guarantees, secrets policy, port policy, incident
  response basics) and a `PRODUCTION_CHECKLIST.md` (what must be true before a client goes live).
- Add tests where feasible: installer dry-run, isolation test, secret-scan test, config-validation.
- Add CI (GitHub Actions): lint shell (`shellcheck`), run the secret scan, run tests.
- Keep docs in sync — update `README.md` and any setup docs to match new flows.
- Every script that handles secrets or client data gets a header comment stating what it touches.

## Definition of Done
- [ ] Two clients can be provisioned in isolation and provably cannot access each other's data.
- [ ] Fresh install on a clean machine fails loudly on any real error; summary reflects reality.
- [ ] No secret is ever written world-readable or committed; pre-commit + CI scan enforce it.
- [ ] Telegram and self-modification default to safe; unsafe modes are explicit opt-ins.
- [ ] Niche multi-select works; install counts are truthful.
- [ ] `health-guard.sh` detects and reports a downed gateway / stalled agent.
- [ ] `SECURITY.md`, `PRODUCTION_CHECKLIST.md`, updated `README.md`, and CI all present.
- [ ] shellcheck clean; tests pass in CI.

## Working agreement
Start by reading the repo and giving me: (1) a 5–10 line summary of the current architecture as
you understand it, (2) your ordered implementation plan, (3) any place you disagree with the
priorities above or see a better approach. Wait for my go-ahead before P0 code. After each
priority, show me the diff and a one-paragraph summary before moving on. If any instruction here
conflicts with something you find in the repo's own files, surface the conflict to me rather than
guessing.
