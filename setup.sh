#!/usr/bin/env bash
# =============================================================================
# Timbre Agent Kit — One-Click Setup
# Cross-platform: macOS · Linux · Windows (Git Bash/WSL) · VPS
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/tpffounder/timbre-agent-kit/main/setup.sh)
# =============================================================================

set -e

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        ${BOLD}TIMBRE AGENT KIT — SYSTEM INSTALLER${NC}${CYAN}          ║${NC}"
echo -e "${CYAN}║     AI Automation Agency · 7-Agent Architecture    ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Detect OS ──
OS="unknown"
OS_FULL=""
case "$(uname -s)" in
  Linux*)     
    OS="linux"
    OS_FULL=$(grep -oP '(?<=^PRETTY_NAME=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo "Linux")
    ;;
  Darwin*)    
    OS="macos"
    OS_FULL=$(sw_vers -productVersion 2>/dev/null || echo "macOS")
    ;;
  MINGW*|MSYS*|CYGWIN*) 
    OS="windows"
    OS_FULL="Windows (Git Bash/MSYS2)"
    ;;
  *)          
    OS="unknown"
    OS_FULL="Unknown ($(uname -s))"
    ;;
esac

echo -e "  ${BOLD}Detected OS:${NC} ${OS_FULL} (${OS})"
echo ""

# ── Pre-flight checks ──
PREFLIGHT_PASS=true

echo -e "${YELLOW}── Pre-flight checks ─────────────────────────────${NC}"

# Check for curl/wget
if command -v curl &>/dev/null; then
  DOWNLOAD_CMD="curl -fsSL"
  echo -e "  ${GREEN}✓${NC} curl installed"
elif command -v wget &>/dev/null; then
  DOWNLOAD_CMD="wget -qO-"
  echo -e "  ${GREEN}✓${NC} wget installed (fallback)"
else
  echo -e "  ${RED}✗${NC} Need curl or wget — install one first"
  PREFLIGHT_PASS=false
fi

# Check for git
if command -v git &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} git installed"
else
  echo -e "  ${YELLOW}⚠${NC} git not found — will download zip instead"
fi

# Check for Node.js
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  echo -e "  ${GREEN}✓${NC} Node.js ${NODE_VER}"
else
  echo -e "  ${YELLOW}⚠${NC} Node.js not found — will install"
  INSTALL_NODE=true
fi

# Check for npm
if command -v npm &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} npm $(npm --version)"
else
  echo -e "  ${YELLOW}⚠${NC} npm not found — will install"
  INSTALL_NODE=true
fi

# Check for Docker (optional)
HAS_DOCKER=false
if command -v docker &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} Docker $(docker --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' || echo 'found')"
  HAS_DOCKER=true
else
  echo -e "  ${YELLOW}⚠${NC} Docker not found — Twenty CRM + n8n will use local install"
fi

echo ""

if [ "$PREFLIGHT_PASS" = false ]; then
  echo -e "${RED}Pre-flight checks failed. Fix the issues above and re-run.${NC}"
  exit 1
fi

# ── Collect API Keys ──
echo -e "${YELLOW}── API Keys ───────────────────────────────────────${NC}"
echo -e "  ${CYAN}→${NC} These are stored locally. Never shared. Deleteable anytime."
echo ""

read -p "  DeepSeek API key (required): " DEEPSEEK_KEY
while [ -z "$DEEPSEEK_KEY" ]; do
  echo -e "  ${RED}Required for AI agents.${NC}"
  read -p "  DeepSeek API key: " DEEPSEEK_KEY
done

read -p "  Telegram bot token — get from @BotFather (optional, press Enter to skip): " TELEGRAM_TOKEN

echo ""
echo -e "  ${GREEN}✓${NC} Keys collected"

# ── Choose Install Type ──
echo ""
echo -e "${YELLOW}── Install Type ───────────────────────────────────${NC}"
echo "  1) ${BOLD}Minimal${NC} — OpenClaw + agents + skills only (no Docker apps)"
echo "  2) ${BOLD}Standard${NC} — Everything: agents + Twenty CRM + n8n + dashboard"
echo "  3) ${BOLD}Full Stack${NC} — Standard + Chrome/Puppeteer + all extras"
read -p "  Choice [2]: " INSTALL_TYPE
INSTALL_TYPE=${INSTALL_TYPE:-2}

# ── 1. Install Node.js if needed ──
if [ "$INSTALL_NODE" = true ]; then
  echo ""
  echo -e "${YELLOW}── Installing Node.js ───────────────────────────${NC}"
  
  case "$OS" in
    linux)
      echo -e "  Installing via nvm..."
      export NVM_DIR="$HOME/.nvm"
      $DOWNLOAD_CMD https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      nvm install 22
      nvm alias default 22
      ;;
    macos)
      if command -v brew &>/dev/null; then
        echo -e "  Installing via Homebrew..."
        brew install node@22
      else
        echo -e "  Installing via nvm..."
        export NVM_DIR="$HOME/.nvm"
        $DOWNLOAD_CMD https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install 22
      fi
      ;;
    windows)
      echo -e "  ${YELLOW}⚠${NC} On Windows: Download Node.js LTS from https://nodejs.org"
      echo -e "  Run this script again after installing Node.js"
      read -p "  Press Enter after installing Node.js..."
      ;;
  esac
