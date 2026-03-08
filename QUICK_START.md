# 🚀 Quick Start Guide - Testing the App

## Prerequisites

1. **Flutter SDK** - Already installed ✅
2. **Node.js** - Install from https://nodejs.org (v16+)
3. **PostgreSQL Database** - Choose a free option:
   - **Supabase** (Recommended): https://supabase.com → Create project → Get connection string
   - **Neon**: https://neon.tech → Create project → Get connection string
   - **Railway**: https://railway.app → Create PostgreSQL → Get connection string

## Step 1: Set Up Database (5 minutes)

1. Sign up for a free PostgreSQL database (Supabase recommended)
2. Copy your connection string (looks like: `postgresql://user:password@host:5432/dbname`)
3. Go to your database's SQL Editor
4. Copy and paste the contents of `backend/schema.sql`
5. Run the SQL script to create all tables

## Step 2: Set Up Backend (2 minutes)

1. Open terminal in the project folder
2. Navigate to backend:
   ```powershell
   cd backend
   ```

3. Install dependencies:
   ```powershell
   npm install
   ```

4. Create `.env` file:
   ```powershell
   copy env.example .env
   ```

5. Edit `.env` file and add:
   ```env
   DATABASE_URL=your-postgresql-connection-string-here
   JWT_SECRET=my-super-secret-jwt-key-change-this
   PORT=3000
   INSTAMOJO_API_KEY=your-key-here
   INSTAMOJO_AUTH_TOKEN=your-token-here
   NODE_ENV=development
   ```

6. Start backend server:
   ```powershell
   npm start
   ```
   
   You should see: `🚀 BSLND Backend API running on port 3000`

## Step 3: Set Up Flutter App (1 minute)

1. Open a NEW terminal (keep backend running)
2. Navigate to project root
3. Update API URL in `lib/core/services/api_service.dart`:
   - Change line 6: `static const String baseUrl = 'http://localhost:3000/api';`
   - For Android emulator: Use `http://10.0.2.2:3000/api` instead
   - For physical device: Use your computer's IP (e.g., `http://192.168.1.100:3000/api`)

4. Install Flutter dependencies:
   ```powershell
   flutter pub get
   ```

## Step 4: Run the App

### Option A: Run on Android Phone/Emulator

```powershell
flutter run
```

### Option B: Run on Specific Device

```powershell
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Quick Test Checklist

- [ ] Backend server running on port 3000
- [ ] Database connection working
- [ ] Flutter app starts without errors
- [ ] Can register a new account
- [ ] Can login
- [ ] Home screen loads

## Troubleshooting

### Backend won't start
- Check if Node.js is installed: `node --version`
- Check if port 3000 is available
- Verify `.env` file exists and has correct `DATABASE_URL`

### Database connection error
- Verify your connection string is correct
- Check if your database allows connections from your IP (for cloud databases)
- Try connecting with a PostgreSQL client to verify

### Flutter can't connect to backend
- **Android Emulator**: Use `http://10.0.2.2:3000/api`
- **Physical Device**: 
  - Find your computer's IP: `ipconfig` (Windows)
  - Use `http://YOUR_IP:3000/api`
  - Make sure phone and computer are on same WiFi
- **iOS Simulator**: Use `http://localhost:3000/api`

### App shows "Network error"
- Make sure backend is running
- Check the API URL in `api_service.dart`
- Check backend terminal for errors

## Development Tips

1. **Keep backend running** in one terminal
2. **Hot reload Flutter** with `r` in the Flutter terminal
3. **View backend logs** to debug API calls
4. **Check database** using your provider's dashboard

## Next Steps

Once everything is running:
- Test user registration
- Test login
- Browse through features
- Test payments (will need Instamojo setup for full testing)
