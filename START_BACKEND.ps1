# PowerShell script to start the backend server
Write-Host "=== Starting BSLND Backend Server ===" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found!" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org" -ForegroundColor Yellow
    exit 1
}

# Navigate to backend directory
if (Test-Path "backend") {
    Set-Location backend
    Write-Host "📁 Changed to backend directory" -ForegroundColor Green
} else {
    Write-Host "❌ Backend directory not found!" -ForegroundColor Red
    exit 1
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    if (Test-Path "env.example") {
        Write-Host "Creating .env from env.example..." -ForegroundColor Yellow
        Copy-Item "env.example" ".env"
        Write-Host "✅ Created .env file" -ForegroundColor Green
        Write-Host "⚠️  Please edit .env file and add your DATABASE_URL and other settings!" -ForegroundColor Yellow
        Write-Host "Press any key to continue after editing .env..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "❌ env.example file not found!" -ForegroundColor Red
        exit 1
    }
}

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
}

# Start the server
Write-Host ""
Write-Host "🚀 Starting backend server..." -ForegroundColor Cyan
Write-Host "Server will run on http://localhost:3000" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

npm start





