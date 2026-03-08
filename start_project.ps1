# BSLND Project Startup Script
# Starts both backend and Flutter app

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 Starting BSLND Project" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Set Flutter path
$flutterPath = "C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin"
if (Test-Path $flutterPath) {
    $env:Path = $flutterPath + ";" + $env:Path
    Write-Host "✅ Flutter path configured" -ForegroundColor Green
} else {
    Write-Host "⚠️  Flutter path not found, trying system PATH..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 1: Starting Backend Server..." -ForegroundColor Yellow
Write-Host ""

# Start backend in new window
$backendScript = @"
cd '$PSScriptRoot\backend'
if (-not (Test-Path 'node_modules')) {
    Write-Host 'Installing backend dependencies...' -ForegroundColor Yellow
    npm install
}
Write-Host ''
Write-Host '═══════════════════════════════════════' -ForegroundColor Cyan
Write-Host '  Backend Server Running' -ForegroundColor Green
Write-Host '═══════════════════════════════════════' -ForegroundColor Cyan
Write-Host 'Server: http://localhost:3000' -ForegroundColor White
Write-Host ''
npm start
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript -WindowStyle Normal

Write-Host "✅ Backend server starting in new window..." -ForegroundColor Green
Write-Host ""

# Wait a bit for backend to start
Start-Sleep -Seconds 3

Write-Host "Step 2: Starting Flutter App..." -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Login Credentials:" -ForegroundColor Cyan
Write-Host "   Email:    test@bslnd.com" -ForegroundColor White
Write-Host "   Password: Test123456" -ForegroundColor White
Write-Host ""
Write-Host "Starting Flutter app (this may take 1-2 minutes for first build)..." -ForegroundColor Gray
Write-Host ""

# Change to project root
Set-Location $PSScriptRoot

# Run Flutter app
flutter run -d windows

