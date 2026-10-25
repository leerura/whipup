ALTER TABLE recipe
    ADD COLUMN source_title VARCHAR(2048),
    ADD COLUMN source_channel_name VARCHAR(512),
    ADD COLUMN source_channel_id VARCHAR(128),
    ADD COLUMN source_metadata_fetched_at TIMESTAMPTZ;
