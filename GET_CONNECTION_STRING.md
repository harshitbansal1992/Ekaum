# 🔗 Get Correct Supabase Connection String

## Problem
The connection string in `.env` is not working. We need to get the **exact** connection string from your Supabase dashboard.

---

## ✅ Step-by-Step Instructions

### Step 1: Open Supabase Dashboard

1. Go to: **https://supabase.com/dashboard**
2. Sign in to your account
3. Select your project: **odzpwqclczerzxpkcsnx**

### Step 2: Navigate to Database Settings

1. Click **Settings** (gear icon) in the left sidebar
2. Click **Database** in the settings menu
3. Scroll down to **"Connection string"** section

### Step 3: Copy Connection String

You'll see tabs: **URI**, **JDBC**, **Golang**, etc.

1. Click on **"URI"** tab
2. You'll see connection strings for:
   - **Session mode** (port 5432) - Direct connection
   - **Transaction mode** (port 6543) - Connection pooler (recommended for apps)

3. **Copy the Transaction mode connection string** (port 6543)

It should look like:
```
postgresql://postgres.odzpwqclczerzxpkcsnx:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

**Important:** The password in the connection string should be your database password: `Tripursundhari9`

### Step 4: Update .env File

**Option A: Use the Helper Script**
```powershell
cd C:\PP\Ekaum\backend
.\update_connection_string.ps1
```
Then paste the connection string when prompted.

**Option B: Manual Edit**
```powershell
cd C:\PP\Ekaum\backend
notepad .env
```

Find the line:
```
DATABASE_URL=...
```

Replace it with the connection string you copied from Supabase.

### Step 5: Restart Backend

```powershell
# Stop current backend (Ctrl+C in the terminal where it's running)
# Then restart:
cd C:\PP\Ekaum\backend
npm start
```

---

## 🔍 What to Look For

The connection string should have:
- ✅ `postgres.odzpwqclczerzxpkcsnx` (username with project ref)
- ✅ `aws-0-[region].pooler.supabase.com` (hostname)
- ✅ Port `6543` (transaction mode) or `5432` (session mode)
- ✅ Your password: `Tripursundhari9`

---

## ⚠️ Common Issues

### "Tenant or user not found"
- Username format might be wrong
- Use the exact format from Supabase dashboard

### "getaddrinfo ENOTFOUND"
- Hostname is wrong or outdated
- Use the connection string from Supabase dashboard (not old format)

### Connection timeout
- Check if Supabase project is active (not paused)
- Verify your network connection
- Try the session mode connection string instead

---

## ✅ After Updating

1. Restart backend server
2. Test: http://localhost:3000/health
3. Try login in the app
4. Should work now!

---

## 📝 Quick Reference

**Your Supabase Project:**
- Project URL: https://odzpwqclczerzxpkcsnx.supabase.co
- Project Ref: odzpwqclczerzxpkcsnx
- Password: Tripursundhari9

**Get connection string from:**
- Dashboard → Settings → Database → Connection string → URI tab

