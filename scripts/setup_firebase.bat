@echo off
echo ========================================
echo BSLND Firebase Configuration Setup
echo ========================================
echo.

echo Checking for Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not in PATH
    echo Please add Flutter to your PATH or run this from Flutter SDK directory
    echo.
    echo You can manually configure Firebase by:
    echo 1. Opening Firebase Console
    echo 2. Getting API keys from Project Settings
    echo 3. Updating lib/firebase_options.dart
    pause
    exit /b 1
)

echo Flutter found!
echo.

echo Installing FlutterFire CLI...
dart pub global activate flutterfire_cli
if %errorlevel% neq 0 (
    echo ERROR: Failed to install FlutterFire CLI
    pause
    exit /b 1
)

echo.
echo Configuring Firebase for project: ekaum-e5b36
flutterfire configure --project=ekaum-e5b36

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Firebase configuration failed
    echo Please check:
    echo 1. You are logged into Firebase CLI (run: firebase login)
    echo 2. You have access to project ekaum-e5b36
    echo 3. Flutter project is properly initialized
    pause
    exit /b 1
)

echo.
echo ========================================
echo Firebase configuration complete!
echo ========================================
echo.
echo Next steps:
echo 1. Review lib/firebase_options.dart
echo 2. Add google-services.json to android/app/
echo 3. Add GoogleService-Info.plist to ios/Runner/
echo.
pause


