# Quip MCP Server Setup

Connect your Quip workspace (`gofynd.quip.com`) to Claude Desktop via MCP.

---

## Quick Start

### 1. Create the folder & download setup files

```bash
mkdir -p ~/Documents/quip-mcp
cd ~/Documents/quip-mcp
```

Copy `setup.sh` and `README.md` into this folder, then run:

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Ask for your Quip API token
- Clone the TypeScript MCP server from GitHub
- Install dependencies & build the project
- Create a `.env` config file
- Generate and apply the Claude Desktop config
- Run a smoke test to verify everything works

---

## Get Your Quip Token

1. Open: **https://gofynd.quip.com/dev/token**
2. Click **"Get Personal Access Token"**
3. Copy the token — paste it when `setup.sh` asks

---

## Manual Steps (if you prefer not to use the script)

### Clone & build

```bash
cd ~/Documents/quip-mcp
git clone https://github.com/zxkane/quip-mcp-server-typescript.git .
npm install
npm run build
mkdir -p storage
```

### Create `.env`

```env
QUIP_TOKEN=your_token_here
QUIP_BASE_URL=https://platform.quip.com
QUIP_STORAGE_PATH=/Users/YOUR_USERNAME/Documents/quip-mcp/storage
```

### Configure Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "quip": {
      "command": "node",
      "args": [
        "/Users/YOUR_USERNAME/Documents/quip-mcp/dist/index.js",
        "--storage-path",
        "/Users/YOUR_USERNAME/Documents/quip-mcp/storage",
        "--file-protocol"
      ],
      "env": {
        "QUIP_TOKEN": "your_token_here"
      }
    }
  }
}
```

> Replace `YOUR_USERNAME` with the output of `whoami`

---

## Using the MCP Server in Claude

The main tool is `quip_read_spreadsheet`. Find the **Thread ID** from your Quip URL:

```
https://gofynd.quip.com/AbCdEfGhIjKl
                         ^^^^^^^^^^^^
                         This is the Thread ID
```

Then ask Claude:

- *"Read the Quip spreadsheet with thread ID AbCdEfGhIjKl"*
- *"Read the 'Budget' sheet from Quip thread AbCdEfGhIjKl"*

---

## Project Structure (after setup)

```
~/Documents/quip-mcp/
├── setup.sh                         ← Run this first
├── README.md                        ← This file
├── .env                             ← Your credentials (auto-created)
├── storage/                         ← Downloaded CSV files go here
├── dist/                            ← Compiled server (auto-built)
│   └── index.js                     ← Main server entry point
├── src/                             ← TypeScript source
├── package.json
└── claude_desktop_config_snippet.json  ← Claude config (auto-created)
```

---

## Troubleshooting

| Problem | Fix |
|--------|-----|
| `node: command not found` | Install Node.js 18+ from nodejs.org |
| `git: command not found` | Run `xcode-select --install` |
| MCP not showing in Claude | Fully quit & reopen Claude Desktop |
| Token error from Quip | Re-generate token at gofynd.quip.com/dev/token |
| Build fails | Run `npm install` then `npm run build` again |

---

## Verify Setup

```bash
cd ~/Documents/quip-mcp

# Test with mock data (no real token needed)
node dist/index.js --mock --storage-path ./storage

# Test with your real token
node dist/index.js --storage-path ./storage
```

Press `Ctrl+C` to stop. No errors = you're good to go!