-- Original YouTube channel profile image for the recipe source credit.
-- Optional: the app shows the channel name's first letter when it is NULL.
ALTER TABLE recipe
    ADD COLUMN source_channel_thumbnail_url VARCHAR(2048);
