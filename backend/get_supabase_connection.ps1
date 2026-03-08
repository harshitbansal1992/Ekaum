# Script to help get Supabase connection string

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Get Supabase Connection String" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Your Supabase Project:" -ForegroundColor Yellow
Write-Host "  Project URL: https://odzpwqclczerzxpkcsnx.supabase.co" -ForegroundColor White
Write-Host "  Project Ref: odzpwqclczerzxpkcsnx" -ForegroundColor White
Write-Host "  Password: Tripursundhari9" -ForegroundColor White
Write-Host ""

Write-Host "Steps to get connection string:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open this URL in your browser:" -ForegroundColor Yellow
Write-Host "   https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/settings/database" -ForegroundColor White
Write-Host ""
Write-Host "2. Scroll to 'Connection string' section" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Click 'URI' tab" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Copy the 'Transaction mode' connection string (port 6543)" -ForegroundColor Yellow
Write-Host "   It should look like:" -ForegroundColor Gray
Write-Host "   postgresql://postgres.xxx:password@aws-0-region.pooler.supabase.com:6543/postgres" -ForegroundColor DarkGray
Write-Host ""
Write-Host "5. Make sure the password in the string is: Tripursundhari9" -ForegroundColor Yellow
Write-Host ""

$connectionString = Read-Host "Paste the connection string here"

if ($connectionString -and $connectionString -ne "") {
    # Update .env file
    $content = Get-Content .env -Raw
    $content = $content -replace 'DATABASE_URL=.*', "DATABASE_URL=$connectionString"
    $content | Set-Content .env -NoNewline
    
    Write-Host ""
    Write-Host "✅ Connection string updated in .env file!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Testing connection..." -ForegroundColor Yellow
    
    # Test connection
    $env:DATABASE_URL = $connectionString
    node -e "require('dotenv').config(); const { Pool } = require('pg'); const pool = new Pool({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } }); pool.query('SELECT NOW()').then(r => { console.log('✅ Connection successful!'); console.log('Database time:', r.rows[0].now); pool.end(); process.exit(0); }).catch(e => { console.error('❌ Connection failed:', e.message); process.exit(1); });"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Connection works! Backend should now be able to connect." -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  Restart your backend server for changes to take effect:" -ForegroundColor Yellow
        Write-Host "   cd C:\PP\Ekaum\backend" -ForegroundColor White
        Write-Host "   npm start" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "❌ Connection test failed. Please verify the connection string." -ForegroundColor Red
    }
} else {
    Write-Host "No connection string provided." -ForegroundColor Gray
}

Write-Host ""

