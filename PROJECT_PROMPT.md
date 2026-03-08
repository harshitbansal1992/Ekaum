# BSLND Flutter Mobile App - Complete Project Prompt

## Project Overview

Build a comprehensive Flutter mobile application for BSLND organization and their spiritual leader. The app serves as a digital platform for spiritual services, content delivery, and community engagement.

**Organization Websites:**
- https://bslnd.in/
- https://mahabrahmrishi.com/

## Core Requirements

### 1. Nadi Dosh Calculator
- Calculate nadi and nadi dosh for couples
- Integrate logic from: https://github.com/dhaneshcodes/nadi-dosha-calculator
- Input fields: Name, Date of Birth, Time of Birth, Place of Birth for both male and female
- Display compatibility results with detailed explanation
- Port JavaScript/other language logic to Dart if needed

### 2. Rahu Kaal, Sandhya Kaal, Brahma Muhurat Calculator
- Calculate timings based on user's GPS location
- Integrate logic from:
  - https://github.com/harshlagyan/Rahukaal
  - https://github.com/itbslnd/Rahukaal
- Automatically detect location using device GPS
- Display:
  - Rahu Kaal (varies by day of week)
  - Sandhya Kaal (morning and evening)
  - Brahma Muhurat
  - Sunrise/Sunset times
- Show daily calendar view

### 3. Avdhan Audio Content
- Audio files stored in Firebase Realtime Database
- Users can listen to first 2 minutes for free (preview)
- After 2 minutes, prompt for subscription
- Monthly subscription: ₹500/month
- Subscription unlocks all Avdhan content
- Audio player with:
  - Play/pause controls
  - Progress tracking
  - Duration display
  - Preview limit enforcement

### 4. Samagam Schedules
- Display upcoming samagam (spiritual gathering) schedules
- Data managed via back office/admin panel
- Show:
  - Event title
  - Description
  - Start and end dates
  - Location and address
  - Optional image
- Calendar view
- Filter by date (upcoming events only)

### 5. Prabhu Kripa Patrika (Monthly Magazine)
- PDF issues stored in Firebase Realtime Database
- Users can read first 5 pages for free
- After 5 pages, prompt for payment
- Payment per issue (amount varies)
- After payment, full PDF access
- PDF viewer with:
  - Page navigation
  - Zoom controls
  - Preview limit enforcement

### 6. Pooja Item Ordering
- Integrate existing website: https://mndivine.com/product-category/pooja-samagari/
- Use WebView to display the website
- Allow users to browse and order pooja items
- Handle navigation within WebView
- Deep linking support if needed

### 7. Paath Services
Seven different paath services with comprehensive forms:

**Service Types & Prices:**
- Durga Saptashti paath - ₹21,000
- Durga Saptashti parihar paath - ₹21,000
- Durga Saptashti paath family - ₹51,000
- Durga Saptashti parihar paath family - ₹51,000
- Mahamritunjaya paath - ₹1,25,000
- Vishesh kripa Samadhan - ₹1,100
- Janam Kundli Samadhar - ₹1,100

**Form Fields (Required):**
- Full Name
- Date of Birth
- Time of Birth (HH:MM format)
- Place of Birth
- Father's/Husband's Name
- Gotra
- Caste

**Family Services:**
- For family services, include details of all family members
- Each member needs: Name, DOB, TOB, POB, Relationship

**Payment:**
- 6 equal installments option
- Track payment status per installment
- Form submission to Firebase Realtime Database
- Payment integration with Instamojo

### 8. Donation Feature
- Donation amount input
- User details: Name, Email, Phone, Optional Message
- Payment integration with Instamojo
- Donation history tracking
- Store in Firebase Realtime Database

## Technical Specifications

### Frontend (Flutter)

**State Management:** Riverpod (modern, type-safe, well-maintained)

**Architecture:** Clean Architecture with feature-based folder structure

**Key Dependencies:**
```yaml
# State Management
flutter_riverpod: ^2.4.9
riverpod_annotation: ^2.3.3

# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
firebase_database: ^10.4.0

# Location
geolocator: ^10.1.0
permission_handler: ^11.1.0

# Payment
http: ^1.1.2
dio: ^5.4.0

# WebView
webview_flutter: ^4.4.2

# Audio
just_audio: ^0.9.36
audio_service: ^0.18.11

# PDF
syncfusion_flutter_pdfviewer: ^24.1.41
pdfx: ^1.2.0

# Navigation
go_router: ^13.0.0

# UI
google_fonts: ^6.1.0
intl: ^0.18.1

# Storage
shared_preferences: ^2.2.2
path_provider: ^2.1.1

# Utils
url_launcher: ^6.2.2
connectivity_plus: ^5.0.2
```

