---
name: skillguard
description: Self-contained skill security scanner for OpenClaw. Scans skill directories for dangerous patterns — credential leaks, external URLs, shell injection, large binaries, obfuscated code — without phoning home to any third-party API.
metadata:
  version: "1.0.0"
  author: "Timbre AI Automation"
  requires:
    bins: [python3]
---

# SkillGuard — Offline Skill Security Scanner

Zero-dependency security scanner for OpenClaw skills. All analysis is done locally. No data leaves your machine.

## When to Activate

Run SkillGuard whenever a skill is:
- Newly installed
- Downloaded from a URL
- Copied from an untrusted source
- Being evaluated for safety

## How to Use

```bash
# Scan a specific skill directory
python <skillguard_dir>/scripts/scanner.py scan ./skills/some-skill

# Scan all installed skills
python <skillguard_dir>/scripts/scanner.py scan-all

# Quick check on a single file
python <skillguard_dir>/scripts/scanner.py check ./skills/some-skill/scripts/script.py
```

## What It Catches

| Level | Pattern | Example |
|-------|---------|---------|
| Level | Pattern | Example |
|-------|---------|---------|
| HIGH | Hardcoded API keys/secrets | OpenAI, GitHub, AWS keys |
| HIGH | Calls to external APIs | HTTP requests to external URLs |
| HIGH | obfuscated/minified code | Base64-encoded scripts, eval, exec |
| HIGH | Zip-slip path traversal | Paths that escape the target dir |
| MEDIUM | Telemetry/phone-home URLs | Pingbacks to unknown services |
| MEDIUM | Shell command injection | System calls with user input |
| MEDIUM | Large binary blobs | Files larger than 1MB in skill dir |
| LOW | Network imports | urllib, requests, curl |
| INFO | Fail closed behavior | Confirm with user before proceeding |

## How It Works

1. Walks every file in the skill directory
2. Checks for dangerous patterns using static analysis
3. Reports risk level: HIGH (block) / MEDIUM (warn) / LOW (inform) / SAFE (pass)
4. For HIGH risks, blocks with details. For MEDIUM, asks user confirmation.

## Design Principle

**No data leaves the machine.** All pattern matching runs locally. No API calls, no telemetry, no auto-update that phones home. If security definitions need updating, they ship through the agent-kit repo update.
