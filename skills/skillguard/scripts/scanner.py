#!/usr/bin/env python3
"""
SkillGuard v1.0.0 — Offline OpenClaw skill security scanner.
Zero external dependencies. No data leaves the machine.

Usage:
  python scanner.py scan <skill_dir>   # Scan one skill
  python scanner.py scan-all            # Scan all installed skills
  python scanner.py check <file>        # Quick-check a single file
"""

import sys, os, re, json, stat
from pathlib import Path
from datetime import datetime

# ──────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────
GUARD_VERSION = "1.0.0"

# Paths to scan for scan-all
SKILL_ROOTS = [
    Path.home() / ".openclaw" / "workspace" / "skills",
    Path.home() / ".openclaw" / "skills",
    Path.home() / ".agents" / "skills",
]

# ──────────────────────────────────────────────────────────────────────────
# Detection Rules
# ──────────────────────────────────────────────────────────────────────────

def color(s, code):
    return f"\033[{code}m{s}\033[0m"

RED = lambda s: color(s, "91")
YELLOW = lambda s: color(s, "93")
CYAN = lambda s: color(s, "96")
GREEN = lambda s: color(s, "92")
BOLD = lambda s: color(s, "1")

# Patterns: (regex, severity, description)
SEVERITY_HIGH = "HIGH"
SEVERITY_MED = "MEDIUM"
SEVERITY_LOW = "LOW"

PATTERNS = [
    # ── HIGH: Secrets / Credentials ──
    (r"(?i)(sk-[a-zA-Z0-9]{20,})", SEVERITY_HIGH, "OpenAI API key detected"),
    (r"(?i)(ghp_[a-zA-Z0-9]{36,})", SEVERITY_HIGH, "GitHub personal access token"),
    (r"(?i)(gho_[a-zA-Z0-9]{36,})", SEVERITY_HIGH, "GitHub OAuth token"),
    (r"(?i)(AIza[0-9A-Za-z\-_]{35})", SEVERITY_HIGH, "Google API key"),
    (r"(?i)(AKIA[0-9A-Z]{16})", SEVERITY_HIGH, "AWS access key"),
    (r"(?i)-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----", SEVERITY_HIGH, "Private key embedded"),
    (r"(?i)-----BEGIN CERTIFICATE-----", SEVERITY_HIGH, "Certificate embedded"),

    # ── HIGH: External API calls (phone-home) ──
    (r"""(?i)(requests\.(get|post|put|delete|patch)\(["'][a-z]+://)""", SEVERITY_HIGH, "External HTTP request"),
    (r"""(?i)(urllib\.request\.urlopen\(["'][a-z]+://)""", SEVERITY_HIGH, "External URL open"),
    (r"(?i)(curl\s+(-s|-S|-L)?\s*['\"]?https?://)", SEVERITY_HIGH, "External curl call"),
    (r"(?i)(wget\s+['\"]?https?://)", SEVERITY_HIGH, "External wget call"),

    # ── HIGH: Code execution / injection ──
    (r"(?i)\bexec\s*\(", SEVERITY_HIGH, "Dynamic exec() call"),
    (r"(?i)\beval\s*\(", SEVERITY_HIGH, "Dynamic eval() call"),
    (r"(?i)\b__import__\s*\(", SEVERITY_HIGH, "Dynamic __import__()"),
    (r"(?i)compile\s*\(.*['\"]", SEVERITY_HIGH, "Dynamic compile()"),

    # ── HIGH: Shell injection / dangerous commands ──
    (r"(?i)os\.system\s*\(", SEVERITY_HIGH, "os.system() call"),
    (r"(?i)subprocess\.(call|Popen|run|check_output)\s*\(", SEVERITY_HIGH, "subprocess execution"),
    (r"(?i)shutil\.rmtree\s*\(", SEVERITY_MED, "Recursive file deletion"),
    (r"[`$][(][^)]*rm\s", SEVERITY_HIGH, "Inline shell rm injection"),

    # ── HIGH: Base64-encoded scripts / obfuscation ──
    (r"(?i)(base64\.(b64decode|decodestring)\s*\()", SEVERITY_HIGH, "Base64 decoded in code — possible obfuscation"),
    (r"(?i)([A-Za-z0-9+/]{100,}={0,2})['\"]", SEVERITY_MED, "Long base64 string in code"),

    # ── MEDIUM: Network imports ──
    (r"^\s*import\s+(requests|urllib|http\.client|socket|ftplib)", SEVERITY_MED, "Network library import"),
    (r"^\s*from\s+(requests|urllib)", SEVERITY_MED, "Network library import (from)"),

    # ── MEDIUM: Telemetry domains (specific patterns, not generic words)
    (r"(?i)(telemetry|beacon|pingback|heartbeat\.send|phoning.home)", SEVERITY_MED, "Telemetry/pingback reference"),
    (r"https?://[a-z0-9.-]*\b(analytics|tracking|metrics)\.", SEVERITY_MED, "Analytics/tracking URL"),

    # ── LOW: Suspicious patterns ──
    (r"\binput\s*\(\s*['\"]", SEVERITY_LOW, "Interactive input() — may hang in batch"),
    (r"(?i)(tempfile|mkdtemp|mktemp)", SEVERITY_LOW, "Creates temp files/dirs"),
    (r"\b(rm\s+-rf|rmdir\s+/[sd])", SEVERITY_LOW, "Dangerous rm pattern"),
]

