# BSLND Firebase Configuration Script (PowerShell)
# Run this script to automatically configure Firebase

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BSLND Firebase Configuration Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for Flutter
Write-Host "Checking for Flutter..." -ForegroundColor Yellow
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterPath) {
    Write-Host "ERROR: Flutter is not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please either:" -ForegroundColor Yellow
    Write-Host "1. Add Flutter to your PATH, or" -ForegroundColor Yellow
    Write-Host "2. Run this from Flutter SDK directory, or" -ForegroundColor Yellow
    Write-Host "3. Use manual configuration (see FIREBASE_AUTO_SETUP.md)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common Flutter locations:" -ForegroundColor Cyan
    Write-Host "  - C:\src\flutter\bin" -ForegroundColor Gray
    Write-Host "  - C:\flutter\bin" -ForegroundColor Gray
    Write-Host "  - %LOCALAPPDATA%\Pub\Cache\bin" -ForegroundColor Gray
    Write-Host ""
    
    # Try to find Flutter in common locations
    $commonPaths = @(
        "C:\src\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "$env:LOCALAPPDATA\Pub\Cache\bin\flutter.bat"
    )
    
    $foundFlutter = $null
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $foundFlutter = $path
            Write-Host "Found Flutter at: $path" -ForegroundColor Green
            Write-Host "Adding to PATH for this session..." -ForegroundColor Yellow
            $env:Path = (Split-Path $path) + ";" + $env:Path
            break
        }
    }
    
    if (-not $foundFlutter) {
        Write-Host "Could not find Flutter automatically." -ForegroundColor Red
        Write-Host "Please configure Firebase manually (see FIREBASE_AUTO_SETUP.md)" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host "Flutter found!" -ForegroundColor Green
Write-Host ""

# Install FlutterFire CLI
Write-Host "Installing FlutterFire CLI..." -ForegroundColor Yellow
dart pub global activate flutterfire_cli

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install FlutterFire CLI" -ForegroundColor Red
    Write-Host "You may need to run: dart pub global activate flutterfire_cli manually" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Configuring Firebase for project: ekaum-e5b36" -ForegroundColor Yellow
flutterfire configure --project=ekaum-e5b36

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Firebase configuration failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. You are logged into Firebase CLI (run: firebase login)" -ForegroundColor Yellow
    Write-Host "2. You have access to project ekaum-e5b36" -ForegroundColor Yellow
    Write-Host "3. Flutter project is properly initialized" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "For manual setup, see: FIREBASE_AUTO_SETUP.md" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Firebase configuration complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review lib/firebase_options.dart" -ForegroundColor Yellow
Write-Host "2. Add google-services.json to android/app/" -ForegroundColor Yellow
Write-Host "3. Add GoogleService-Info.plist to ios/Runner/" -ForegroundColor Yellow
Write-Host ""
Write-Host "Configuration files location:" -ForegroundColor Cyan
Write-Host "  - Firebase Console: https://console.firebase.google.com/project/ekaum-e5b36/settings/general" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"


