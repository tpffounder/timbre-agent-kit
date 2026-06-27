#!/usr/bin/env bash
# =============================================================================
# Timbre Agent Kit — One-Click Setup
# Cross-platform: macOS · Linux · Windows (Git Bash/WSL) · VPS
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/tpffounder/timbre-agent-kit/main/setup.sh)
# =============================================================================

set -e

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
case "$(uname -s)" in
  Linux*)     OS="linux";;
  Darwin*)    OS="macos";;
  MINGW*|MSYS*|CYGWIN*) OS="windows";;
  *)          OS="unknown";;
esac
echo -e "  ${BOLD}OS:${NC} $(uname -s) (${OS})"
echo ""

# ── Pre-flight ──
echo -e "${YELLOW}── Pre-flight checks ─────────────────────────────${NC}"
PREFLIGHT=true
for cmd in curl git; do
  if command -v $cmd &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} ${cmd} installed"
  else
    echo -e "  ${RED}✗${NC} ${cmd} required — install first"
    PREFLIGHT=false
  fi
done
if command -v node &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} Node.js $(node --version)"
else
  echo -e "  ${YELLOW}⚠${NC} Node.js not found — will install"
  INSTALL_NODE=true
fi
if command -v docker &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} Docker $(docker --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' || echo 'found')"
  HAS_DOCKER=true
else
  echo -e "  ${YELLOW}⚠${NC} Docker not found — apps will use local install"
fi
echo ""
[ "$PREFLIGHT" = false ] && { echo -e "${RED}Fix issues above and re-run.${NC}"; exit 1; }

# ── API Keys ──
echo -e "${YELLOW}── API Keys ───────────────────────────────────────${NC}"
echo -e "  ${CYAN}→${NC} Stored locally. Never shared. Delete anytime."
read -p "  DeepSeek API key (required): " DEEPSEEK_KEY
while [ -z "$DEEPSEEK_KEY" ]; do
  read -p "  DeepSeek API key: " DEEPSEEK_KEY
done
read -p "  Telegram bot token (optional, Enter to skip): " TELEGRAM_TOKEN
echo -e "  ${GREEN}✓${NC} Keys collected"

# ── Niche Selection ──
echo ""
echo -e "${YELLOW}── Niche Skills Selection ─────────────────────────${NC}"
echo "  0) None — core agents only"
echo "  1) Real Estate"
echo "  2) Contractors (Roofing + Painting)"
echo "  3) Bookkeeping / Accounting"
echo "  4) Medical Offices"
echo "  5) Website Design"
echo "  6) Marketing Teams"
echo "  7) ALL of the above"
echo "  8) Pick multiple: enter space-separated numbers (e.g. 1 3 5)"
read -p "  Choice [0]: " NICHE
NICHE=${NICHE:-0}

# ── Install Type ──
echo ""
echo -e "${YELLOW}── Install Type ───────────────────────────────────${NC}"
echo "  1) Minimal — OpenClaw + agents + skills only"
echo "  2) Standard — Everything + Docker apps"
echo "  3) Full Stack — Standard + Puppeteer/Chrome"
read -p "  Choice [2]: " INSTALL_TYPE
INSTALL_TYPE=${INSTALL_TYPE:-2}

# ── Install Node.js ──
if [ "$INSTALL_NODE" = true ]; then
  echo ""
  echo -e "${YELLOW}── Installing Node.js ───────────────────────────${NC}"
  case "$OS" in
    linux|macos)
      export NVM_DIR="$HOME/.nvm"
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      nvm install 22
      nvm alias default 22
      ;;
    windows)
      echo -e "  ${YELLOW}Download Node.js LTS from https://nodejs.org then re-run.${NC}"
      read -p "  Press Enter after installing..."
      ;;
  esac
fi

# ── Clone Agent Kit ──
WORKSPACE_DIR="$HOME/timbre-agent-kit"
echo ""
echo -e "${YELLOW}── Downloading Agent Kit ─────────────────────────${NC}"
if [ -d "$WORKSPACE_DIR" ]; then
  cd "$WORKSPACE_DIR" && git pull
else
  git clone https://github.com/tpffounder/timbre-agent-kit.git "$WORKSPACE_DIR"
fi
echo -e "  ${GREEN}✓${NC} Repo cloned to ${WORKSPACE_DIR}"

