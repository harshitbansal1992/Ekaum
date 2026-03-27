-- Migration: Add mantra_notes table for user-stored mantras (note-taker style)
-- Each note has: heading, description; owned by user_id

CREATE TABLE IF NOT EXISTS mantra_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    heading VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_mantra_notes_user_id ON mantra_notes(user_id);
