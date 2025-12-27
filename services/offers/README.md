# Offers Service

## Endpoints
- GET /health
- GET /offers?listingId=&status=
- GET /offers/:id
- POST /offers
- PATCH /offers/:id

## Environment
- DATABASE_URL
- PORT (default: 4003)

## Local dev
- docker compose up --build
- docker compose exec offers npm run migrate

## Example payload
```json
{
  "listingId": "l-001",
  "threadId": "e2c5b06f-1a5b-4b66-90b0-1e7c0b665b9b",
  "amount": 395,
  "status": "pending",
  "expiresAt": "2024-08-02T12:00:00.000Z",
  "lastUpdatedBy": "buyer"
}
```