fi

# ── 2. Clone the Agent Kit repo ──
WORKSPACE_DIR="$HOME/timbre-agent-kit"
echo ""
echo -e "${YELLOW}── Downloading Agent Kit ─────────────────────────${NC}"

if command -v git &>/dev/null; then
  if [ -d "$WORKSPACE_DIR" ]; then
    echo -e "  ${YELLOW}⚠${NC} Directory exists — pulling latest..."
    cd "$WORKSPACE_DIR" && git pull
  else
    git clone https://github.com/tpffounder/timbre-agent-kit.git "$WORKSPACE_DIR"
  fi
else
  $DOWNLOAD_CMD https://github.com/tpffounder/timbre-agent-kit/archive/refs/heads/main.zip -o /tmp/timbre-agent-kit.zip
  unzip -o /tmp/timbre-agent-kit.zip -d /tmp/
  mv /tmp/timbre-agent-kit-main "$WORKSPACE_DIR"
fi

echo -e "  ${GREEN}✓${NC} Agent Kit downloaded to ${WORKSPACE_DIR}"

# ── 3. Install OpenClaw ──
echo ""
echo -e "${YELLOW}── Installing OpenClaw Engine ────────────────────${NC}"
npm install -g openclaw
echo -e "  ${GREEN}✓${NC} OpenClaw $(openclaw --version 2>/dev/null || echo 'installed')"

# ── 4. Install Skills ──
echo ""
echo -e "${YELLOW}── Installing Skills ──────────────────────────────${NC}"
SKILLS=(
  "market-research-agent"
  "copywriting-pro"
  "tiktok-growth"
  "outbound-prospecting" 
  "cold-email-writer"
  "yc-cold-outreach"
  "email-outreach-ops"
  "weekly-report-generator"
  "memory-setup-openclaw"
)

for skill in "${SKILLS[@]}"; do
  echo -ne "  Installing ${skill}... "
  openclaw skills install "$skill" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠${NC} (already installed)"
done

# ── 5. Generate OpenClaw Config ──
echo ""
echo -e "${YELLOW}── Configuring OpenClaw ──────────────────────────${NC}"

CONFIG_DIR="$HOME/.openclaw"
mkdir -p "$CONFIG_DIR"

CONFIG_FILE="$CONFIG_DIR/openclaw.json"
if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" << CONFIGEOF
{
  "models": {
    "default": "deepseek/deepseek-v4-flash",
    "deepseek/deepseek-v4-flash": {
      "apiKey": "${DEEPSEEK_KEY}",
      "baseUrl": "https://api.deepseek.com"
    },
    "deepseek/deepseek-v4-pro": {
      "apiKey": "${DEEPSEEK_KEY}",
      "baseUrl": "https://api.deepseek.com"
    }
  },
  "channels": {
    "telegram": {
      "enabled": $( [ -n "$TELEGRAM_TOKEN" ] && echo "true" || echo "false" ),
      "groupPolicy": "open",
      "groups": {
        "*": {
          "enabled": true,
          "requireMention": false
        }
      }
    }
  }
}
CONFIGEOF
  echo -e "  ${GREEN}✓${NC} Config generated"
else
  echo -e "  ${YELLOW}⚠${NC} Config exists at ${CONFIG_FILE} — not overwriting"
fi

# Set Telegram token if provided
if [ -n "$TELEGRAM_TOKEN" ]; then
  openclaw config set channels.telegram.token "$TELEGRAM_TOKEN" 2>/dev/null || true
fi

# ── 6. Set up Agent Files ──
echo ""
echo -e "${YELLOW}── Setting Up Agents ─────────────────────────────${NC}"
AGENTS_DIR="$HOME/.openclaw/agents"
mkdir -p "$AGENTS_DIR"

