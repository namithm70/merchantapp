# Listings Service

## Endpoints
- GET /health
- GET /listings?status=&condition=&category=
- GET /listings/:id
- POST /listings
- PATCH /listings/:id
- POST /listings/:id/publish
- POST /listings/:id/archive

## Environment
- DATABASE_URL (e.g. postgres://marketplace:marketplace@postgres:5432/listings)
- PORT (default: 4001)

## Local dev (with Docker Compose)
From repo root:
- docker compose up --build
- docker compose exec listings npm run migrate

## Example payload
```json
{
  "title": "Studio Monitor Pair",
  "category": "Electronics",
  "condition": "Like New",
  "price": 420,
  "location": "Austin, TX",
  "description": "Pair of monitors with cables"
}
```
