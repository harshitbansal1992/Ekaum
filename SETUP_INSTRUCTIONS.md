# BSLND Flutter App - Setup Instructions

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Node.js** (v16 or higher)
   - Download from: https://nodejs.org/

3. **Firebase Account**
   - Create a project at: https://console.firebase.google.com/
   - Enable Authentication (Email/Password)
   - Enable Realtime Database
   - Download configuration files

4. **Instamojo Account**
   - Sign up at: https://www.instamojo.com/
   - Get API Key and Auth Token from dashboard

## Flutter App Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Firebase

#### Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Add to `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```
4. Add to `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/GoogleService-Info.plist`
3. Open `ios/Runner.xcworkspace` in Xcode
4. Add the file to the Runner target

### 3. Configure Payment Service

In `lib/main.dart` or a configuration file, initialize the payment service:

```dart
PaymentService.initialize(
  'your-instamojo-api-key',
  'your-instamojo-auth-token',
);
```

### 4. Update Deep Links

Configure deep links for payment redirects:

#### Android:
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="bslndapp" />
</intent-filter>
```

#### iOS:
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bslndapp</string>
        </array>
    </dict>
</array>
```

### 5. Run the App

```bash
flutter run
```

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Create `backend/.env`:
```
PORT=3000
FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com
INSTAMOJO_API_KEY=your-instamojo-api-key
INSTAMOJO_AUTH_TOKEN=your-instamojo-auth-token
```

### 3. Add Firebase Service Account

1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Save as `backend/serviceAccountKey.json`

### 4. Start the Server

```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## Firebase Database Setup

1. Go to Firebase Console > Realtime Database
2. Create database (choose location)
3. Set up security rules (see `FIREBASE_SCHEMA.md`)
4. Create indexes for better performance

## Testing

### Test Authentication
- Register a new user
- Login with credentials
- Verify user data in Firebase

### Test Features
1. **Nadi Dosh**: Enter couple details and calculate
2. **Rahu Kaal**: Allow location permission and view timings
3. **Avdhan**: Upload test audio files via admin API
4. **Samagam**: Add test events via admin API
5. **Patrika**: Add test PDFs via admin API
6. **Pooja Items**: WebView should load the website
7. **Paath Services**: Fill form and submit
8. **Donation**: Enter amount and submit

## Admin Operations

Use the backend API to manage content:

### Add Avdhan Audio
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

### Add Samagam Event
```bash
curl -X POST http://localhost:3000/api/admin/samagam \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Event",
    "description": "Test description",
    "startDate": "2024-01-01T00:00:00Z",
    "endDate": "2024-01-02T00:00:00Z",
    "location": "Test Location"
  }'
```

### Add Patrika Issue
```bash
curl -X POST http://localhost:3000/api/admin/patrika \
  -H "Content-Type: application/json" \
  -d '{
    "title": "January 2024",
    "month": "January",
    "year": 2024,
    "pdfUrl": "https://example.com/patrika.pdf",
    "price": 100
  }'
```

## Troubleshooting

### Firebase Connection Issues
- Verify `google-services.json` / `GoogleService-Info.plist` are in correct locations
- Check Firebase project settings
- Verify internet connection

### Payment Issues
- Verify Instamojo API credentials
- Check webhook URL is accessible
- Verify deep link configuration

### Location Permission
- Android: Check `AndroidManifest.xml` has location permissions
- iOS: Check `Info.plist` has location usage descriptions

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Flutter version compatibility
- Verify all dependencies are compatible

## Next Steps

1. Set up production Firebase project
2. Configure production Instamojo account
3. Set up CI/CD pipeline
4. Add analytics and crash reporting
5. Implement push notifications
6. Add admin panel UI for content management

