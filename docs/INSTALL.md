# Installation Guide

## Prerequisites

- **Flutter** 3.0+ (for mobile app)
- **Node.js** 16+ (for backend)
- **PostgreSQL** (local or hosted: Supabase, Neon, Railway)
- **Firebase** project (optional, for push/auth if used)

## 1. Clone and Install Dependencies

```bash
git clone <repo-url>
cd Ekaum

# Flutter
flutter pub get

# Backend
cd backend
npm install
```

## 2. Database

### Option A: Docker (local PostgreSQL)

```bash
cd docker
docker-compose up -d

# Default: postgresql://username:password@localhost:5432/database_name
```

### Option B: Supabase / Neon / Railway

Create a project and copy the connection string (e.g. `postgresql://...`).

## 3. Backend Configuration

```bash
cd backend
cp env.example .env
```

Edit `.env`:

```env
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/bslnd_db
JWT_SECRET=your-secure-random-string

# Razorpay (test keys in env.example)
RAZORPAY_KEY_ID=rzp_test_xxx
RAZORPAY_KEY_SECRET=xxx

NODE_ENV=development
```

For production, generate a secure JWT secret:

```bash
openssl rand -base64 32
```

## 4. Run Migrations

```bash
cd backend
npm run migrate
```

This runs all `.sql` files in `backend/migrations/` in order.

## 5. Start Backend

```bash
cd backend
npm run dev    # development (nodemon)
# or
npm start      # production
```

Backend runs at `http://localhost:3000`.

**Note:** `npm run dev` and `npm start` use `cross-env` for `NODE_ENV`, so they work correctly on Windows, macOS, and Linux.

## 6. Flutter App

### Point app to backend

- **Default**: `http://localhost:3000/api` (Android emulator: use `http://10.0.2.2:3000/api`)
- **Custom**: `flutter run --dart-define=BACKEND_URL=https://your-api.com/api`

### Run

```bash
flutter run
```

### Build APK

```bash
flutter build apk --dart-define=BACKEND_URL=https://your-api.com/api
```

## 7. Firebase (optional)

If using Firebase for auth or push:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=ekaum-e5b36
```

## Environment Summary

| Variable | Required | Purpose |
|----------|----------|---------|
| `PORT` | Yes | Backend port (default 3000) |
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `JWT_SECRET` | Yes | JWT signing secret |
| `RAZORPAY_KEY_ID` | Yes | Razorpay key ID |
| `RAZORPAY_KEY_SECRET` | Yes | Razorpay secret (server only) |
| `KAALCHAKRA_API_KEY` | No | For Panchang (kaalchakra.dev) |
