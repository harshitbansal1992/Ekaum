# Script to update Supabase connection string

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Update Supabase Connection String" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current connection string:" -ForegroundColor Yellow
if (Test-Path ".env") {
    Get-Content .env | Select-String "DATABASE_URL"
} else {
    Write-Host ".env file not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "To get the correct connection string:" -ForegroundColor Cyan
Write-Host "1. Go to: https://supabase.com/dashboard" -ForegroundColor White
Write-Host "2. Select your project" -ForegroundColor White
Write-Host "3. Settings → Database" -ForegroundColor White
Write-Host "4. Scroll to 'Connection string' section" -ForegroundColor White
Write-Host "5. Click 'URI' tab" -ForegroundColor White
Write-Host "6. Copy the connection string" -ForegroundColor White
Write-Host ""

$newConnectionString = Read-Host "Paste the connection string here (or press Enter to keep current)"

if ($newConnectionString -and $newConnectionString -ne "") {
    $content = Get-Content .env -Raw
    $content = $content -replace 'DATABASE_URL=.*', "DATABASE_URL=$newConnectionString"
    $content | Set-Content .env -NoNewline
    
    Write-Host ""
    Write-Host "✅ Connection string updated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Updated DATABASE_URL:" -ForegroundColor Cyan
    Get-Content .env | Select-String "DATABASE_URL"
    Write-Host ""
    Write-Host "⚠️  Restart the backend server for changes to take effect!" -ForegroundColor Yellow
} else {
    Write-Host "No changes made." -ForegroundColor Gray
}

Write-Host ""

