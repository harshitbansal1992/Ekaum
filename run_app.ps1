# BSLND Flutter App - Run Script (PowerShell)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BSLND Flutter App - Run Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterPath) {
    Write-Host ""
    Write-Host "ERROR: Flutter is not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please either:" -ForegroundColor Yellow
    Write-Host "1. Add Flutter to your PATH, or" -ForegroundColor Yellow
    Write-Host "2. Run this from Flutter SDK directory" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common Flutter locations:" -ForegroundColor Cyan
    Write-Host "  - C:\src\flutter\bin" -ForegroundColor Gray
    Write-Host "  - C:\flutter\bin" -ForegroundColor Gray
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
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host "Flutter found!" -ForegroundColor Green
Write-Host ""

Write-Host "Step 1: Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Failed to install dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Checking for connected devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

Write-Host "Step 3: Running the app..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Select a device from the list above, or press Ctrl+C to cancel" -ForegroundColor Cyan
Write-Host ""

flutter run

Read-Host "Press Enter to exit"


