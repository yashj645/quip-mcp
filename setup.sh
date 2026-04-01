#!/bin/bash

# ============================================================
# Quip MCP Server - Setup Script
# Run this script to set up Quip MCP on your machine
# ============================================================

set -e  # Exit on any error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log()    { echo -e "${GREEN}[✔]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✘]${NC} $1"; exit 1; }

echo ""
echo "=================================================="
echo "   Quip MCP Server Setup"
echo "=================================================="
echo ""

# ── Step 1: Check prerequisites ──────────────────────────
log "Checking prerequisites..."

if ! command -v node &>/dev/null; then
  error "Node.js not found. Install it from https://nodejs.org (v18+)"
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  error "Node.js v18+ required. Current: $(node -v)"
fi
log "Node.js $(node -v) found"

if ! command -v npx &>/dev/null; then
  error "npx not found. It comes with Node.js — please reinstall Node.js."
fi
log "npx found"

# ── Check Claude Desktop ──────────────────────────────────
if [ ! -d "/Applications/Claude.app" ]; then
  warn "Claude Desktop not found on this machine."
  warn "Download it from: https://claude.ai/download"
  warn "You can finish this setup now and install Claude Desktop later."
  echo ""
  read -rp "Continue setup anyway? (y/n): " CONTINUE
  if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
    echo "Setup cancelled. Install Claude Desktop first, then re-run this script."
    exit 0
  fi
else
  log "Claude Desktop found"
fi

# ── Step 2: Get Quip token ────────────────────────────────
echo ""
warn "You'll need your Quip API token."
warn "Get it from: https://gofynd.quip.com/dev/token"
echo ""
read -rp "Paste your Quip API token here: " QUIP_TOKEN

if [ -z "$QUIP_TOKEN" ]; then
  error "Token cannot be empty."
fi
log "Token received"

# ── Step 3: Create storage folder ────────────────────────
echo ""
STORAGE_PATH="$HOME/.quip-mcp/storage"
mkdir -p "$STORAGE_PATH"
log "Storage folder created at $STORAGE_PATH"

# ── Step 4: Verify package is accessible ─────────────────
echo ""
log "Verifying @yashj645/quip-mcp-server is available on npm..."
PKG_VERSION=$(npm view @yashj645/quip-mcp-server version 2>/dev/null || true)
if [ -z "$PKG_VERSION" ]; then
  warn "Could not verify package on npm. Make sure it has been published."
else
  log "Found package version: $PKG_VERSION"
fi

# ── Step 5: Write Claude Desktop config snippet ───────────
cat > quip_mcp_config.json << EOF
{
  "mcpServers": {
    "quip": {
      "command": "npx",
      "args": [
        "-y",
        "@yashj645/quip-mcp-server",
        "--storage-path",
        "${STORAGE_PATH}",
        "--file-protocol"
      ],
      "env": {
        "QUIP_TOKEN": "${QUIP_TOKEN}"
      }
    }
  }
}
EOF

log "Config snippet saved → quip_mcp_config.json"

# ── Step 6: Apply Claude Desktop config ───────────────────
echo ""
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -f "$CLAUDE_CONFIG" ]; then
  warn "Claude Desktop config already exists at:"
  warn "  $CLAUDE_CONFIG"
  warn "Please manually merge the snippet from quip_mcp_config.json"
  warn "into that file under the \"mcpServers\" key."
else
  mkdir -p "$HOME/Library/Application Support/Claude"
  cp quip_mcp_config.json "$CLAUDE_CONFIG"
  log "Claude Desktop config written automatically!"
fi

# ── Step 7: Apply Claude Code config ──────────────────────
echo ""
CLAUDE_CODE_CONFIG="$HOME/.claude.json"

if command -v claude &>/dev/null || [ -f "$CLAUDE_CODE_CONFIG" ]; then
  log "Claude Code detected — updating $CLAUDE_CODE_CONFIG..."

  QUIP_ENTRY="{\"type\":\"stdio\",\"command\":\"npx\",\"args\":[\"-y\",\"@yashj645/quip-mcp-server\",\"--storage-path\",\"${STORAGE_PATH}\",\"--file-protocol\"],\"env\":{\"QUIP_TOKEN\":\"${QUIP_TOKEN}\"}}"

  python3 -c "
import json, os, sys
config_path = os.path.expanduser('~/.claude.json')
entry = json.loads(sys.argv[1])
config = {}
if os.path.exists(config_path):
    with open(config_path) as f:
        config = json.load(f)
config.setdefault('mcpServers', {})['quip'] = entry
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
" "$QUIP_ENTRY"

  log "Claude Code config updated!"
else
  warn "Claude Code not found — skipping Claude Code config."
  warn "If you install Claude Code later, run this script again."
fi

# ── Done ──────────────────────────────────────────────────
echo ""
echo "=================================================="
echo -e "${GREEN}  Setup Complete!${NC}"
echo "=================================================="
echo ""
echo "  Next steps:"
echo "  1. Quit Claude Desktop completely"
echo "  2. Reopen Claude Desktop"
echo "  3. Look for 'quip' in the MCP tools list"
echo ""
echo "  To read a Quip doc, ask Claude:"
echo "  'Read the Quip document with thread ID <ID>'"
echo "  'Read the Quip spreadsheet with thread ID <ID>'"
echo ""
echo "  (Thread ID = the part after gofynd.quip.com/ in the URL)"
echo ""
