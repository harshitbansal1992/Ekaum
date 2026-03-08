# 🚀 Complete Supabase PostgreSQL Setup Guide

This guide will walk you through setting up Supabase PostgreSQL for your BSLND app.

---

## Step 1: Create Supabase Account & Project

### 1.1 Sign Up (Free, No Credit Card Required)

1. Go to **https://supabase.com**
2. Click **"Start your project"** or **"Sign up"** (top right)
3. Choose to sign up with:
   - GitHub (recommended - fastest)
   - Email
   - Google
4. Complete the sign-up process

### 1.2 Create New Project

1. After signing in, click **"New Project"** (green button)
2. **Choose or create organization:**
   - If you have an organization, select it
   - If not, create a new one (free)
3. **Fill in project details:**
   - **Name**: `bslnd-app` (or any name you like)
   - **Database Password**: 
     - ⚠️ **IMPORTANT**: Create a strong password and **SAVE IT**!
     - You'll need this for the connection string
     - Example: `MySecurePass123!@#`
   - **Region**: Choose closest to you (e.g., `Southeast Asia (Singapore)`)
4. **Connection Type** (Important!):
   - ✅ **Choose: "Only Connection String"**
   - ❌ Don't choose "Data API + Connection String"
   - **Why?** Your backend uses direct PostgreSQL connections (`pg` library), not Supabase's REST APIs
5. Click **"Create new project"**
6. ⏳ **Wait 2-3 minutes** for database to provision

---

## Step 2: Get Your Connection String

### 2.1 Find Database Settings

1. Once project is ready, you'll see the dashboard
2. Click **Settings** (gear icon) in the left sidebar
3. Click **Database** in the settings menu

### 2.2 Copy Connection String

1. Scroll down to **"Connection string"** section
2. You'll see tabs: **URI**, **JDBC**, **Golang**, etc.
3. Click on **"URI"** tab
4. You'll see something like:
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
   ```
5. **Copy the entire connection string**
   - It includes your password (the part after `postgres:`)
   - Example: `postgresql://postgres.xxxxx:MySecurePass123!@#@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres`

**⚠️ Important Notes:**
- There are **two connection strings**:
  - **Session mode** (port 5432) - For direct connections
  - **Transaction mode** (port 6543) - For connection pooling (recommended for apps)
- **Use the Transaction mode** (port 6543) for your backend app
- The password is shown in the connection string - keep it secure!

---

## Step 3: Create Database Tables

### 3.1 Open SQL Editor

1. In Supabase dashboard, click **SQL Editor** in the left sidebar
2. Click **"New query"** button (top right)

### 3.2 Run Schema Script

1. Open your project file: `backend/schema.sql`
2. **Copy ALL the SQL code** from that file
3. **Paste it into** the Supabase SQL Editor
4. Click **"Run"** button (or press `Ctrl+Enter`)

**Expected Result:**
- You should see: ✅ **"Success. No rows returned"**
- This means all tables were created successfully!

### 3.3 Verify Tables Were Created

1. In Supabase dashboard, click **"Table Editor"** in the left sidebar
2. You should see all your tables:
   - ✅ `users`
   - ✅ `subscriptions`
   - ✅ `avdhan`
   - ✅ `samagam`
   - ✅ `patrika`
   - ✅ `patrika_purchases`
   - ✅ `paath_forms`
   - ✅ `paath_form_family_members`
   - ✅ `paath_payments`
   - ✅ `donations`
   - ✅ `payments`

---

## Step 4: Configure Backend (.env file)

### 4.1 Create .env File

1. Navigate to your project's `backend` folder:
   ```powershell
   cd C:\PP\Ekaum\backend
   ```

2. Copy the example file:
   ```powershell
   copy env.example .env
   ```

3. Open `.env` file in a text editor:
   ```powershell
   notepad .env
   ```

### 4.2 Update .env File

Replace the values with your Supabase connection string:

```env
# Server Port
PORT=3000

# PostgreSQL Database URL (from Supabase)
# Use the Transaction mode connection string (port 6543)
DATABASE_URL=postgresql://postgres.xxxxx:YOUR_PASSWORD@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres

# JWT Secret Key (Generate a random string)
# You can use: openssl rand -base64 32
# Or just use a long random string
JWT_SECRET=my-super-secret-jwt-key-change-this-to-random-string-in-production

# Instamojo Payment Gateway (Optional for now)
INSTAMOJO_API_KEY=your-instamojo-api-key
INSTAMOJO_AUTH_TOKEN=your-instamojo-auth-token

# Environment
NODE_ENV=development
```

