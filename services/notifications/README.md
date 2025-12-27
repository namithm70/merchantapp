# Notifications Service

## Endpoints
- GET /health
- GET /preferences/:userId
- POST /preferences
- POST /notifications
- GET /notifications?userId=&status=
- PATCH /notifications/:id

## Environment
- DATABASE_URL
- PORT (default: 4006)

## Local dev
- docker compose up --build
- docker compose exec notifications npm run migrate

## Example payload
```json
{
  "userId": "u-123",
  "channel": "push",
  "title": "New offer",
  "body": "You received an offer for $395"
}
```
