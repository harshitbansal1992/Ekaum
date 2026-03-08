# PowerShell script to start the Flutter app
Write-Host "=== Starting BSLND Flutter App ===" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is in PATH
$flutterPath = "C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin"
if (Test-Path $flutterPath) {
    $env:Path = "$flutterPath;" + $env:Path
    Write-Host "✅ Flutter SDK found" -ForegroundColor Green
} else {
    Write-Host "⚠️  Flutter SDK path not found, trying system PATH..." -ForegroundColor Yellow
}

# Check if Flutter is available
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Flutter found" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter not found in PATH!" -ForegroundColor Red
    Write-Host "Please add Flutter to PATH or update this script" -ForegroundColor Yellow
    exit 1
}

# Check if backend is running
Write-Host "Checking if backend is running..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✅ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend server not running!" -ForegroundColor Yellow
    Write-Host "Please start the backend first using: .\START_BACKEND.ps1" -ForegroundColor Yellow
    Write-Host "Or start it manually: cd backend && npm start" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Get connected devices
Write-Host ""
Write-Host "Checking for connected devices..." -ForegroundColor Cyan
$devices = flutter devices 2>&1
Write-Host $devices

# Ask user which device to use
Write-Host ""
Write-Host "Available options:" -ForegroundColor Cyan
Write-Host "1. Auto-select device (default)"
Write-Host "2. List devices and choose"
Write-Host "3. Run on Chrome (web)"
$choice = Read-Host "Enter choice (1-3)"

switch ($choice) {
    "2" {
        Write-Host ""
        flutter devices
        Write-Host ""
        $deviceId = Read-Host "Enter device ID to run on"
        if ($deviceId) {
            Write-Host "🚀 Starting app on device: $deviceId" -ForegroundColor Cyan
            flutter run -d $deviceId
        } else {
            Write-Host "❌ No device ID provided" -ForegroundColor Red
        }
    }
    "3" {
        Write-Host "🌐 Starting app on Chrome..." -ForegroundColor Cyan
        flutter run -d chrome
    }
    default {
        Write-Host "🚀 Starting app (auto-select device)..." -ForegroundColor Cyan
        flutter run
    }
}





