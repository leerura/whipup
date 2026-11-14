-- Last time the account was used (created, or the app confirmed it at start).
-- Accounts unused for 365 days are deleted by a daily job (docs/v4/product).
-- Existing accounts start counting from this migration.
ALTER TABLE users
    ADD COLUMN last_active_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;
