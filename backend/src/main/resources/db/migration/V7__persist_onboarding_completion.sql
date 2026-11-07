ALTER TABLE users
    ADD COLUMN onboarding_completed BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE users
    ALTER COLUMN onboarding_completed SET DEFAULT FALSE;
