# Firebase Setup Instructions

## Project ID: ekaum-e5b36

### Step 1: Get Firebase Configuration Values

You need to get the actual API keys and App IDs from Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ekaum-e5b36**
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section

### Step 2: Update firebase_options.dart

Replace the placeholder values in `lib/firebase_options.dart`:

#### For Android:
1. Click on Android app (or add one if not exists)
2. Package name: `com.bslnd.app` (or your package name)
3. Download `google-services.json`
4. Copy the values from Firebase Console:
   - `apiKey` → `YOUR_ANDROID_API_KEY`
   - `appId` → `YOUR_ANDROID_APP_ID`
   - `messagingSenderId` → `YOUR_MESSAGING_SENDER_ID`

#### For iOS:
1. Click on iOS app (or add one if not exists)
2. Bundle ID: `com.bslnd.app` (or your bundle ID)
3. Download `GoogleService-Info.plist`
4. Copy the values from Firebase Console:
   - `apiKey` → `YOUR_IOS_API_KEY`
   - `appId` → `YOUR_IOS_APP_ID`
   - `messagingSenderId` → `YOUR_MESSAGING_SENDER_ID`

#### For Web:
1. Click on Web app (or add one if not exists)
2. Copy the values from Firebase Console:
   - `apiKey` → `YOUR_WEB_API_KEY`
   - `appId` → `YOUR_WEB_APP_ID`
   - `messagingSenderId` → `YOUR_MESSAGING_SENDER_ID`

### Step 3: Add Configuration Files

#### Android:
1. Place `google-services.json` in `android/app/`
2. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```
3. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS:
1. Place `GoogleService-Info.plist` in `ios/Runner/`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Drag the file into the Runner project
4. Make sure "Copy items if needed" is checked

### Step 4: Enable Firebase Services

In Firebase Console:

1. **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"
   - Enable "Phone" (if needed)

2. **Realtime Database**:
   - Go to Realtime Database
   - Create database (choose location)
   - Set security rules (see FIREBASE_SCHEMA.md)

3. **Storage** (optional, for audio/PDF files):
   - Go to Storage
   - Get started
   - Set security rules

### Step 5: Using FlutterFire CLI (Alternative)

If you have Flutter and Dart in PATH, you can run:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure --project=ekaum-e5b36
```

This will automatically generate `firebase_options.dart` with correct values.

### Step 6: Verify Configuration

After updating the values, the app should connect to Firebase. Test by:
1. Running the app
2. Trying to register a new user
3. Checking Firebase Console > Authentication for the new user

### Database URL

The database URL is already set in `firebase_options.dart`:
```
https://ekaum-e5b36-default-rtdb.firebaseio.com
```

If you're using a different region, update the URL accordingly.

