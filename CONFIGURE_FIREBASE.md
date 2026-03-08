# Configure Firebase - Quick Guide

## ✅ Current Status

Your Firebase configuration file (`lib/firebase_options.dart`) is already set up with:
- ✅ Project ID: `ekaum-e5b36`
- ✅ Database URL: `https://ekaum-e5b36-default-rtdb.firebaseio.com`
- ✅ Auth Domain: `ekaum-e5b36.firebaseapp.com`
- ✅ Storage Bucket: `ekaum-e5b36.appspot.com`

## 🚀 Quick Setup (Choose One)

### Method 1: Automated Script (Easiest)

**Windows PowerShell:**
```powershell
.\scripts\setup_firebase.ps1
```

**Windows CMD:**
```cmd
scripts\setup_firebase.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/setup_firebase.sh
./scripts/setup_firebase.sh
```

### Method 2: Manual FlutterFire CLI

If Flutter is in your PATH:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=ekaum-e5b36
```

### Method 3: Manual Configuration

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com/project/ekaum-e5b36/settings/general

2. **Get API Keys:**
   - Click on each app (Web, Android, iOS) or create them
   - Copy the values:
     - `apiKey`
     - `appId` (or `applicationId`)
     - `messagingSenderId`

3. **Update `lib/firebase_options.dart`:**
   - Replace `YOUR_WEB_API_KEY` with actual Web API key
   - Replace `YOUR_WEB_APP_ID` with actual Web App ID
   - Replace `YOUR_MESSAGING_SENDER_ID` with actual Sender ID
   - Repeat for Android and iOS sections

4. **Download Configuration Files:**
   
   **For Android:**
   - Download `google-services.json`
   - Save to: `android/app/google-services.json`
   
   **For iOS:**
   - Download `GoogleService-Info.plist`
   - Save to: `ios/Runner/GoogleService-Info.plist`
   - Open `ios/Runner.xcworkspace` in Xcode
   - Drag the file into the Runner project

## 📋 Checklist

After configuration, verify:

- [ ] `lib/firebase_options.dart` has real API keys (not placeholders)
- [ ] `android/app/google-services.json` exists (for Android builds)
- [ ] `ios/Runner/GoogleService-Info.plist` exists (for iOS builds)
- [ ] Firebase Authentication is enabled (Email/Password)
- [ ] Realtime Database is created
- [ ] Security rules are set (see `FIREBASE_SCHEMA.md`)

## 🔍 Verification

Test the configuration:

```bash
flutter run
```

Then try:
1. Register a new user
2. Check Firebase Console > Authentication
3. The new user should appear

## ❓ Troubleshooting

### "Flutter not found"
- Add Flutter to PATH, or
- Use Method 3 (Manual Configuration)

### "Firebase CLI not authenticated"
```bash
firebase login
```

### "Project access denied"
- Ensure you have access to project `ekaum-e5b36`
- Check Firebase Console > Project Settings > Users and permissions

### Still having issues?
See `FIREBASE_AUTO_SETUP.md` for detailed troubleshooting.


