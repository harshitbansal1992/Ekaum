# Fix MissingPluginException for just_audio
# This script will rebuild the app to register the plugin properly

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔧 Fixing just_audio Plugin Registration" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is in PATH
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterPath) {
    Write-Host "⚠️  Flutter not found in PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Trying to find Flutter in common locations..." -ForegroundColor Cyan
    
    $commonPaths = @(
        "C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin\flutter.bat",
        "C:\src\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "$env:LOCALAPPDATA\Pub\Cache\bin\flutter.bat"
    )
    
    $foundFlutter = $null
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $foundFlutter = $path
            Write-Host "✅ Found Flutter at: $path" -ForegroundColor Green
            $env:Path = (Split-Path $path) + ";" + $env:Path
            break
        }
    }
    
    if (-not $foundFlutter) {
        Write-Host ""
        Write-Host "❌ Could not find Flutter automatically." -ForegroundColor Red
        Write-Host ""
        Write-Host "Please run these commands manually:" -ForegroundColor Yellow
        Write-Host "1. flutter clean" -ForegroundColor White
        Write-Host "2. flutter pub get" -ForegroundColor White
        Write-Host "3. flutter run" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  IMPORTANT: Do a FULL REBUILD (flutter run), NOT hot reload!" -ForegroundColor Cyan
        Write-Host "   Hot reload won't fix MissingPluginException!" -ForegroundColor Cyan
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Step 1: Clean Flutter build
Write-Host ""
Write-Host "🧹 Step 1: Cleaning Flutter build..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Clean failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✅ Clean complete" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "📦 Step 2: Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 3: Check for connected devices
Write-Host "📱 Step 3: Checking connected devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Step 4: Rebuild and run
Write-Host "🚀 Step 4: Rebuilding app (this will register plugins)..." -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  IMPORTANT: This will do a FULL REBUILD (not hot reload)" -ForegroundColor Cyan
Write-Host "   Hot reload won't fix plugin registration issues!" -ForegroundColor Cyan
Write-Host "   The app will be completely rebuilt to register just_audio plugin." -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting rebuild..." -ForegroundColor White
Write-Host ""

flutter run

Write-Host ""
Write-Host "✅ If the app runs successfully, the plugin should now work!" -ForegroundColor Green
Write-Host ""

