# Payments Service

## Endpoints
- GET /health
- GET /payments?listingId=&status=
- GET /payments/:id
- POST /payments
- POST /payments/:id/hold
- POST /payments/:id/release
- POST /payments/:id/refund
- POST /payments/:id/fail

## Environment
- DATABASE_URL
- PORT (default: 4004)

## Local dev
- docker compose up --build
- docker compose exec payments npm run migrate

## Example payload
```json
{
  "listingId": "l-001",
  "buyerId": "u-123",
  "amount": 420,
  "holdUntil": "2024-08-03T12:00:00.000Z"
}
```
