ALTER TABLE users
    ADD COLUMN terms_version VARCHAR(64),
    ADD COLUMN terms_accepted_at TIMESTAMPTZ,
    ADD COLUMN privacy_version VARCHAR(64),
    ADD COLUMN privacy_accepted_at TIMESTAMPTZ,
    ADD COLUMN age_14_confirmed_at TIMESTAMPTZ;

-- Existing accounts predate the V4 consent flow and are not shown the
-- onboarding/consent screens again. New accounts leave these columns NULL.
UPDATE users
SET terms_version = 'v1',
    terms_accepted_at = COALESCE(terms_accepted_at, CURRENT_TIMESTAMP),
    privacy_version = 'v1',
    privacy_accepted_at = COALESCE(privacy_accepted_at, CURRENT_TIMESTAMP),
    age_14_confirmed_at = COALESCE(age_14_confirmed_at, CURRENT_TIMESTAMP)
WHERE terms_accepted_at IS NULL
   OR privacy_accepted_at IS NULL
   OR age_14_confirmed_at IS NULL;
