# Database

## Schema and Migrations

The database is built in two steps:

1. **Base schema**: `backend/schema.sql` – run first on an empty DB.
2. **Migrations**: `backend/migrations/*.sql` – run via `npm run migrate` (or manually in order).

## Running Migrations

```bash
cd backend
npm run migrate
```

Migrations are executed in lexicographic order. Already-applied changes are skipped when tables/columns already exist.

## Migration Files

| File | Purpose |
|------|---------|
| `001_add_app_settings.sql` | `app_settings` table, home hero text |
| `002_add_paath_status_and_audio_preview.sql` | `paath_status`, `paath_done_date`, audio preview seconds |
| `003_add_paath_services_table.sql` | `paath_services` catalog |
| `004_add_user_profile_fields.sql` | User profile columns |
| `005_seed_dummy_paath_forms.sql` | Seed paath service catalog |
| `006_add_paath_service_installments.sql` | Installment support for paath |
| `007_seed_installment_test_data.sql` | Test seed data |
| `008_add_daily_ekaum_password.sql` | Daily Ekaum password in app_settings |
| `009_add_mantra_notes.sql` | `mantra_notes` table |
| `010_add_feature_flags.sql` | Feature flags in app_settings |
| `011_add_samagam_google_maps_url.sql` | Samagam `google_maps_url` |
| `012_add_announcements.sql` | Announcements table |
| `013_add_video_satsang.sql` | Video Satsang table |
| `014_add_donation_subscriptions.sql` | Donation subscriptions |

## Main Tables (from schema.sql)

| Table | Purpose |
|-------|---------|
| `users` | User accounts, profile fields |
| `subscriptions` | Avdhan subscription status |
| `avdhan` | Avdhan audio metadata |
| `samagam` | Samagam events |
| `paath_services` | Paath service catalog |
| `paath_forms` | User paath bookings |
| `paath_form_family_members` | Family members for paath |
| `paath_payments` | Paath installments |
| `patrika` | Patrika issues |
| `patrika_purchases` | Patrika purchases |
| `mantra_notes` | User mantra notes |
| `donations` | Donation records |
| `payments` | Payment records (generic) |
| `app_settings` | Key-value app configuration |

## Caching

In production, read-heavy endpoints use in-memory caching (5 min TTL for paath-services, samagam, avdhan; 1 min for settings). Cache is invalidated when admin updates data via backoffice.

## Common Queries

```sql
-- List users
SELECT id, email, name, created_at FROM users ORDER BY created_at DESC;

-- User paath forms with status
SELECT pf.id, pf.service_name, pf.total_amount, pf.payment_status, pf.paath_status
FROM paath_forms pf
JOIN users u ON u.id = pf.user_id
WHERE u.email = 'user@example.com';

-- Active subscriptions
SELECT s.*, u.email
FROM subscriptions s
JOIN users u ON u.id = s.user_id
WHERE s.is_active = true;

-- App settings
SELECT key, value FROM app_settings;

-- Update home hero text
UPDATE app_settings SET value = 'Your text' WHERE key = 'home_hero_text';

-- Daily Ekaum password
UPDATE app_settings
SET value = 'new_password', updated_at = CURRENT_TIMESTAMP
WHERE key = 'daily_ekaum_password';
```

## Docker (local DB)

```bash
cd docker
docker-compose up -d
```

- PostgreSQL: `localhost:5432`  
- PgWeb UI: `http://localhost:8081`  
- Default: `postgres://username:password@localhost:5432/database_name`
