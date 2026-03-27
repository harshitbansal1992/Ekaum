-- Migration: Add daily Ekaum password settings for backoffice to update daily
-- Keys: daily_ekaum_password (the mantra/word), daily_ekaum_date (YYYY-MM-DD)

INSERT INTO app_settings (key, value) VALUES
  ('daily_ekaum_password', 'नमो नारायण'),
  ('daily_ekaum_date', to_char(CURRENT_DATE, 'YYYY-MM-DD'))
ON CONFLICT (key) DO NOTHING;
