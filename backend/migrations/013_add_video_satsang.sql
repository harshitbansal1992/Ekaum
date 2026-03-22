-- Video Satsang: Free YouTube video content (satsangs, kirtans)
-- Managed from backoffice, displayed in mobile app

CREATE TABLE IF NOT EXISTS video_satsang (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    youtube_video_id VARCHAR(20) NOT NULL,
    thumbnail_url TEXT,
    duration_seconds INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_video_satsang_display_order ON video_satsang(display_order);
