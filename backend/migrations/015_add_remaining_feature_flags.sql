-- Migration: Add remaining feature flags for all app sections
-- Enables backoffice to control: Announcements, Daily Ekaum, Social Activities, Blog, BSLND Centers

INSERT INTO app_settings (key, value) VALUES
  ('feature_announcements_enabled', 'true'),
  ('feature_daily_ekaum_enabled', 'true'),
  ('feature_social_activities_enabled', 'true'),
  ('feature_blog_enabled', 'true'),
  ('feature_bslnd_centers_enabled', 'true')
ON CONFLICT (key) DO NOTHING;
