# Disputes Service

## Endpoints
- GET /health
- GET /disputes?listingId=&status=
- GET /disputes/:id
- POST /disputes
- PATCH /disputes/:id

## Environment
- DATABASE_URL
- PORT (default: 4005)

## Local dev
- docker compose up --build
- docker compose exec disputes npm run migrate

## Example payload
```json
{
  "listingId": "l-001",
  "orderId": "o-100",
  "issueType": "Item not as described",
  "details": "Scratches not shown in listing",
  "evidenceUrl": "https://example.com/photo.jpg"
}
```
