# Ekaum / BSLND

Flutter mobile app for BSLND organization with Node.js backend.

**Docs:**

- [Project Overview](docs/PROJECT.md)
- [Installation](docs/INSTALL.md)
- [Database & Migrations](docs/DATABASE.md)

## Quick Start

```bash
# Backend
cd backend
cp env.example .env   # edit DATABASE_URL, JWT_SECRET
npm install
npm run migrate
npm run dev

# App
flutter pub get
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000/api
```