# Files to skip entirely
SKIP_FILES = {".DS_Store", "Thumbs.db", ".gitkeep", "__pycache__"}
SKIP_DIRS = {".git", "__pycache__", ".venv", "node_modules", ".clawhub"}

# Max file size to scan (bytes)
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# Max binary blob warning threshold
BINARY_WARN_SIZE = 1 * 1024 * 1024  # 1MB


# ──────────────────────────────────────────────────────────────────────────
# Scanner Logic
# ──────────────────────────────────────────────────────────────────────────

def is_binary(filepath):
    """Quick check: read first 8KB, if null bytes found, it's likely binary."""
    try:
        with open(filepath, "rb") as f:
            chunk = f.read(8192)
            return b"\x00" in chunk
    except Exception:
        return True  # Can't read = skip


def scan_file(filepath):
    """Scan a single file for dangerous patterns. Returns list of findings."""
    findings = []
    try:
        size = filepath.stat().st_size
        if size > MAX_FILE_SIZE:
            return [("WARN", f"File too large ({size // 1024 // 1024}MB), skipped")]
    except OSError:
        return [("WARN", "Cannot stat file")]

    # Warn on large binary files
    ext = filepath.suffix.lower()
    binary_exts = {".png", ".jpg", ".jpeg", ".gif", ".ico", ".mp3", ".mp4", ".zip", ".gz", ".tar"}
    if ext in binary_exts:
        if filepath.stat().st_size > BINARY_WARN_SIZE:
            return [("WARN", f"Large binary file ({filepath.stat().st_size // 1024}KB) — review manually")]
        return []  # Small binaries are fine

    if is_binary(filepath):
        return []  # True binary with no known ext is fine

    try:
        text = filepath.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return [("WARN", "Could not read as text")]

    if not text.strip():
        return []

    lines = text.split("\n")
    for lineno, line in enumerate(lines, 1):
        stripped = line.strip()
        if not stripped:
            continue
        for pattern, severity, desc in PATTERNS:
            if re.search(pattern, stripped):
                findings.append((severity, f"L{lineno}: {desc} — {stripped[:100]}"))

    return findings


def scan_skill(skill_path, verbose=False):
    """Scan an entire skill directory. Returns (skill_name, findings, risk_level)."""
    skill_path = Path(skill_path)
    if not skill_path.is_dir():
        return (skill_path.name, [("ERROR", "Not a directory or doesn't exist")], "ERROR")

    all_findings = []
    walked = 0

    for root, dirs, files in os.walk(skill_path):
        root_path = Path(root)
        # Skip directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]

        for fname in files:
            if fname in SKIP_FILES:
                continue
            fpath = root_path / fname
            findings = scan_file(fpath)
            walked += 1
            for sev, msg in findings:
                rel = fpath.relative_to(skill_path)
                all_findings.append((sev, f"{rel}: {msg}"))
                if verbose:
                    print(f"  {sev:8s} | {rel}: {msg}")

    # Determine overall risk level
    severities = [s for s, _ in all_findings]
    if any(s == "HIGH" or s == "ERROR" for s in severities):
        risk = "HIGH"
    elif any(s == "MEDIUM" for s in severities):
        risk = "MEDIUM"
    elif any(s == "LOW" for s in severities):
        risk = "LOW"
    else:
        risk = "SAFE"

    return (skill_path.name, all_findings, risk, walked)


