# 🔧 Fix Database Connection Error

## Problem
Error: `getaddrinfo ENOTFOUND db.odzpwqclczerzxpkcsnx.supabase.co`

This means the backend can't resolve the Supabase database hostname.

---

## ✅ Solution: Update Connection String

The old connection string format is deprecated. We need to use the **new Supabase connection string format**.

### Step 1: Get Correct Connection String from Supabase

1. Go to: https://supabase.com/dashboard
2. Select your project: `odzpwqclczerzxpkcsnx`
3. Go to: **Settings** → **Database**
4. Scroll to **"Connection string"** section
5. Click on **"URI"** tab
6. You'll see two options:
   - **Session mode** (port 5432) - Direct connection
   - **Transaction mode** (port 6543) - Connection pooler (recommended)

### Step 2: Copy the Connection String

**For Transaction Mode (Recommended):**
```
postgresql://postgres.odzpwqclczerzxpkcsnx:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

**For Session Mode (Direct):**
```
postgresql://postgres.odzpwqclczerzxpkcsnx:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres
```

Replace:
- `[YOUR-PASSWORD]` with: `Tripursundhari9`
- `[REGION]` with your region (e.g., `ap-southeast-1`)

### Step 3: Update .env File

```powershell
cd C:\PP\Ekaum\backend
notepad .env
```

Update the `DATABASE_URL` line with the correct connection string from Supabase dashboard.

### Step 4: Restart Backend

```powershell
# Stop current backend (Ctrl+C)
# Then restart:
cd C:\PP\Ekaum\backend
npm start
```

---

## 🔍 Alternative: Check Supabase Dashboard

The connection string format might have changed. The best way is to:

1. **Go to Supabase Dashboard**
2. **Settings → Database**
3. **Copy the exact connection string** shown there
4. **Paste it into `backend/.env`**

---

## ✅ Quick Fix Script

I've updated the connection string, but if it still doesn't work, manually copy from Supabase dashboard:

```powershell
cd C:\PP\Ekaum\backend
notepad .env
```

Then update `DATABASE_URL` with the exact string from Supabase dashboard.

---

## 🎯 Expected Connection String Format

**Transaction Mode (Pooler) - Recommended:**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

**Session Mode (Direct):**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres
```

**Your values:**
- Project Ref: `odzpwqclczerzxpkcsnx`
- Password: `Tripursundhari9`
- Region: Check in Supabase dashboard (likely `ap-southeast-1`)

---

## 📝 After Fixing

1. Restart backend server
2. Test login again
3. Should work now!

