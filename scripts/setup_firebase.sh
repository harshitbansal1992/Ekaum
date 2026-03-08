#!/bin/bash

echo "========================================"
echo "BSLND Firebase Configuration Setup"
echo "========================================"
echo ""

echo "Checking for Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not in PATH"
    echo "Please add Flutter to your PATH"
    exit 1
fi

echo "Flutter found!"
echo ""

echo "Installing FlutterFire CLI..."
dart pub global activate flutterfire_cli

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install FlutterFire CLI"
    exit 1
fi

echo ""
echo "Configuring Firebase for project: ekaum-e5b36"
flutterfire configure --project=ekaum-e5b36

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Firebase configuration failed"
    echo "Please check:"
    echo "1. You are logged into Firebase CLI (run: firebase login)"
    echo "2. You have access to project ekaum-e5b36"
    echo "3. Flutter project is properly initialized"
    exit 1
fi

echo ""
echo "========================================"
echo "Firebase configuration complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Review lib/firebase_options.dart"
echo "2. Add google-services.json to android/app/"
echo "3. Add GoogleService-Info.plist to ios/Runner/"
echo ""


