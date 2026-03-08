// Script to configure Firebase for Flutter
// Run with: node scripts/configure_firebase.js

const fs = require('fs');
const path = require('path');
const https = require('https');

const PROJECT_ID = 'ekaum-e5b36';
const FIREBASE_CONFIG_URL = `https://${PROJECT_ID}.firebaseapp.com/.well-known/firebase-config.json`;

console.log('Fetching Firebase configuration...');
console.log(`Project ID: ${PROJECT_ID}`);

// Note: This script requires Firebase CLI or manual configuration
// For automatic configuration, use: flutterfire configure --project=ekaum-e5b36

const firebaseOptionsTemplate = `// File generated for Firebase project: ${PROJECT_ID}
// Run: flutterfire configure --project=${PROJECT_ID} to auto-generate this file
// Or manually update the values below from Firebase Console

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: '${PROJECT_ID}',
    authDomain: '${PROJECT_ID}.firebaseapp.com',
    databaseURL: 'https://${PROJECT_ID}-default-rtdb.firebaseio.com',
    storageBucket: '${PROJECT_ID}.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: '${PROJECT_ID}',
    authDomain: '${PROJECT_ID}.firebaseapp.com',
    databaseURL: 'https://${PROJECT_ID}-default-rtdb.firebaseio.com',
    storageBucket: '${PROJECT_ID}.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: '${PROJECT_ID}',
    authDomain: '${PROJECT_ID}.firebaseapp.com',
    databaseURL: 'https://${PROJECT_ID}-default-rtdb.firebaseio.com',
    storageBucket: '${PROJECT_ID}.appspot.com',
    iosBundleId: 'com.bslnd.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: '${PROJECT_ID}',
    authDomain: '${PROJECT_ID}.firebaseapp.com',
    databaseURL: 'https://${PROJECT_ID}-default-rtdb.firebaseio.com',
    storageBucket: '${PROJECT_ID}.appspot.com',
    iosBundleId: 'com.bslnd.app',
  );
}
`;

const outputPath = path.join(__dirname, '..', 'lib', 'firebase_options.dart');
fs.writeFileSync(outputPath, firebaseOptionsTemplate);
console.log(`\n✅ Created firebase_options.dart template at: ${outputPath}`);
console.log('\n📝 Next steps:');
console.log('1. Go to Firebase Console: https://console.firebase.google.com/');
console.log(`2. Select project: ${PROJECT_ID}`);
console.log('3. Go to Project Settings > Your apps');
console.log('4. For each platform (Web, Android, iOS), copy the values:');
console.log('   - apiKey');
console.log('   - appId');
console.log('   - messagingSenderId');
console.log('5. Update lib/firebase_options.dart with these values');
console.log('\nOr run: flutterfire configure --project=' + PROJECT_ID);


