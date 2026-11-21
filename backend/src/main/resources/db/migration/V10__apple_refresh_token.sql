-- Encrypted Apple refresh token, kept only to revoke the Apple connection when
-- the account is deleted. NULL for non-Apple accounts.
ALTER TABLE user_auth_account
    ADD COLUMN apple_refresh_token_encrypted TEXT;
