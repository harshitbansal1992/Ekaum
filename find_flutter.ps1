# Find and Use Flutter SDK

Write-Host "Searching for Flutter SDK..." -ForegroundColor Cyan
Write-Host ""

$found = $false
$commonPaths = @(
    "C:\src\flutter",
    "C:\flutter",
    "C:\tools\flutter",
    "D:\flutter",
    "D:\src\flutter",
    "$env:USERPROFILE\flutter",
    "$env:USERPROFILE\src\flutter"
)

foreach ($path in $commonPaths) {
    $flutterBat = Join-Path $path "bin\flutter.bat"
    if (Test-Path $flutterBat) {
        Write-Host "FOUND FLUTTER: $path" -ForegroundColor Green
        $binPath = Join-Path $path "bin"
        $env:Path = "$binPath;" + $env:Path
        $found = $true
        
        Write-Host ""
        Write-Host "Testing Flutter..." -ForegroundColor Yellow
        flutter --version | Select-Object -First 1
        
        Write-Host ""
        Write-Host "Changing to project directory..." -ForegroundColor Yellow
        Set-Location "c:\PP\Ekaum"
        
        Write-Host ""
        Write-Host "Running: flutter pub get" -ForegroundColor Cyan
        flutter pub get
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "SUCCESS! Dependencies installed." -ForegroundColor Green
            Write-Host ""
            Write-Host "Checking for devices..." -ForegroundColor Yellow
            flutter devices
            Write-Host ""
            Write-Host "To run the app: flutter run" -ForegroundColor Yellow
        }
        
        break
    }
}

if (-not $found) {
    Write-Host "Flutter not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide the Flutter installation path, or" -ForegroundColor Yellow
    Write-Host "add Flutter to your system PATH." -ForegroundColor Yellow
}


