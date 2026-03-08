# ✅ Supabase Setup Complete - Next Steps

Your Supabase connection is configured! Here's what to do next:

---

## ✅ What's Done

- ✅ Supabase project created
- ✅ Connection string configured
- ✅ `.env` file created with your credentials
- ✅ JWT secret generated

---

## 📋 Next Steps

### Step 1: Create Database Tables in Supabase

1. **Go to Supabase Dashboard:**
   - https://supabase.com/dashboard
   - Select your project: `bslnd-app`

2. **Open SQL Editor:**
   - Click **"SQL Editor"** in the left sidebar
   - Click **"New query"** button (top right)

3. **Run the Schema:**
   - Open `backend/schema.sql` from your project folder
   - **Copy ALL the SQL code** (Ctrl+A, Ctrl+C)
   - **Paste into** Supabase SQL Editor
   - Click **"Run"** button (or press `Ctrl+Enter`)

4. **Verify Success:**
   - You should see: ✅ **"Success. No rows returned"**
   - If you see errors, check the error message

5. **Check Tables:**
   - Click **"Table Editor"** in left sidebar
   - You should see all tables: `users`, `subscriptions`, `avdhan`, `samagam`, `patrika`, etc.

---

### Step 2: Install Backend Dependencies

```powershell
# Make sure you're in the backend folder
cd C:\PP\Ekaum\backend

# Install Node.js packages
npm install
```

**Expected output:** Should install all packages without errors

---

### Step 3: Start Backend Server

```powershell
# Start the server
npm start
```

**Expected output:**
```
✅ Connected to PostgreSQL database
🚀 BSLND Backend API running on port 3000
📊 Database: PostgreSQL
🔐 JWT Secret: ✅ Set
```

**If you see connection errors:**
- Check that `.env` file exists in `backend` folder
- Verify connection string is correct
- Make sure Supabase project is active (not paused)

---

### Step 4: Test Backend Connection

1. **Open browser:**
   - Go to: **http://localhost:3000/health**

2. **Expected response:**
   ```json
   {
     "status": "ok",
     "message": "BSLND Backend API is running",
     "database": "PostgreSQL"
   }
   ```

✅ **If you see this, your database connection is working!**

---

### Step 5: Test Database Operations

**Test User Registration:**

```powershell
# In a new PowerShell window
$body = @{
    email = "test@example.com"
    password = "test123456"
    name = "Test User"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method Post -Body $body -ContentType "application/json"
```

**Expected response:**
```json
{
  "success": true,
  "user": {
    "id": "...",
    "email": "test@example.com",
    "name": "Test User"
  },
  "token": "..."
}
```

**Verify in Supabase:**
- Go to Supabase Dashboard → Table Editor → `users` table
- You should see the test user you just created!

---

## 🎯 Quick Command Reference

```powershell
# Navigate to backend
cd C:\PP\Ekaum\backend

# Install dependencies (first time only)
npm install

# Start backend server
npm start

# Test health endpoint (in browser)
# http://localhost:3000/health
```

---

## 🔧 Troubleshooting

### "Cannot find module" error
```powershell
cd backend
npm install
```

### "PostgreSQL connection error"
- Check `.env` file exists: `Test-Path backend\.env`
- Verify connection string in `.env` is correct
- Make sure Supabase project is not paused

### "Table does not exist" error
- Go back to Step 1 and run the schema in Supabase SQL Editor
- Make sure you copied ALL SQL from `backend/schema.sql`

### Port 3000 already in use
- Change `PORT=3001` in `.env` file
- Update API URL in `lib/core/services/api_service.dart` to match

---

## ✅ Success Checklist

- [ ] Supabase tables created (SQL Editor → Run schema)
- [ ] Backend dependencies installed (`npm install`)
- [ ] Backend server starts without errors (`npm start`)
- [ ] Health endpoint works (http://localhost:3000/health)
- [ ] Can create test user via API
- [ ] Test user appears in Supabase Table Editor

---

## 🚀 Once Backend is Working

Continue with Flutter app setup:
- See `TEST_ON_WINDOWS.md` for Flutter setup instructions
- Make sure backend is running before starting Flutter app

---

## 📝 Your Connection Details (Saved)

- **Project URL**: https://odzpwqclczerzxpkcsnx.supabase.co
- **Database**: PostgreSQL
- **Connection**: Direct (port 5432)
- **Password**: Tripursundhari9 (saved in .env)

**Note:** Your `.env` file contains sensitive data - never commit it to Git (it's already in .gitignore)



