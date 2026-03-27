-- Migration: Add paath-form-related profile fields to users table
-- Enables users to save details for prepopulating paath forms

ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS time_of_birth VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS place_of_birth VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS fathers_or_husbands_name VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS gotra VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS caste VARCHAR(100);
