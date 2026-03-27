# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Monorepo with three components that work together:
- **terminal-socket** (Node.js) — Bridge service connecting Flutter clients to a Firebird database via WebSocket
- **shop_blink** (Flutter) — E-commerce mobile app (APK) with barcode scanning
- **blink_pcp_novo** (Flutter) — Production control panel (Flutter web)

All user-facing text, logs, and comments are in **Brazilian Portuguese**.

## Running the Node.js Service

```bash
npm start                    # Run directly
pm2 start app.js --name terminal-socket  # Via PM2
npm run install-service      # Install as Windows service
npm run uninstall-service    # Remove Windows service
```

PM2 config: `ecosystem.config.js` (max 2GB memory, 10 max restarts, 5s restart delay).

## Building Flutter Apps

```bash
cd shop_blink && flutter pub get && flutter build apk    # Android APK
cd blink_pcp_novo && flutter pub get && flutter build web # Web app
```

## Architecture

### Communication Flow

```
Flutter Apps  →  WebSocket Server (138.204.224.235:9090)  →  terminal-socket  →  Firebird DB
                 (visual.tigoo.com.br:9001/socket)
```

1. Flutter apps send HTTP requests with header `socket_client: {terminal_token}` to a WebSocket relay server
2. The relay forwards messages to the Node.js service via WebSocket (`ws://SOCKET_URL`)
3. Node.js routes messages by `type`: `query` → executes SQL on Firebird, `status` → returns system info
4. Responses return through the same WebSocket path as JSON: `{ api_status: 1, api_message: 'sucess', data: [...] }`

### Node.js Service Components

- **app.js** — Entry point, health monitor, request handlers (`handleQueryRequest`, `handleStatusRequest`)
- **services/database.js** — Firebird connection (dedicated connections, no pool). Handles Latin-1→UTF-8 encoding for Portuguese characters. Type inference for SELECT results.
- **services/websocket.js** — WebSocket client with auto-reconnect (5s delay). Registers with `{ type: 'initial', uuid: terminalToken }`
- **services/http-server.js** — Express server on port 7778 (env `API_PORT`). Single health-check endpoint `GET /`
- **utils/logger.js** — Logs to console, file (`log_terminal.txt`), and Windows Event Viewer

### Terminal Token

The service retrieves `SECURE_TOKEN` from the Firebird `parametro` table at startup. This token identifies the terminal to the WebSocket relay server. Flutter apps must send this token in their requests.

### Flutter App Environments

Both apps use `lib/api/config/environment.dart` to switch between developer/production endpoints. **blink_pcp_novo has a hardcoded token** in `cafe_api.dart` — this should be made configurable.

## Environment Variables (.env)

| Variable | Default | Purpose |
|----------|---------|---------|
| FB_SERVER | localhost | Firebird server |
| FB_DATABASE | — | Firebird database file path |
| FB_USER | SYSDBA | Firebird user |
| FB_PASSWORD | masterkey | Firebird password |
| FB_PORT | 3050 | Firebird port |
| SOCKET_URL | 138.204.224.235:9090 | WebSocket relay server |
| API_PORT | 7778 | HTTP health-check port |
| LOG_LEVEL | info | Logging verbosity |

## Key Behaviors

- **Health monitor** checks WebSocket connection every 30 seconds; only reconnects if actually disconnected (not on inactivity)
- **Database encoding**: Firebird returns Latin-1; `database.js` converts to UTF-8 using iconv-lite
- **Type inference**: `database.js` analyzes SELECT columns — fields matching `tam##` are forced to string, `e##` to number, `id_produto` always string (preserves leading zeros)
- **Date normalization**: DD/MM/YYYY dates from Firebird are converted to YYYY-MM-DD
- Both Flutter apps use `HttpOverrides` to accept self-signed SSL certificates
