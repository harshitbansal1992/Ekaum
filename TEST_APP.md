# 🧪 Easy Testing Guide

## The Simplest Way to Test

### Step 1: Start Backend (One Command)

Open PowerShell in the project folder and run:

```powershell
.\START_BACKEND.ps1
```

**First time?** The script will:
- ✅ Check Node.js installation
- ✅ Install npm packages automatically
- ✅ Create `.env` file from template
- ⚠️ You'll need to edit `.env` and add your database connection string

### Step 2: Set Up Database (One-Time)

1. Go to https://supabase.com (or neon.tech, railway.app)
2. Create a free account and project
3. Copy the connection string (looks like: `postgresql://postgres:xxxxx@xxx.supabase.co:5432/postgres`)
4. In your database provider's SQL Editor, paste and run the SQL from `backend/schema.sql`
5. Edit `backend/.env` and paste your connection string

### Step 3: Start Flutter App (One Command)

Open a NEW PowerShell window and run:

```powershell
.\START_APP.ps1
```

The script will:
- ✅ Check if backend is running
- ✅ Show available devices
- ✅ Let you choose device or auto-select

## Quick Commands

```powershell
# Terminal 1: Backend
.\START_BACKEND.ps1

# Terminal 2: Flutter App
.\START_APP.ps1
```

## Important URLs

- **Backend API**: http://localhost:3000/api
- **Health Check**: http://localhost:3000/health
- **For Android Emulator**: Change API URL to `http://10.0.2.2:3000/api` in `lib/core/services/api_service.dart`

## Common Issues

### "Backend not running"
→ Run `.\START_BACKEND.ps1` first

### "Database connection error"
→ Check your `.env` file has correct `DATABASE_URL`

### "Network error" in app
→ For Android emulator, change API URL to `http://10.0.2.2:3000/api`
→ For physical device, use your computer's IP address (run `ipconfig` to find it)

### "Cannot find Flutter"
→ The script should auto-detect your Flutter installation
→ If not, edit `START_APP.ps1` and update the Flutter path

## Testing Checklist

Once both are running:

1. ✅ Open app → Should show login screen
2. ✅ Register new account → Should work
3. ✅ Login → Should redirect to home
4. ✅ Browse features → Should load (may be empty until you add data)
5. ✅ Check backend terminal → Should show API requests

## Need Help?

Check `QUICK_START.md` for detailed instructions!





