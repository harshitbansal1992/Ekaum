# Simple Flutter Run Script
# This script finds Flutter and runs the app

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BSLND App - Flutter Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to project directory
Set-Location $PSScriptRoot

# Try to find Flutter
$flutterFound = $false
$flutterPaths = @(
    "C:\src\flutter\bin\flutter.bat",
    "C:\flutter\bin\flutter.bat",
    "$env:USERPROFILE\flutter\bin\flutter.bat",
    "$env:LOCALAPPDATA\Pub\Cache\bin\flutter.bat"
)

foreach ($path in $flutterPaths) {
    if (Test-Path $path) {
        $binPath = Split-Path $path
        Write-Host "Found Flutter at: $binPath" -ForegroundColor Green
        $env:Path = "$binPath;" + $env:Path
        $flutterFound = $true
        break
    }
}

if (-not $flutterFound) {
    Write-Host "Flutter not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Install Flutter SDK" -ForegroundColor White
    Write-Host "2. Add Flutter to PATH" -ForegroundColor White
    Write-Host "3. Or edit this script with your Flutter path" -ForegroundColor White
    Write-Host ""
    Write-Host "Download Flutter: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

# Verify Flutter works
Write-Host "Verifying Flutter..." -ForegroundColor Yellow
try {
    $version = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter version: $version" -ForegroundColor Green
} catch {
    Write-Host "Flutter verification failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 1: Installing dependencies..." -ForegroundColor Cyan
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Checking devices..." -ForegroundColor Cyan
flutter devices

Write-Host ""
Write-Host "Step 3: Running app..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

flutter run

Read-Host "`nPress Enter to exit"