**Project Structure:**
```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── config/
│   ├── constants/
│   ├── routes/
│   ├── services/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── home/
│   ├── nadi_dosh/
│   │   ├── data/
│   │   └── presentation/
│   ├── rahu_kaal/
│   ├── avdhan/
│   ├── samagam/
│   ├── patrika/
│   ├── pooja_items/
│   ├── paath_services/
│   ├── donation/
│   └── payment/
└── shared/
    └── widgets/
```

### Backend (Node.js)

**Technology Stack:**
- Express.js REST API
- Firebase Admin SDK
- Instamojo API integration

**Key Dependencies:**
```json
{
  "express": "^4.18.2",
  "firebase-admin": "^11.11.0",
  "cors": "^2.8.5",
  "dotenv": "^16.3.1",
  "body-parser": "^1.20.2",
  "axios": "^1.6.2"
}
```

**API Endpoints:**
- `GET /health` - Health check
- `GET /api/users/:userId` - Get user details
- `POST /api/subscriptions` - Create subscription
- `GET /api/subscriptions/:userId` - Get user subscription
- `POST /api/payments/webhook` - Instamojo webhook handler
- `GET /api/paath-forms/:userId` - Get user's paath forms
- `GET /api/donations/:userId` - Get user's donations
- `POST /api/admin/avdhan` - Add Avdhan audio (admin)
- `POST /api/admin/samagam` - Add Samagam event (admin)
- `POST /api/admin/patrika` - Add Patrika issue (admin)

### Database (Firebase Realtime Database)

**Project ID:** ekaum-e5b36

**Database URL:** https://ekaum-e5b36-default-rtdb.asia-southeast1.firebasedatabase.app

**Schema Structure:**
```
/users/{userId}
  - name, email, phone, createdAt

/subscriptions/{userId}
  - isActive, amount, paymentId, startDate, expiryDate

/avdhan/{audioId}
  - title, description, audioUrl, thumbnailUrl, duration, createdAt

/samagam/{eventId}
  - title, description, startDate, endDate, location, address, imageUrl

/patrika/{issueId}
  - title, month, year, pdfUrl, coverImageUrl, price, publishedDate

/patrika_purchases/{userId}/{issueId}
  - purchaseDate, amount, paymentId

/paath_forms/{formId}
  - serviceId, serviceName, userId, totalAmount, installments, 
    installmentAmount, name, dateOfBirth, timeOfBirth, placeOfBirth,
    fathersOrHusbandsName, gotra, caste, familyMembers, status, 
    paymentStatus, createdAt

/paath_payments/{formId}/{installmentNumber}
  - amount, paymentId, paymentDate, status

/donations/{donationId}
  - userId, amount, name, email, phone, message, status, paymentId, createdAt

/payments/{paymentId}
  - userId, type, amount, status, instamojoPaymentId, metadata, createdAt
```

**Security Rules:**
- Users can only read/write their own data
- Content (avdhan, samagam, patrika) is read-only for authenticated users
- Subscriptions and payments are read-only (managed by backend)
- Forms and donations are user-controlled

### Payment Integration

**Payment Gateway:** Instamojo

**Payment Types:**
1. **Subscription:** ₹500/month for Avdhan access
2. **Patrika:** Per-issue payment (varies)
3. **Paath Services:** 6 equal installments
4. **Donations:** User-specified amount

**Payment Flow:**
1. Create payment request via Instamojo API
2. Launch payment URL in external browser
3. Handle webhook callback
4. Verify payment status
5. Update database
6. Deep link back to app with payment status

**Deep Links:**
- `bslndapp://payment/subscription?payment_id={id}&payment_status={status}`
- `bslndapp://payment/patrika?payment_id={id}&payment_status={status}`
- `bslndapp://payment/paath?payment_id={id}&payment_status={status}`
- `bslndapp://payment/donation?payment_id={id}&payment_status={status}`

### Authentication

**Methods:**
- Email/Password authentication
- Phone authentication (optional, SMS quota: 10/day)

**User Data:**
- Stored in Firebase Realtime Database
- Profile: name, email, phone, createdAt

## Implementation Details

### Constants

```dart
// Subscription
static const double subscriptionPrice = 500.0; // ₹500 per month

// Paath Service Prices
static const double durgaSaptashtiPaath = 21000.0;
static const double durgaSaptashtiPariharPaath = 21000.0;
static const double durgaSaptashtiPaathFamily = 51000.0;
static const double durgaSaptashtiPariharPaathFamily = 51000.0;
static const double mahamritunjayaPaath = 125000.0;
static const double visheshKripaSamadhan = 1100.0;
static const double janamKundliSamadhar = 1100.0;

// Installments
static const int maxInstallments = 6;

// Preview Limits
static const int audioPreviewSeconds = 120; // 2 minutes
static const int patrikaPreviewPages = 5;
```

