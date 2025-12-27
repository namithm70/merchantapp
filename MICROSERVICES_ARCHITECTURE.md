# Marketplace Backend Architecture (Microservices + PostgreSQL)

## Overview
This document outlines a microservices architecture for the Marketplace product with PostgreSQL as the primary datastore. Services are split by domain to improve scalability, ownership, and deployment velocity.

## Goals
- Clear service boundaries aligned to product domains
- Independent deployability and scaling
- Strong data ownership with PostgreSQL per service
- Event-driven integration for cross-service workflows

## Core Services
1) API Gateway
- Entry point for mobile/web clients
- Auth token validation, rate limiting, request routing

2) Auth & Identity Service
- User accounts, sessions, MFA
- JWT issuance
- Owns user profile data (Postgres)

3) Listings Service
- Listing creation, editing, publishing
- Product condition rating model
- Bulk listing import validation
- Owns listing catalog (Postgres)

4) Messaging Service
- Real-time chat threads and messages
- Attachments metadata
- WebSocket gateway for live updates
- Owns messages/threads (Postgres)

5) Offers & Negotiation Service
- Offer, counter, accept, decline, expire rules
- Auditable offer state transitions
- Owns offers (Postgres)

6) Payments & Protection Service
- Payment intents, escrow hold/release
- Refund workflows
- Owns payment and protection records (Postgres)

7) Disputes Service
- Dispute intake, evidence, SLA tracking
- Admin resolution workflow
- Owns disputes and evidence metadata (Postgres)

8) Verification Service
- Seller verification state machine
- Third-party ID verification integration
- Owns verification records (Postgres)

9) Shipping & Logistics Service
- Shipping rate quotes, label creation
- Carrier integrations
- Logistics optimization signals
- Owns shipping orders (Postgres)

10) Pricing & AI Service
- AI pricing suggestions
- Demand forecasting output
- Owns model outputs and telemetry (Postgres)

11) Fraud & Risk Service
- Risk scoring for users, listings, transactions
- Holds and review queue
- Owns risk events (Postgres)

12) Notifications Service
- Push, email, SMS delivery
- Notification preferences
- Owns notification logs (Postgres)

## Data Ownership
Each service owns its schema. Cross-service access is via APIs or events. Avoid direct DB sharing.

## Event Bus (Recommended)
- Use a message broker (e.g., Kafka, RabbitMQ, or NATS)
- Publish domain events:
  - ListingPublished
  - OfferCreated / OfferAccepted
  - PaymentHeld / PaymentReleased
  - DisputeOpened / DisputeResolved
  - ShipmentCreated / ShipmentDelivered
  - RiskFlagRaised

## API Gateway Routes (Example)
- /auth/* -> Auth Service
- /listings/* -> Listings Service
- /messages/* -> Messaging Service
- /offers/* -> Offers Service
- /payments/* -> Payments Service
- /disputes/* -> Disputes Service
- /verification/* -> Verification Service
- /shipping/* -> Shipping Service
- /pricing/* -> Pricing Service
- /fraud/* -> Fraud Service
- /notifications/* -> Notifications Service

## PostgreSQL Strategy
- One Postgres database per service (preferred)
- Each service controls migrations
- Use read replicas for heavy read services

## Cross-Cutting Concerns
- Observability: centralized logs + metrics + tracing
- Config management: env vars + secrets manager
- CI/CD: service-by-service pipelines
- Security: JWT, service-to-service auth, least privilege

## Suggested Deployment
- Containerized services (Docker)
- Orchestrator: Kubernetes or managed container service
- Database: managed PostgreSQL (e.g., RDS, Cloud SQL)
- Gateway: managed API gateway or Envoy/NGINX

## MVP Service Cut (Start Small)
- Auth, Listings, Messaging, Offers, Payments, Notifications
- Add Disputes, Verification, Shipping next
- Add Fraud, Pricing/AI, Logistics later

## Open Questions
- Preferred message broker?
- Managed Postgres provider?
- Real-time messaging stack (Redis + WS, or managed PubSub)?
- SLA targets for each service?
