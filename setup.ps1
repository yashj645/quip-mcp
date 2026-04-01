# ============================================================
# Quip MCP Server - Windows Setup Script (PowerShell)
# Run this from PowerShell:
#   irm https://raw.githubusercontent.com/yashj645/quip-mcp/main/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

function Log   { Write-Host "[OK] $args" -ForegroundColor Green }
function Warn  { Write-Host "[!]  $args" -ForegroundColor Yellow }
function Fail  { Write-Host "[X]  $args" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "=================================================="
Write-Host "   Quip MCP Server Setup"
Write-Host "=================================================="
Write-Host ""

# ── Step 1: Check prerequisites ──────────────────────────
Log "Checking prerequisites..."

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Fail "Node.js not found. Install it from https://nodejs.org (v18+) and rerun this script."
}

$nodeVersion = (node -v) -replace "v", "" -split "\." | Select-Object -First 1
if ([int]$nodeVersion -lt 18) {
  Fail "Node.js v18+ required. Current: $(node -v)"
}
Log "Node.js $(node -v) found"

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
  Fail "npx not found. It comes with Node.js — please reinstall Node.js."
}
Log "npx found"

# ── Check Claude Desktop ──────────────────────────────────
$CLAUDE_EXE = "$env:LOCALAPPDATA\AnthropicClaude\claude.exe"
if (-not (Test-Path $CLAUDE_EXE)) {
  Warn "Claude Desktop not found on this machine."
  Warn "Download it from: https://claude.ai/download"
  Warn "You can finish this setup now and install Claude Desktop later."
  Write-Host ""
  $CONTINUE = Read-Host "Continue setup anyway? (y/n)"
  if ($CONTINUE -ne "y" -and $CONTINUE -ne "Y") {
    Write-Host "Setup cancelled. Install Claude Desktop first, then re-run this script."
    exit 0
  }
} else {
  Log "Claude Desktop found"
}

# ── Step 2: Get Quip token ────────────────────────────────
Write-Host ""
Warn "You'll need your Quip API token."
Warn "Get it from: https://gofynd.quip.com/dev/token"
Write-Host ""
$QUIP_TOKEN = Read-Host "Paste your Quip API token here"

if ([string]::IsNullOrWhiteSpace($QUIP_TOKEN)) {
  Fail "Token cannot be empty."
}
Log "Token received"

# ── Step 3: Create storage folder ────────────────────────
Write-Host ""
$STORAGE_PATH = "$env:USERPROFILE\.quip-mcp\storage"
New-Item -ItemType Directory -Force -Path $STORAGE_PATH | Out-Null
Log "Storage folder created at $STORAGE_PATH"

# ── Step 4: Verify package is accessible ─────────────────
Write-Host ""
Log "Verifying @yashj645/quip-mcp-server is available on npm..."
$PKG_VERSION = npm view @yashj645/quip-mcp-server version 2>$null
if ([string]::IsNullOrWhiteSpace($PKG_VERSION)) {
  Warn "Could not verify package on npm. Make sure it has been published."
} else {
  Log "Found package version: $PKG_VERSION"
}

# ── Step 5: Write Claude Desktop config ──────────────────
Write-Host ""
$CLAUDE_CONFIG = "$env:APPDATA\Claude\claude_desktop_config.json"
$STORAGE_PATH_JSON = $STORAGE_PATH -replace "\\", "\\"

$CONFIG_CONTENT = @"
{
  "mcpServers": {
    "quip": {
      "command": "npx",
      "args": [
        "-y",
        "@yashj645/quip-mcp-server",
        "--storage-path",
        "$STORAGE_PATH_JSON",
        "--file-protocol"
      ],
      "env": {
        "QUIP_TOKEN": "$QUIP_TOKEN"
      }
    }
  }
}
"@

# Save snippet
$CONFIG_CONTENT | Out-File -FilePath "quip_mcp_config.json" -Encoding UTF8
Log "Config snippet saved → quip_mcp_config.json"

if (Test-Path $CLAUDE_CONFIG) {
  Warn "Claude Desktop config already exists at:"
  Warn "  $CLAUDE_CONFIG"
  Warn "Please manually merge quip_mcp_config.json into that file under `"mcpServers`"."
} else {
  $CLAUDE_DIR = Split-Path $CLAUDE_CONFIG
  New-Item -ItemType Directory -Force -Path $CLAUDE_DIR | Out-Null
  $CONFIG_CONTENT | Out-File -FilePath $CLAUDE_CONFIG -Encoding UTF8
  Log "Claude Desktop config written automatically!"
}

# ── Done ──────────────────────────────────────────────────
Write-Host ""
Write-Host "=================================================="
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "=================================================="
Write-Host ""
Write-Host "  Next steps:"
Write-Host "  1. Quit Claude Desktop completely"
Write-Host "  2. Reopen Claude Desktop"
Write-Host "  3. Look for 'quip' in the MCP tools list"
Write-Host ""
Write-Host "  To read a Quip doc, ask Claude:"
Write-Host "  'Read the Quip document with thread ID <ID>'"
Write-Host "  'Read the Quip spreadsheet with thread ID <ID>'"
Write-Host ""
Write-Host "  (Thread ID = the part after gofynd.quip.com/ in the URL)"
Write-Host ""
