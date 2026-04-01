# Quip MCP

Connect your Quip workspace to Claude — lets Claude read your Quip documents and spreadsheets directly.

Works with both **Claude Desktop** and **Claude Code**.

---

## Setup

### Mac / Linux

Open Terminal and run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yashj645/quip-mcp/main/setup.sh)
```

### Windows

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/yashj645/quip-mcp/main/setup.ps1 | iex
```

---

The script will:
1. Check for Node.js (v18+)
2. Check for Claude Desktop — prompts to install if missing
3. Ask for your Quip API token
4. Create a local storage folder
5. Configure **Claude Desktop** automatically
6. Configure **Claude Code** automatically (if installed)

**Get your Quip token from:** https://gofynd.quip.com/dev/token

---

## After Setup

**Claude Desktop:**
1. Quit Claude Desktop completely
2. Reopen it
3. Look for `quip` in the MCP tools list

**Claude Code:**
- Quip is available immediately in your next session (or run `/mcp` to reconnect)

Then ask Claude:
- *"Read the Quip document with thread ID `<ID>`"*
- *"Read the Quip spreadsheet with thread ID `<ID>`"*

**Finding the Thread ID:** It's the part of the URL right after `gofynd.quip.com/`
Example: `https://gofynd.quip.com/S6eaArZiT0xy/Doc-Title` → ID is `S6eaArZiT0xy`

---

## Requirements

| | Mac | Windows |
|---|---|---|
| Node.js v18+ | [nodejs.org](https://nodejs.org) | [nodejs.org](https://nodejs.org) |
| Claude Desktop | [claude.ai/download](https://claude.ai/download) | [claude.ai/download](https://claude.ai/download) |
| Claude Code | Optional | Optional |
| Shell | Terminal (built-in) | PowerShell (built-in) |

---

## What Gets Configured

| App | Config file |
|---|---|
| Claude Desktop (Mac) | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Claude Desktop (Windows) | `%APPDATA%\Claude\claude_desktop_config.json` |
| Claude Code (Mac/Linux) | `~/.claude.json` |
| Claude Code (Windows) | `%USERPROFILE%\.claude.json` |

If Claude Code is not installed at the time of setup, just re-run the script after installing it.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `node: command not found` | Install Node.js 18+ from [nodejs.org](https://nodejs.org) |
| Claude Desktop not found | Download from [claude.ai/download](https://claude.ai/download), then re-run |
| Quip not showing in Claude Desktop | Fully quit and reopen Claude Desktop |
| Quip not showing in Claude Code | Run `/mcp` to reconnect, or start a new session |
| Token error | Re-generate token at gofynd.quip.com/dev/token |
| Config already exists warning | Manually merge `quip_mcp_config.json` into your existing Claude config |

---

## Source

- Setup scripts: https://github.com/yashj645/quip-mcp
- MCP server package: https://www.npmjs.com/package/@yashj645/quip-mcp-server
- Server source code: https://github.com/yashj645/quip-mcp-server
