# Firebase Auto-Configuration Guide

## Quick Setup

Since FlutterFire CLI requires Flutter/Dart to be in PATH, here are the options:

### Option 1: Run Setup Script (Recommended)

**Windows:**
```bash
scripts\setup_firebase.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/setup_firebase.sh
./scripts/setup_firebase.sh
```

### Option 2: Manual FlutterFire CLI

If Flutter is in your PATH:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=ekaum-e5b36
```

### Option 3: Manual Configuration

If CLI tools are not available:

1. **Go to Firebase Console:**
   - https://console.firebase.google.com/
   - Select project: **ekaum-e5b36**

2. **Get Configuration Values:**
   - Go to Project Settings (gear icon)
   - Scroll to "Your apps" section
   - For each platform (Web, Android, iOS):

3. **Update `lib/firebase_options.dart`:**
   - Replace `YOUR_WEB_API_KEY` with actual API key
   - Replace `YOUR_WEB_APP_ID` with actual App ID
   - Replace `YOUR_MESSAGING_SENDER_ID` with actual Sender ID
   - Repeat for Android and iOS sections

4. **Add Configuration Files:**
   
   **Android:**
   - Download `google-services.json` from Firebase Console
   - Place in: `android/app/google-services.json`
   
   **iOS:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place in: `ios/Runner/GoogleService-Info.plist`
   - Open `ios/Runner.xcworkspace` in Xcode
   - Drag the file into the Runner project

## Current Configuration Status

✅ Project ID: `ekaum-e5b36`  
✅ Database URL: `https://ekaum-e5b36-default-rtdb.firebaseio.com`  
✅ Auth Domain: `ekaum-e5b36.firebaseapp.com`  
✅ Storage Bucket: `ekaum-e5b36.appspot.com`  

⚠️ **Action Required:** Update API keys and App IDs in `lib/firebase_options.dart`

## Verification

After configuration, verify by:

1. Running the app:
   ```bash
   flutter run
   ```

2. Testing authentication:
   - Try to register a new user
   - Check Firebase Console > Authentication for the new user

3. Testing database:
   - Check Firebase Console > Realtime Database
   - Data should appear when app writes to database

## Troubleshooting

### "Flutter not found"
- Add Flutter to your PATH
- Or use Option 3 (Manual Configuration)

### "Firebase CLI not authenticated"
```bash
firebase login
```

### "Project access denied"
- Ensure you have access to project `ekaum-e5b36`
- Check Firebase Console permissions

### Configuration file errors
- Ensure all API keys are correct
- Check that `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Verify package name matches in Firebase Console and app


