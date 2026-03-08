# 🪟 Testing BSLND App on Windows PC

This guide will help you test the Flutter app on your Windows desktop.

## Prerequisites Checklist

- [ ] Node.js installed (✅ You have v22.20.0)
- [ ] PostgreSQL database (cloud or local)
- [ ] Flutter SDK installed
- [ ] Flutter Windows desktop support enabled

---

## Step 1: Set Up Backend (Required - App needs this!)

The app connects to a backend API running on `localhost:3000`. You must start the backend first.

### 1.1 Set Up PostgreSQL Database

**Option A: Free Cloud Database (Recommended for testing)**

#### 🏆 Best Option: **Supabase** (Recommended)

**Why Supabase is best:**
- ✅ **Generous free tier**: 500 MB database, 2 GB bandwidth, unlimited API requests
- ✅ **Easy upgrade path**: Clear pricing tiers ($25/month Pro, $599/month Team)
- ✅ **Full PostgreSQL**: Standard PostgreSQL 15+ with extensions
- ✅ **Built-in features**: Auth, Storage, Realtime, Edge Functions (bonus features you might use later)
- ✅ **Great dashboard**: Easy SQL editor, table viewer, API docs
- ✅ **No credit card required** for free tier
- ✅ **Auto-scaling**: Handles traffic spikes well

**Setup:**
1. Go to https://supabase.com
2. Sign up (free, no credit card)
3. Create new project (takes ~2 minutes)
4. Go to **Settings → Database** → Copy connection string
5. Go to **SQL Editor** → New query → Paste `backend/schema.sql` → Run

**Upgrade path:** $25/month Pro plan (8 GB database, 50 GB bandwidth, better performance)

---

#### Alternative: **Neon** (Good for pure PostgreSQL)

**Pros:**
- ✅ **Serverless PostgreSQL**: Auto-scales, pay for what you use
- ✅ **Branching**: Create database branches (like Git branches) - great for testing
- ✅ **Free tier**: 3 GB storage, 192 MB RAM
- ✅ **PostgreSQL 15+**: Latest features

**Cons:**
- ⚠️ More complex pricing (usage-based)
- ⚠️ Fewer built-in features than Supabase

**Best for:** If you only need PostgreSQL and want advanced features like branching

**Setup:** https://neon.tech → Sign up → Create project → Copy connection string

---

#### Alternative: **Railway** (Simple, good for small projects)

**Pros:**
- ✅ **$5 free credit monthly** (enough for small projects)
- ✅ **Simple pricing**: Easy to understand
- ✅ **One-click deploy**: Can deploy backend too

**Cons:**
- ⚠️ Free credit expires monthly
- ⚠️ Need to monitor usage

**Best for:** Quick testing, small projects

**Setup:** https://railway.app → New Project → PostgreSQL → Copy connection string

---

#### Quick Comparison Table

| Feature | **Supabase** ⭐ | Neon | Railway |
|---------|----------------|------|---------|
| **Free Tier** | 500 MB DB, 2 GB bandwidth | 3 GB storage | $5 credit/month |
| **Upgrade Cost** | $25/month Pro | Usage-based | Pay-as-you-go |
| **Best For** | Full-featured apps | Pure PostgreSQL needs | Simple projects |
| **Setup Time** | 2 minutes | 2 minutes | 1 minute |
| **Credit Card** | Not required | Not required | Not required |
| **Dashboard** | Excellent | Good | Basic |
| **Bonus Features** | Auth, Storage, Realtime | Branching | Deploy backend too |
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**My Recommendation:** Start with **Supabase** - it's the easiest, most feature-rich, and has the clearest upgrade path.

---

#### **Recommendation: Start with Supabase**

1. **Sign up**: https://supabase.com (free, no credit card)
2. **Create project**: Click "New Project" → Choose organization → Name it "bslnd-app"
3. **Wait 2 minutes** for database to provision
4. **Get connection string**: 
   - Go to **Settings** (gear icon) → **Database**
   - Under "Connection string", select "URI"
   - Copy the connection string (looks like: `postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres`)
5. **Run schema**: 
   - Go to **SQL Editor** (left sidebar)
   - Click "New query"
   - Open `backend/schema.sql` from your project
   - Copy all SQL and paste into Supabase SQL Editor
   - Click "Run" (or press Ctrl+Enter)
   - ✅ You should see "Success. No rows returned"

**Option B: Local PostgreSQL**
1. Install PostgreSQL from https://www.postgresql.org/download/windows/
2. Create database: `createdb bslnd_db`
3. Run: `psql bslnd_db < backend/schema.sql`
4. Connection string: `postgresql://postgres:yourpassword@localhost:5432/bslnd_db`

### 1.2 Configure Backend