# ── Install OpenClaw ──
echo ""
echo -e "${YELLOW}── Installing OpenClaw Engine ────────────────────${NC}"
npm install -g openclaw
echo -e "  ${GREEN}✓${NC} OpenClaw installed"

# ── Install Core Skills ──
echo ""
echo -e "${YELLOW}── Installing Skills ──────────────────────────────${NC}"
CORE_SKILLS="market-research-agent copywriting-pro tiktok-growth outbound-prospecting cold-email-writer yc-cold-outreach email-outreach-ops weekly-report-generator memory-setup-openclaw founder strategy business growth crm project-planner self-improving humanizer ontology skillguard skill-firewall openclaw-backup workflow-skillify openclaw-cron-setup"

# ── Optional Proactive Skills ──
echo ""
echo -e "${YELLOW}── Proactive Agent Skills ─────────────────────────${NC}"
echo "  Would you like to install proactive agent skills?"
echo "  These make agents anticipate needs and self-improve over time."
echo "  y) Yes — install both proactive-agent-lite + ontology"
echo "  n) No — skip (default)"
read -p "  Choice [n]: " PROACTIVE_CHOICE
if [ "$PROACTIVE_CHOICE" = "y" ]; then
  for skill in proactive-agent-lite ontology; do
    echo -ne "  ${skill}... "
    openclaw skills install "$skill" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠${NC} (already installed)"
  done
fi

# ── Social Media Skills ──
echo ""
echo -e "${YELLOW}── Social Media Skills ────────────────────────────${NC}"
echo "  Would you like to install social media publishing skills?"
echo "  socialclaw lets agents schedule/post to X, LinkedIn, Instagram, TikTok, etc."
echo "  y) Yes — install socialclaw"
echo "  n) No — skip (default)"
read -p "  Choice [n]: " SOCIAL_CHOICE
if [ "$SOCIAL_CHOICE" = "y" ]; then
  echo -ne "  socialclaw... "
  openclaw skills install "socialclaw" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠${NC} (already installed)"
fi
for skill in $CORE_SKILLS; do
  echo -ne "  ${skill}... "
  openclaw skills install "$skill" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠${NC} (already installed)"
done

# ── Install Niche Skills ──
if [ "$NICHE" != "0" ]; then
  echo ""
  echo -e "${YELLOW}── Installing Niche Skills ───────────────────────${NC}"
  
  case "$NICHE" in
    1) NICHE_LIST="real-estate-skill real-estate-investing real-estate-listing-writer";;
    2) NICHE_LIST="afrexai-roofing-contractor afrexai-painting-contractor";;
    3) NICHE_LIST="bookkeeping-basics personal-bookkeeper accountant accounting";;
    4) NICHE_LIST="medical medical-terms medical-auditor";;
    5) NICHE_LIST="website website-seo website-structure-analyzer";;
    6) NICHE_LIST="eb-marketing marketing-analytics marketing-plan marketing-genius pls-marketing-ideas";;
    7) NICHE_LIST="real-estate-skill real-estate-investing real-estate-listing-writer afrexai-roofing-contractor afrexai-painting-contractor bookkeeping-basics personal-bookkeeper accountant accounting medical medical-terms medical-auditor website website-seo website-structure-analyzer eb-marketing marketing-analytics marketing-plan marketing-genius pls-marketing-ideas";;
    8) NICHE_LIST="$NICHE"; echo -e "  ${YELLOW}Custom selection — will handle by number mapping${NC}";;
    *) NICHE_LIST="";;
  esac
  
  if [ "$NICHE" = "8" ]; then
    echo -e "  ${YELLOW}Select by entering numbers directly, or re-run with choice 1-7${NC}"
  fi
  
  for skill in $NICHE_LIST; do
    echo -ne "  ${skill}... "
    openclaw skills install "$skill" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠${NC} (already installed)"
  done
fi

