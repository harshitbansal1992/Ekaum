# PowerShell script to set up .env file with Supabase connection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BSLND Backend - .env Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Your Supabase connection details
$DATABASE_URL = "postgresql://postgres:Tripursundhari9@db.odzpwqclczerzxpkcsnx.supabase.co:5432/postgres"
$JWT_SECRET = "yxbD8P2vEOkgSYji73eMLHWAsuThtRm6"

# Create .env file content
$envContent = @"
# Backend Environment Variables

# Server Port
PORT=3000

# PostgreSQL Database URL (Supabase)
DATABASE_URL=$DATABASE_URL

# JWT Secret Key
JWT_SECRET=$JWT_SECRET

# Instamojo Payment Gateway (Optional - can add later)
INSTAMOJO_API_KEY=your-instamojo-api-key
INSTAMOJO_AUTH_TOKEN=your-instamojo-auth-token

# Environment
NODE_ENV=development
"@

# Write to .env file
$envContent | Out-File -FilePath ".env" -Encoding utf8 -NoNewline

Write-Host "✅ .env file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Database: Supabase PostgreSQL" -ForegroundColor Gray
Write-Host "  Connection: Direct (port 5432)" -ForegroundColor Gray
Write-Host "  JWT Secret: Generated" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. npm install" -ForegroundColor Cyan
Write-Host "  2. npm start" -ForegroundColor Cyan
Write-Host "  3. Test: http://localhost:3000/health" -ForegroundColor Cyan
Write-Host ""



