# Next Steps - BSLND App Setup

## ✅ Completed So Far

- [x] Flutter project structure created
- [x] All features implemented
- [x] Android app registered in Firebase
- [x] `google-services.json` added to `android/app/`
- [x] Gradle files updated with Firebase dependencies
- [x] Android Firebase configuration in `firebase_options.dart`

## 🔄 Immediate Next Steps

### 1. Complete Firebase Setup (Choose what you need)

#### Option A: Continue with iOS (if building for iOS)
1. In Firebase Console, click "Add app" → Select **iOS**
2. Bundle ID: `com.bslnd.app`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Update iOS section in `lib/firebase_options.dart` with iOS API keys

#### Option B: Continue with Web (if building for web)
1. In Firebase Console, click "Add app" → Select **Web**
2. App nickname: `BSLND Web`
3. Copy the config values
4. Update Web section in `lib/firebase_options.dart`

#### Option C: Skip for now (Android only)
- You can continue with just Android setup
- Add iOS/Web later if needed

### 2. Enable Firebase Services

Go to Firebase Console (https://console.firebase.google.com/project/ekaum-e5b36):

1. **Enable Authentication:**
   - Go to: Authentication → Sign-in method
   - Enable "Email/Password"
   - Enable "Phone" (optional, if you want phone auth)

2. **Create Realtime Database:**
   - Go to: Realtime Database → Create Database
   - Choose location (closest to your users)
   - Start in **test mode** for now (we'll update rules later)
   - Database URL: `https://ekaum-e5b36-default-rtdb.firebaseio.com`

3. **Set Security Rules:**
   - Go to: Realtime Database → Rules
   - Copy rules from `FIREBASE_SCHEMA.md`
   - Or use test mode temporarily for development

### 3. Configure Payment Service

1. Get Instamojo credentials:
   - Go to: https://www.instamojo.com/developers/
   - Get API Key and Auth Token

2. Update `lib/core/config/app_config.dart`:
   ```dart
   PaymentService.initialize(
     'YOUR_INSTAMOJO_API_KEY',  // Replace
     'YOUR_INSTAMOJO_AUTH_TOKEN', // Replace
   );
   ```

3. Update webhook URLs in `lib/core/services/payment_service.dart`:
   - Replace `https://your-backend-url.com` with your actual backend URL

### 4. Set Up Backend (Node.js)

1. Navigate to backend folder:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env` file:
   ```
   PORT=3000
   FIREBASE_DATABASE_URL=https://ekaum-e5b36-default-rtdb.firebaseio.com
   INSTAMOJO_API_KEY=your-instamojo-api-key
   INSTAMOJO_AUTH_TOKEN=your-instamojo-auth-token
   ```

4. Add Firebase service account:
   - Go to: Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `backend/serviceAccountKey.json`

5. Start backend:
   ```bash
   npm start
   ```

### 5. Test the App

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Test features:**
   - [ ] Register a new user
   - [ ] Login with credentials
   - [ ] Test Nadi Dosh calculator
   - [ ] Test Rahu Kaal (allow location permission)
   - [ ] Check Firebase Console for user data

### 6. Add Test Content (via Backend API)

Once backend is running, add test content:

**Add Avdhan Audio:**
```bash
curl -X POST http://localhost:3000/api/admin/avdhan \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Audio",
    "description": "Test description",
    "audioUrl": "https://example.com/audio.mp3",
    "duration": 3600
  }'
```

**Add Samagam Event:**
```bash
curl -X POST http://localhost:3000/api/admin/samagam \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Event",
    "description": "Test description",
    "startDate": "2024-12-01T00:00:00Z",
    "endDate": "2024-12-02T00:00:00Z",
    "location": "Test Location"
  }'
```

**Add Patrika Issue:**
```bash
curl -X POST http://localhost:3000/api/admin/patrika \
  -H "Content-Type: application/json" \
  -d '{
    "title": "December 2024",
    "month": "December",
    "year": 2024,
    "pdfUrl": "https://example.com/patrika.pdf",
    "price": 100
  }'
```

## 📋 Priority Checklist

**Must Do (Before Testing):**
- [ ] Enable Firebase Authentication (Email/Password)
- [ ] Create Realtime Database
- [ ] Set basic security rules
- [ ] Run `flutter pub get`
- [ ] Test app runs without errors

**Should Do (For Full Functionality):**
- [ ] Configure Instamojo payment credentials
- [ ] Set up backend server
- [ ] Add test content via API
- [ ] Test payment flows

**Nice to Have (Can Do Later):**
- [ ] Add iOS app configuration
- [ ] Add Web app configuration
- [ ] Set up production environment
- [ ] Add analytics

## 🚀 Quick Start (Minimum Setup)

If you want to test quickly:

1. **Enable Auth & Database:**
   - Firebase Console → Authentication → Enable Email/Password
   - Firebase Console → Realtime Database → Create Database (test mode)

2. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Test basic features:**
   - Register user
   - Login
   - Test calculators

You can add payment and backend setup later!

## 📚 Documentation Reference

- `CONFIGURE_FIREBASE.md` - Firebase setup details
- `FIREBASE_SCHEMA.md` - Database structure and security rules
- `SETUP_INSTRUCTIONS.md` - Comprehensive setup guide
- `backend/README.md` - Backend API documentation

## ❓ Need Help?

- Check `FIREBASE_AUTO_SETUP.md` for Firebase troubleshooting
- See `QUICK_START.md` for quick setup guide
- Review `COMPLETION_CHECKLIST.md` for full feature status


