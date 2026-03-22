-- Migration: Add feature enable/disable flags for backoffice
-- App features correspond to home page: Quick Tools + Services Grid

INSERT INTO app_settings (key, value) VALUES
  ('feature_nadi_dosh_enabled', 'true'),
  ('feature_rahu_kaal_enabled', 'true'),
  ('feature_avdhan_enabled', 'true'),
  ('feature_mantra_notes_enabled', 'true'),
  ('feature_samagam_enabled', 'true'),
  ('feature_patrika_enabled', 'true'),
  ('feature_pooja_items_enabled', 'true'),
  ('feature_paath_services_enabled', 'true'),
  ('feature_donation_enabled', 'true')
ON CONFLICT (key) DO NOTHING;