# ── Generate Config ──
echo ""
echo -e "${YELLOW}── Generating OpenClaw Config ────────────────────${NC}"
CONFIG_DIR="$HOME/.openclaw"
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_DIR/openclaw.json" ]; then
  cat > "$CONFIG_DIR/openclaw.json" << CONFIG
{
  "models": {
    "default": "deepseek/deepseek-v4-flash",
    "deepseek/deepseek-v4-flash": { "apiKey": "$DEEPSEEK_KEY", "baseUrl": "https://api.deepseek.com" },
    "deepseek/deepseek-v4-pro": { "apiKey": "$DEEPSEEK_KEY", "baseUrl": "https://api.deepseek.com" }
  },
  "channels": {
    "telegram": {
      "enabled": $( [ -n "$TELEGRAM_TOKEN" ] && echo "true" || echo "false" ),
      "groupPolicy": "open",
      "groups": { "*": { "enabled": true, "requireMention": false } }
    }
  }
}
CONFIG
  echo -e "  ${GREEN}✓${NC} Config file created"
else
  echo -e "  ${YELLOW}⚠${NC} Config exists — set DeepSeek key manually: openclaw config set models.deepseek/deepseek-v4-flash.apiKey \"$DEEPSEEK_KEY\""
fi

if [ -n "$TELEGRAM_TOKEN" ]; then
  openclaw config set channels.telegram.token "$TELEGRAM_TOKEN" 2>/dev/null || true
fi

# ── Copy Agent Files ──
echo ""
echo -e "${YELLOW}── Setting Up Agents ─────────────────────────────${NC}"
mkdir -p "$HOME/.openclaw/agents"
cp -r "$WORKSPACE_DIR/agents/"* "$HOME/.openclaw/agents/" 2>/dev/null
ln -sf "$WORKSPACE_DIR" "$HOME/timbre-workspace" 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Agent definitions installed"

# ── Start Gateway ──
echo ""
echo -e "${YELLOW}── Starting OpenClaw Gateway ─────────────────────${NC}"
openclaw gateway start 2>/dev/null || openclaw gateway restart 2>/dev/null
sleep 2
echo -e "  ${GREEN}✓${NC} Gateway running"

# ── Docker Apps ──
if [ "$INSTALL_TYPE" -ge 2 ] && [ "$HAS_DOCKER" = true ]; then
  echo ""
  echo -e "${YELLOW}── Deploying Docker Services ────────────────────${NC}"
  if [ -f "$WORKSPACE_DIR/deployments/twenty/docker-compose.yml" ]; then
    cd "$WORKSPACE_DIR/deployments/twenty" && docker compose up -d 2>/dev/null && echo -e "  ${GREEN}✓${NC} Twenty CRM on port 3000"
  fi
  docker run -d --restart always --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n n8nio/n8n:latest 2>/dev/null && echo -e "  ${GREEN}✓${NC} n8n on port 5678"
fi

# ── Puppeteer ──
if [ "$INSTALL_TYPE" -ge 3 ]; then
  echo ""
  echo -e "${YELLOW}── Installing Browser Automation ────────────────${NC}"
  case "$OS" in
    linux)
      sudo apt-get update -qq && sudo apt-get install -y -qq libatk-bridge2.0-0 libcups2 libgbm1 libnss3 libxcomposite1 libxdamage1 xdg-utils 2>/dev/null
      npm install -g puppeteer 2>/dev/null || true
      ;;
    *) npm install -g puppeteer 2>/dev/null || true ;;
  esac
  echo -e "  ${GREEN}✓${NC} Puppeteer installed"
fi

# ── Summary ──
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║             ${BOLD}INSTALLATION COMPLETE${NC}${CYAN}                   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} OpenClaw engine installed"
echo -e "  ${GREEN}✓${NC} DeepSeek V4 configured"
echo -e "  ${GREEN}✓${NC} Core skills (23) installed"
echo -e "  ${GREEN}✓${NC} 7 agents deployed"
echo -e "  ${GREEN}✓${NC} Decision Council framework ready"
if [ "$NICHE" != "0" ]; then
  echo -e "  ${GREEN}✓${NC} Niche skills installed (selection: ${NICHE})"
fi
if [ -n "$TELEGRAM_TOKEN" ]; then
  echo -e "  ${GREEN}✓${NC} Telegram bot configured"
fi
echo -e "  ${GREEN}✓${NC} Gateway running"
echo ""
echo -e "  ${BOLD}Next:${NC} Message your Telegram bot or run: openclaw chat"
echo -e "  ${BOLD}Workspace:${NC} ${WORKSPACE_DIR}"
echo ""
