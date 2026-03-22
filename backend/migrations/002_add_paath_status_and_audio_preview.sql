-- Migration: Add paath_status to paath_forms, seed audio_preview_seconds
-- Run this for databases that already exist

-- Paath status: pending (default) | done
ALTER TABLE paath_forms ADD COLUMN IF NOT EXISTS paath_status VARCHAR(50) DEFAULT 'pending';
ALTER TABLE paath_forms ADD COLUMN IF NOT EXISTS paath_done_date DATE;

COMMENT ON COLUMN paath_forms.paath_status IS 'pending | done';

-- Seed audio preview duration (seconds) - used by Avdhan player
INSERT INTO app_settings (key, value) VALUES 
  ('audio_preview_seconds', '120')
ON CONFLICT (key) DO NOTHING;