**Important:**
- Replace `DATABASE_URL` with your **actual Supabase connection string**
- Make sure to use the **Transaction mode** (port 6543) connection string
- Replace `YOUR_PASSWORD` with your actual database password

### 4.3 Generate JWT Secret (Optional but Recommended)

You can generate a secure random JWT secret:

**Windows PowerShell:**
```powershell
# Generate random string
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
```

**Or use online tool:** https://randomkeygen.com/
- Copy a "CodeIgniter Encryption Keys" value
- Paste it as `JWT_SECRET`

---

## Step 5: Test Database Connection

### 5.1 Install Backend Dependencies

```powershell
cd C:\PP\Ekaum\backend
npm install
```

### 5.2 Start Backend Server

```powershell
npm start
```

**Expected Output:**
```
✅ Connected to PostgreSQL database
🚀 BSLND Backend API running on port 3000
📊 Database: PostgreSQL
🔐 JWT Secret: ✅ Set
```

If you see **"❌ PostgreSQL connection error"**, check:
- Connection string is correct
- Password is correct
- You're using Transaction mode connection string (port 6543)

### 5.3 Test Backend Health

1. Open browser
2. Go to: **http://localhost:3000/health**
3. You should see:
   ```json
   {
     "status": "ok",
     "message": "BSLND Backend API is running",
     "database": "PostgreSQL"
   }
   ```

✅ **If you see this, your database is connected successfully!**

---

## Step 6: Test Database Operations

### 6.1 Test via Backend API

You can test creating a user via API:

**Using PowerShell:**
```powershell
# Test registration endpoint
$body = @{
    email = "test@example.com"
    password = "test123456"
    name = "Test User"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method Post -Body $body -ContentType "application/json"
```

**Expected Response:**
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

### 6.2 Verify in Supabase Dashboard

1. Go to Supabase dashboard
2. Click **"Table Editor"**
3. Click on **"users"** table
4. You should see the test user you just created!

---

## Troubleshooting

### Connection Error: "password authentication failed"

**Problem:** Wrong password in connection string

**Solution:**
1. Go to Supabase → Settings → Database
2. Click **"Reset database password"** (if needed)
3. Copy the connection string again
4. Make sure password in `.env` matches

---

### Connection Error: "connection refused" or "timeout"

**Problem:** Wrong connection string or network issue

**Solution:**
1. Verify you're using **Transaction mode** connection string (port 6543)
2. Check if your firewall is blocking the connection
3. Try the **Session mode** connection string (port 5432) as alternative

---

### "Table does not exist" error

**Problem:** Schema wasn't run successfully

**Solution:**
1. Go to Supabase → SQL Editor
2. Open `backend/schema.sql` again
3. Copy and paste ALL SQL
4. Run it again
5. Check Table Editor to verify tables exist

---

### Backend starts but can't connect

**Check:**
1. `.env` file exists in `backend` folder
2. `DATABASE_URL` is set correctly
3. No extra spaces or quotes around connection string
4. Backend terminal shows connection message

**Debug:**
```powershell
# Check if .env is loaded
cd backend
node -e "require('dotenv').config(); console.log(process.env.DATABASE_URL)"
```

---

## Quick Reference

### Supabase Dashboard URLs

- **Dashboard**: https://supabase.com/dashboard
- **SQL Editor**: Dashboard → SQL Editor (left sidebar)
- **Table Editor**: Dashboard → Table Editor (left sidebar)
- **Database Settings**: Dashboard → Settings → Database

### Connection String Format

```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

### Important Files

- **Connection String**: Supabase → Settings → Database → Connection string (URI tab)
- **Schema File**: `backend/schema.sql`
- **Backend Config**: `backend/.env`

---

## Next Steps

Once Supabase is set up:

1. ✅ Database is ready
2. ✅ Backend can connect
3. ✅ Tables are created
4. ➡️ **Continue with**: `TEST_ON_WINDOWS.md` Step 2 (Flutter setup)

---

## Security Notes

⚠️ **Important Security Tips:**

1. **Never commit `.env` file** to Git (it's already in `.gitignore`)
2. **Keep your database password secure**
3. **Use strong JWT_SECRET** in production
4. **Enable Row Level Security (RLS)** in Supabase for production (optional, for direct Supabase access)
5. **Backup your database** regularly (Supabase Pro plan includes automated backups)

---

## Need Help?

- **Supabase Docs**: https://supabase.com/docs
- **Supabase Discord**: https://discord.supabase.com
- **Check backend logs** for detailed error messages

