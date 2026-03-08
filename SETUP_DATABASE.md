# 📊 Database Setup Guide

## Quick Setup (Supabase - Recommended)

### 1. Create Free Account
- Go to https://supabase.com
- Sign up (free tier is enough)
- Create a new project
- Wait 2-3 minutes for database to be ready

### 2. Get Connection String
- Go to Project Settings → Database
- Copy the connection string under "Connection string" → "URI"
- It looks like: `postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-0-us-east-1.pooler.supabase.com:6543/postgres`

### 3. Create Tables
- Go to SQL Editor in Supabase dashboard
- Click "New query"
- Copy the entire contents of `backend/schema.sql`
- Paste and click "Run"
- You should see "Success. No rows returned"

### 4. Update Backend Config
- Edit `backend/.env` file
- Set `DATABASE_URL` to your connection string
- Example:
  ```env
  DATABASE_URL=postgresql://postgres.xxxxx:your-password@aws-0-us-east-1.pooler.supabase.com:6543/postgres
  ```

## Alternative: Neon.tech

1. Go to https://neon.tech
2. Create free account and project
3. Copy connection string
4. Run `backend/schema.sql` in SQL Editor
5. Update `backend/.env`

## Alternative: Railway

1. Go to https://railway.app
2. Create account
3. New Project → Add PostgreSQL
4. Copy DATABASE_URL
5. Connect with Railway CLI or use their dashboard SQL
6. Run `backend/schema.sql`
7. Update `backend/.env`

## Verify Setup

After setup, test the connection:

```powershell
cd backend
npm start
```

You should see:
```
✅ Connected to PostgreSQL database
🚀 BSLND Backend API running on port 3000
```

If you see database errors, check:
- Connection string is correct
- Password is correct (no spaces/extra characters)
- Database is accessible from your IP (cloud databases)
- Tables were created successfully

## Adding Test Data (Optional)

Once tables are created, you can add test data through:
- Supabase dashboard → Table Editor
- SQL queries
- API endpoints (once backend is running)





