# ⚡ Supabase Quick Start Checklist

Follow these steps in order:

## ✅ Step-by-Step Checklist

### 1. Create Supabase Account
- [ ] Go to https://supabase.com
- [ ] Sign up (free, no credit card)
- [ ] Create new project: `bslnd-app`
- [ ] **Choose: "Only Connection String"** (not Data API)
- [ ] **Save your database password!**
- [ ] Wait 2-3 minutes for setup

### 2. Get Connection String
- [ ] Go to: Settings → Database
- [ ] Click "URI" tab
- [ ] Copy **Transaction mode** connection string (port 6543)
- [ ] It looks like: `postgresql://postgres.xxxxx:password@aws-0-region.pooler.supabase.com:6543/postgres`

### 3. Create Tables
- [ ] Go to: SQL Editor → New query
- [ ] Open `backend/schema.sql` from your project
- [ ] Copy ALL SQL code
- [ ] Paste into Supabase SQL Editor
- [ ] Click "Run"
- [ ] Should see: ✅ "Success. No rows returned"

### 4. Configure Backend
- [ ] Go to `backend` folder
- [ ] Run: `copy env.example .env`
- [ ] Open `.env` file
- [ ] Paste your connection string as `DATABASE_URL=...`
- [ ] Set `JWT_SECRET` to a random string
- [ ] Save file

### 5. Test Connection
- [ ] Run: `npm install` (in backend folder)
- [ ] Run: `npm start`
- [ ] Should see: ✅ "Connected to PostgreSQL database"
- [ ] Open browser: http://localhost:3000/health
- [ ] Should see: `{"status":"ok","database":"PostgreSQL"}`

### 6. Verify in Supabase
- [ ] Go to: Table Editor
- [ ] Should see all tables: users, subscriptions, avdhan, etc.

---

## 🎯 You're Done!

If all checkboxes are checked, your Supabase database is ready!

**Next:** Continue with Flutter app setup in `TEST_ON_WINDOWS.md`

---

## 🔗 Quick Links

- **Full Guide**: See `SETUP_SUPABASE.md` for detailed instructions
- **Supabase Dashboard**: https://supabase.com/dashboard
- **Troubleshooting**: Check `SETUP_SUPABASE.md` → Troubleshooting section

