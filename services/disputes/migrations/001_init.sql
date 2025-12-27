CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dispute_status') THEN
    CREATE TYPE dispute_status AS ENUM ('open', 'under_review', 'resolved', 'closed');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id TEXT NOT NULL,
  order_id TEXT,
  issue_type TEXT NOT NULL,
  details TEXT NOT NULL,
  evidence_url TEXT,
  status dispute_status NOT NULL DEFAULT 'open',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS disputes_listing_idx ON disputes(listing_id);
CREATE INDEX IF NOT EXISTS disputes_status_idx ON disputes(status);
