-- Migration: Add Google Maps link for Samagam events

ALTER TABLE samagam ADD COLUMN IF NOT EXISTS google_maps_url TEXT;
