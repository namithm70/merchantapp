# Messaging Service

## Endpoints
- GET /health
- GET /threads
- POST /threads
- GET /threads/:id/messages
- POST /threads/:id/messages
- POST /threads/:id/block
- POST /threads/:id/report

## WebSocket
- Connect to `ws://<host>`
- Receives `{ type: "message", payload: { ... } }` on new messages.

## Environment
- DATABASE_URL
- PORT (default: 4002)

## Local dev
- docker compose up --build
- docker compose exec messaging npm run migrate