def print_report(name, findings, risk, walked):
    """Pretty-print scan results."""
    print(f"\n{'='*60}")
    print(f"  Skill: {BOLD(name)}")
    print(f"  Files scanned: {walked}")
    print(f"  Findings: {len(findings)}")
    print(f"  Risk Level: ", end="")
    if risk == "HIGH":
        print(RED(risk))
    elif risk == "MEDIUM":
        print(YELLOW(risk))
    elif risk == "LOW":
        print(f"\033[93m{risk}\033[0m")
    else:
        print(GREEN(risk))
    print(f"{'='*60}")

    if not findings:
        print(f"  {GREEN('✓ No issues found')}")
        return

    # Group by severity
    for sev in ["HIGH", "MEDIUM", "LOW", "WARN"]:
        items = [m for s, m in findings if s == sev]
        if not items:
            continue
        sev_color = RED if sev == "HIGH" else YELLOW if sev in ("MEDIUM", "WARN") else lambda s: s
        print(f"\n  {sev_color(BOLD(sev))}:")
        for item in items:
            print(f"    • {item}")

    if risk == "HIGH":
        print(f"\n  {RED('⚠ BLOCKED — Resolve HIGH issues before using this skill.')}")
    elif risk == "MEDIUM":
        print(f"\n  {YELLOW('⚠ Review MEDIUM items — ask user before proceeding.')}")


# ──────────────────────────────────────────────────────────────────────────
# Commands
# ──────────────────────────────────────────────────────────────────────────

def cmd_scan(path):
    """Scan a single skill path."""
    p = Path(path)
    if not p.exists():
        print(f"{RED('Error:')} Path does not exist: {path}")
        sys.exit(1)

    name, findings, risk, walked = scan_skill(p, verbose=True)
    print_report(name, findings, risk, walked)

    if risk == "HIGH":
        sys.exit(2)
    elif risk == "MEDIUM":
        sys.exit(1)
    sys.exit(0)


def cmd_check(path):
    """Quick-check a single file."""
    p = Path(path)
    if not p.is_file():
        print(f"{RED('Error:')} Not a file: {path}")
        sys.exit(1)

    print(f"\n{CYAN('Quick check:')} {p.name}")
    findings = scan_file(p)
    if not findings:
        print(f"  {GREEN('✓ Clean')}")
        sys.exit(0)

    for sev, msg in findings:
        sev_color = RED if sev == "HIGH" else YELLOW
        print(f"  {sev_color(sev)}: {msg}")

    if any(s == "HIGH" for s, _ in findings):
        sys.exit(2)
    sys.exit(0)


def cmd_scan_all():
    """Scan all installed skills across known skill directories."""
    found_any = False
    high_count = 0
    med_count = 0
    safe_count = 0

    for root in SKILL_ROOTS:
        if not root.is_dir():
            continue
        print(f"\n{CYAN('Scanning:')} {root}")
        for skill_dir in sorted(root.iterdir()):
            if not skill_dir.is_dir():
                continue
            skill_file = skill_dir / "SKILL.md"
            if not skill_file.exists():
                continue  # Not a valid skill directory

            found_any = True
            name, findings, risk, walked = scan_skill(skill_dir)
            if findings:
                print_report(name, findings, risk, walked)

            if risk == "HIGH":
                high_count += 1
            elif risk == "MEDIUM" or risk == "LOW":
                med_count += 1
            else:
                safe_count += 1

    if not found_any:
        print(f"\n{YELLOW('No skill directories found.')}")
        return

    print(f"\n{'='*60}")
    print(f"  Scan complete:")
    print(f"    {GREEN(f'✓ Safe: {safe_count}')}")
    print(f"    {YELLOW(f'⚠ Needs review: {med_count}')}")
    print(f"    {RED(f'✗ Blocked: {high_count}')}")
    print(f"{'='*60}")


# ──────────────────────────────────────────────────────────────────────────
# Entry Point
# ──────────────────────────────────────────────────────────────────────────

def main():
    print(f"\n{CYAN('SkillGuard v' + GUARD_VERSION)} — Offline security scanner")
    print(f"  {CYAN('No data leaves your machine.')}")
    print()

    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)

    cmd = sys.argv[1]
    if cmd == "scan":
        if len(sys.argv) < 3:
            print("Usage: scanner.py scan <skill_path>")
            sys.exit(1)
        cmd_scan(sys.argv[2])
    elif cmd == "scan-all":
        cmd_scan_all()
    elif cmd == "check":
        if len(sys.argv) < 3:
            print("Usage: scanner.py check <file_path>")
            sys.exit(1)
        cmd_check(sys.argv[2])
    else:
        print(f"Unknown command: {cmd}")
        print("Available: scan <path>, scan-all, check <file>")
        sys.exit(1)


if __name__ == "__main__":
    main()
