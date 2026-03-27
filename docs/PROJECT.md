# Ekaum / BSLND Flutter App

A Flutter mobile application for BSLND organization with a Node.js/PostgreSQL backend.

## Features

| Feature | Description |
|---------|-------------|
| **Auth** | Register, login, JWT sessions |
| **Nadi Dosh Calculator** | Calculate nadi and nadi dosh for couples |
| **Rahu Kaal, Sandhya Kaal, Brahma Muhurat** | Time calculations based on GPS location |
| **Avdhan Audio** | Audio content with preview and subscription |
| **Samagam** | Upcoming event schedules |
| **Prabhu Kripa Patrika** | Monthly magazine with preview and paid access |
| **Paath Services** | Book paath services with installment payment |
| **Donations** | Donations with Razorpay integration |
| **Mantra Notes** | User-stored mantras |
| **Video Satsang** | YouTube video content |
| **Panchang** | Hindu calendar (Tithi, Nakshatra, Vara, Paksha) |

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.x, Riverpod, GoRouter |
| **Backend** | Node.js, Express.js |
| **Database** | PostgreSQL (Supabase / Neon / Railway) |
| **Auth** | JWT |
| **Payments** | Razorpay |

## Performance

- **Response caching**: Read-heavy endpoints (avdhan, samagam, paath-services, settings) use in-memory caching in production (`config.features.caching`). Cache is invalidated when admin updates data.

## Project Structure

```
Ekaum/
├── lib/                      # Flutter app
│   ├── main.dart
│   ├── core/                 # Config, routes, services, theme
│   └── features/             # Auth, home, avdhan, paath_services, etc.
├── backend/
│   ├── server.js
│   ├── schema.sql            # Base schema
│   ├── migrations/           # Incremental migrations
│   └── src/
│       ├── config.js
│       ├── database.js
│       ├── routes/           # API route handlers
│       └── middleware/
├── docker/
│   └── docker-compose.yml   # Local PostgreSQL + pgweb
└── docs/
    ├── PROJECT.md           # This file
    ├── INSTALL.md           # Installation guide
    └── DATABASE.md          # Database and migrations
```

## API Overview

| Base Path | Purpose |
|-----------|---------|
| `/health` | Health check |
| `/api/auth` | Login, register, profile |
| `/api/settings` | App settings (key-value) |
| `/api/avdhan` | Avdhan audio list |
| `/api/paath-services` | Paath catalog |
| `/api/paath-forms` | Create/list paath forms |
| `/api/mantra-notes` | User mantra notes CRUD |
| `/api/donations` | Create donations |
| `/api/samagam` | Samagam events |
| `/api/announcements` | Announcements |
| `/api/panchang` | Hindu calendar (Kaalchakra proxy) |
| `/api/search` | Unified search |
| `/api/patrika` | Patrika magazine |
| `/api/video-satsang` | Video Satsang list |
| `/api/admin` | Admin/back-office |
| `/api/payments` | Payment orders, webhook |
