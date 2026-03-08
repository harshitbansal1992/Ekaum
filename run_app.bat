@echo off
echo ========================================
echo BSLND Flutter App - Run Script
echo ========================================
echo.

cd /d "%~dp0"

echo Checking Flutter installation...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter is not in PATH
    echo.
    echo Please either:
    echo 1. Add Flutter to your PATH, or
    echo 2. Run this from Flutter SDK directory
    echo.
    echo Common Flutter locations:
    echo   - C:\src\flutter\bin
    echo   - C:\flutter\bin
    echo.
    pause
    exit /b 1
)

echo Flutter found!
echo.

echo Step 1: Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Step 2: Checking for connected devices...
flutter devices
echo.

echo Step 3: Running the app...
echo.
echo Select a device from the list above, or press Ctrl+C to cancel
echo.
flutter run

pause