### Platform Configuration

**Android:**
- Package name: `com.bslnd.app`
- Min SDK: 21
- Target SDK: 33
- Google Services plugin: 4.4.4
- Firebase BoM: 34.6.0

**iOS:**
- Bundle ID: `com.bslnd.app`
- Location permissions required
- Deep link support

### Environment Variables

**Backend (.env):**
```
PORT=3000
FIREBASE_DATABASE_URL=https://ekaum-e5b36-default-rtdb.asia-southeast1.firebasedatabase.app
INSTAMOJO_API_KEY=your-instamojo-api-key
INSTAMOJO_AUTH_TOKEN=your-instamojo-auth-token
```

**Flutter (app_config.dart):**
```dart
PaymentService.initialize(
  'YOUR_INSTAMOJO_API_KEY',
  'YOUR_INSTAMOJO_AUTH_TOKEN',
);
```

## Setup Instructions

### Prerequisites
1. Flutter SDK (3.0.0 or higher)
2. Node.js (v16 or higher)
3. Firebase project: ekaum-e5b36
4. Instamojo account

### Flutter App Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:**
   - Run: `flutterfire configure --project=ekaum-e5b36`
   - Or manually update `lib/firebase_options.dart` with API keys
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

3. **Configure Payment:**
   - Edit `lib/core/config/app_config.dart`
   - Add Instamojo credentials

4. **Run the app:**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Create .env file:**
   ```
   PORT=3000
   FIREBASE_DATABASE_URL=https://ekaum-e5b36-default-rtdb.asia-southeast1.firebasedatabase.app
   INSTAMOJO_API_KEY=your-key
   INSTAMOJO_AUTH_TOKEN=your-token
   ```

3. **Add Firebase service account:**
   - Download from Firebase Console
   - Save as `backend/serviceAccountKey.json`

4. **Start server:**
   ```bash
   npm start
   ```

### Firebase Services Setup

1. **Enable Authentication:**
   - Firebase Console → Authentication → Sign-in method
   - Enable "Email/Password"
   - Enable "Phone" (optional)

2. **Create Realtime Database:**
   - Firebase Console → Realtime Database → Create Database
   - Location: asia-southeast1 (Singapore)
   - Start in test mode, then update security rules

3. **Set Security Rules:**
   - Copy rules from `firebase-database-rules.json`
   - Firebase Console → Realtime Database → Rules
   - Paste and publish

## Features Implementation Status

✅ **Completed:**
- Project structure and setup
- Authentication system (Email/Password)
- Nadi Dosh calculator
- Rahu Kaal calculator with GPS
- Avdhan audio player with subscription
- Samagam schedules
- Patrika PDF viewer
- Pooja items WebView
- Paath services forms
- Donation feature
- Payment integration (Instamojo)
- Backend API
- Firebase configuration
- Security rules

## Testing Checklist

- [ ] User registration and login
- [ ] Nadi Dosh calculation
- [ ] Rahu Kaal timings with location
- [ ] Avdhan audio preview and subscription
- [ ] Samagam event display
- [ ] Patrika preview and purchase
- [ ] Pooja items WebView
- [ ] Paath service form submission
- [ ] Donation flow
- [ ] Payment processing
- [ ] Deep link handling
- [ ] Backend API endpoints
- [ ] Firebase security rules

## Deployment Considerations

1. **Production Firebase Project:**
   - Create separate production project
   - Update configuration files
   - Set production security rules

2. **Backend Deployment:**
   - Deploy to hosting (Heroku, AWS, etc.)
   - Update webhook URLs
   - Set environment variables

3. **App Store Submission:**
   - Build release APK/IPA
   - Set up app signing
   - Configure app store listings

4. **Security:**
   - Review and tighten security rules
   - Implement API authentication
   - Secure API keys
   - Add rate limiting

## Documentation Files

- `README.md` - Project overview
- `QUICK_START.md` - Quick setup guide
- `SETUP_INSTRUCTIONS.md` - Comprehensive setup
- `FIREBASE_SETUP.md` - Firebase configuration
- `FIREBASE_SCHEMA.md` - Database structure
- `NEXT_STEPS.md` - Post-setup steps
- `COMPLETION_CHECKLIST.md` - Feature status
- `IMPLEMENTATION_SUMMARY.md` - Implementation overview
- `backend/README.md` - Backend API documentation

## Support & Resources

- Flutter Documentation: https://flutter.dev/docs
- Firebase Documentation: https://firebase.google.com/docs
- Instamojo API: https://docs.instamojo.com/
- Riverpod: https://riverpod.dev/

---

**Project Status:** ✅ Complete - Ready for testing and deployment

**Last Updated:** December 2024


