# Quip MCP

Connect your Quip workspace to Claude Desktop — lets Claude read your Quip documents and spreadsheets directly.

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
1. Ask for your Quip API token
2. Create a local storage folder
3. Auto-configure Claude Desktop

**Get your Quip token from:** https://gofynd.quip.com/dev/token

---

## After Setup

1. Quit Claude Desktop completely
2. Reopen it
3. Look for `quip` in the MCP tools list

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
| Claude Desktop | Required | Required |
| Shell | Terminal (built-in) | PowerShell (built-in) |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `node: command not found` | Install Node.js 18+ from nodejs.org |
| MCP not showing in Claude | Fully quit & reopen Claude Desktop |
| Token error | Re-generate token at gofynd.quip.com/dev/token |
| Config already exists warning | Manually merge `quip_mcp_config.json` into your existing Claude config |

---

## Source

- Setup scripts: https://github.com/yashj645/quip-mcp
- MCP server package: https://www.npmjs.com/package/@yashj645/quip-mcp-server
- Server source code: https://github.com/yashj645/quip-mcp-server
