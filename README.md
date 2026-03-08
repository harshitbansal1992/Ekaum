# BSLND Flutter Mobile App

A comprehensive Flutter mobile application for BSLND organization and their spiritual leader.

## Features

1. **Nadi Dosh Calculator** - Calculate nadi and nadi dosh for couples
2. **Rahu Kaal, Sandhya Kaal, Brahma Muhurat** - Time calculations based on GPS location
3. **Avdhan Audio** - Audio content with 2-minute preview and ₹500/month subscription
4. **Samagam Schedules** - Display upcoming event schedules
5. **Prabhu Kripa Patrika** - Monthly magazine with 5-page preview and paid access
6. **Pooja Item Ordering** - Order pooja items via WebView integration
7. **Paath Services** - Book 7 different paath services with 6-installment payment option
8. **Donations** - Make donations with Instamojo payment integration

## Quick Start

For detailed setup instructions, see:
- **Quick Start Guide**: `QUICK_START.md`
- **Firebase Setup**: `FIREBASE_SETUP.md`
- **Full Setup**: `SETUP_INSTRUCTIONS.md`

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Node.js (for backend)
- Firebase project: **ekaum-e5b36**
- Instamojo account

### Quick Setup

1. **Configure Firebase**:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=ekaum-e5b36
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   cd backend && npm install
   ```

3. **Configure payment service**:
   - Edit `lib/core/config/app_config.dart`
   - Add your Instamojo API credentials

4. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration (auto-generated)
├── core/                        # Core functionality
│   ├── config/                  # App configuration
│   ├── constants/               # App constants
│   ├── routes/                  # Navigation
│   ├── services/                # Firebase, Payment services
│   ├── theme/                   # App theme
│   └── utils/                   # Utilities
├── features/                    # Feature modules
│   ├── auth/                    # Authentication
│   ├── home/                    # Home screen
│   ├── nadi_dosh/               # Nadi Dosh calculator
│   ├── rahu_kaal/               # Rahu Kaal timings
│   ├── avdhan/                  # Audio player
│   ├── samagam/                 # Event schedules
│   ├── patrika/                 # Magazine viewer
│   ├── pooja_items/             # WebView for pooja items
│   ├── paath_services/          # Paath service forms
│   └── donation/                # Donation feature
└── shared/                      # Shared widgets

backend/
├── server.js                    # Express server
├── package.json                 # Dependencies
└── README.md                    # Backend guide
```

## Documentation

- `QUICK_START.md` - Quick setup guide
- `FIREBASE_SETUP.md` - Firebase configuration details
- `SETUP_INSTRUCTIONS.md` - Comprehensive setup instructions
- `FIREBASE_SCHEMA.md` - Database structure
- `IMPLEMENTATION_SUMMARY.md` - Implementation overview
- `backend/README.md` - Backend API documentation

## Technologies

- **Frontend**: Flutter 3.0+, Riverpod
- **Backend**: Node.js, Express.js
- **Database**: Firebase Realtime Database
- **Authentication**: Firebase Auth
- **Payment**: Instamojo
- **Location**: Geolocator
- **Audio**: Just Audio
- **PDF**: Syncfusion PDF Viewer

## Firebase Project

- **Project ID**: ekaum-e5b36
- **Database URL**: https://ekaum-e5b36-default-rtdb.firebaseio.com

## Backend Setup

See `backend/README.md` for detailed backend setup instructions.

## License

[Add your license here]