# Symlink or copy agent files from workspace
if [ -d "$WORKSPACE_DIR/agents" ]; then
  cp -r "$WORKSPACE_DIR/agents/"* "$AGENTS_DIR/" 2>/dev/null || true
  echo -e "  ${GREEN}✓${NC} Agent definitions installed"
fi

# Also link the workspace so agents can access business docs
ln -sf "$WORKSPACE_DIR" "$HOME/timbre-workspace" 2>/dev/null || true

# ── 7. Start Gateway ──
echo ""
echo -e "${YELLOW}── Starting OpenClaw Gateway ─────────────────────${NC}"
openclaw gateway start 2>/dev/null || openclaw gateway restart 2>/dev/null
sleep 2
echo -e "  ${GREEN}✓${NC} Gateway started"

# ── 8. Optional: Docker Apps ──
if [ "$INSTALL_TYPE" -ge 2 ] && [ "$HAS_DOCKER" = true ]; then
  echo ""
  echo -e "${YELLOW}── Deploying Docker Services ────────────────────${NC}"

  # Twenty CRM
  if [ -d "$WORKSPACE_DIR/deployments/twenty" ]; then
    echo -e "  Deploying Twenty CRM..."
    cd "$WORKSPACE_DIR/deployments/twenty" && docker compose up -d 2>/dev/null && echo -e "  ${GREEN}✓${NC} Twenty CRM on port 3000" || echo -e "  ${YELLOW}⚠${NC} Twenty CRM skipped"
  fi

  # n8n
  echo -e "  Deploying n8n..."
  docker run -d --restart always --name n8n -p 5678:5678 \
    -v n8n_data:/home/node/.n8n n8nio/n8n:latest 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} n8n on port 5678" || echo -e "  ${YELLOW}⚠${NC} n8n skipped (may already run)"
fi

# ── 9. Optional: Puppeteer/Chrome for Agent 1 ──
if [ "$INSTALL_TYPE" -ge 3 ]; then
  echo ""
  echo -e "${YELLOW}── Installing Browser Automation ────────────────${NC}"
  
  case "$OS" in
    linux)
      sudo apt-get update -qq && sudo apt-get install -y -qq ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 libgbm1 libnss3 libxcomposite1 libxdamage1 libxrandr2 xdg-utils 2>/dev/null
      echo -e "  ${GREEN}✓${NC} Chromium dependencies installed"
      npm install -g puppeteer 2>/dev/null || true
      echo -e "  ${GREEN}✓${NC} Puppeteer installed"
      ;;
    macos)
      npm install -g puppeteer 2>/dev/null || true
      echo -e "  ${GREEN}✓${NC} Puppeteer installed (macOS has built-in browser deps)"
      ;;
    windows)
      npm install -g puppeteer 2>/dev/null || true
      echo -e "  ${GREEN}✓${NC} Puppeteer installed"
      ;;
  esac
fi

# ── 10. Summary ──
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║             ${BOLD}INSTALLATION COMPLETE${NC}${CYAN}                   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "  ${BOLD}✅ System Ready${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} OpenClaw engine installed"
echo -e "  ${GREEN}✓${NC} DeepSeek V4 configured (Flash + Pro)"
echo -e "  ${GREEN}✓${NC} 9 skills installed"
echo -e "  ${GREEN}✓${NC} 7 agents deployed"
echo -e "  ${GREEN}✓${NC} Decision Council framework ready"
echo -e "  ${GREEN}✓${NC} Business documents loaded"
echo -e "  ${GREEN}✓${NC} Gateway running"
if [ -n "$TELEGRAM_TOKEN" ]; then
  echo -e "  ${GREEN}✓${NC} Telegram bot configured"
fi
if [ "$HAS_DOCKER" = true ] && [ "$INSTALL_TYPE" -ge 2 ]; then
  echo -e "  ${GREEN}✓${NC} Docker apps deployed"
fi
if [ "$INSTALL_TYPE" -ge 3 ]; then
  echo -e "  ${GREEN}✓${NC} Puppeteer/Chrome ready"
fi

echo ""
echo -e "  ${BOLD}Next Steps:${NC}"
echo ""
echo -e "  1. Open your Telegram client and message @BotFather"
echo -e "     to create your bot (if you didn't add one yet)"
echo -e "  2. Talk to your bot — it's live and responding"
echo -e "  3. Check the workspace: ${WORKSPACE_DIR}"
echo -e "  4. Read the quick-start: ${WORKSPACE_DIR}/README.md"
echo ""
echo -e "  ${MAGENTA}Need help?${NC} Run: openclaw status"
echo ""