```powershell
# Navigate to backend folder
cd backend

# Create .env file from template
copy env.example .env

# Edit .env file (use Notepad or any editor)
notepad .env
```

**Edit `.env` file with:**
```env
PORT=3000
DATABASE_URL=your-postgresql-connection-string-here
JWT_SECRET=my-super-secret-jwt-key-change-this
NODE_ENV=development
```

### 1.3 Install Backend Dependencies & Start Server

```powershell
# Install Node.js packages
npm install

# Start the backend server
npm start
```

You should see: `🚀 BSLND Backend API running on port 3000`

**Keep this terminal window open!** The backend must keep running.

---

## Step 2: Check Flutter Installation

### 2.1 Check if Flutter is Installed

```powershell
flutter --version
```

**If you see a version number:** ✅ Flutter is installed, continue to Step 2.2

**If you see "command not found":**
1. Download Flutter: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH:
   - Press `Win + X` → System → Advanced system settings
   - Environment Variables → System variables → Path → Edit → New
   - Add: `C:\src\flutter\bin`
   - OK → Restart terminal

### 2.2 Enable Windows Desktop Support

```powershell
# Check Flutter setup
flutter doctor

# Enable Windows desktop (if not already enabled)
flutter config --enable-windows-desktop
```

### 2.3 Install Flutter Dependencies

```powershell
# Navigate to project root
cd C:\PP\Ekaum

# Install dependencies
flutter pub get
```

---

## Step 3: Update API URL for Windows

The app needs to connect to your backend. Check the API URL:

```powershell
# Check current API URL
Get-Content lib\core\services\api_service.dart | Select-String "baseUrl"
```

For **Windows desktop app**, use: `http://localhost:3000/api`

If it's different, update `lib/core/services/api_service.dart` line 10:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

---

## Step 4: Run the App on Windows

### Option A: Using Run Script (Easiest)

```powershell
# Make sure backend is running first!
# Then in a NEW terminal:
.\run_app.ps1
```

### Option B: Manual Commands

```powershell
# Check available devices (should show Windows)
flutter devices

# Run on Windows desktop
flutter run -d windows
```

---

## Quick Testing Workflow

1. **Terminal 1 - Backend:**
   ```powershell
   cd backend
   npm start
   ```
   ✅ Wait for: "🚀 BSLND Backend API running on port 3000"

2. **Terminal 2 - Flutter App:**
   ```powershell
   cd C:\PP\Ekaum
   flutter run -d windows
   ```

3. **Test the app:**
   - App should launch on Windows
   - Try registering a new account
   - Try logging in
   - Browse features

---

## Troubleshooting

### Backend Issues

**"Cannot find module"**
```powershell
cd backend
npm install
```

**"Database connection error"**
- Check `.env` file has correct `DATABASE_URL`
- Test connection string with: `psql "your-connection-string"`
- For cloud databases, check firewall/IP whitelist

**"Port 3000 already in use"**
- Change PORT in `.env` to another port (e.g., 3001)
- Update `api_service.dart` to match

### Flutter Issues

**"Flutter not found"**
- Add Flutter to PATH (see Step 2.1)
- Restart terminal after adding to PATH

**"Windows desktop not supported"**
```powershell
flutter config --enable-windows-desktop
flutter doctor
```

**"No devices found"**
```powershell
# Check if Windows desktop is enabled
flutter devices

# If not listed, enable it:
flutter config --enable-windows-desktop
```

**App shows "Network error" or can't connect**
- Verify backend is running (check Terminal 1)
- Verify API URL in `lib/core/services/api_service.dart` is `http://localhost:3000/api`
- Test backend manually: Open browser → `http://localhost:3000/health`

### Build Errors

**"Unable to find Dart SDK"**
```powershell
flutter doctor -v
# Follow the instructions to fix issues
```

**Gradle errors (if building Android instead)**
- Make sure you're using: `flutter run -d windows`
- Or remove Android build files if not needed

---

## Testing Checklist

After everything is running:

- [ ] Backend server running on port 3000
- [ ] App launches on Windows desktop
- [ ] Can see login/register screen
- [ ] Can register new account
- [ ] Can login with registered account
- [ ] Home screen loads
- [ ] Features are accessible
- [ ] No console errors

---

## Next Steps

Once testing is successful:
- Test all features
- Check payment integration (requires Instamojo setup)
- Test on Android/iOS if needed
- Deploy backend to cloud (Heroku, Railway, etc.)
- Build release version

---

## Quick Command Reference

```powershell
# Backend
cd backend
npm install          # First time only
npm start            # Start server

# Flutter
cd C:\PP\Ekaum
flutter pub get      # Install dependencies
flutter devices      # List devices
flutter run -d windows  # Run on Windows
flutter doctor       # Check setup
```

