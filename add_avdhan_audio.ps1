# Script to add Avdhan audio to database
# This script will help you add the audio file to the Avdhan collection

param(
    [string]$AudioFilePath = "C:\Users\DhaneshMadhukarMengi\Downloads\mykhanaji-avdhan.mp3",
    [string]$Title = "महबरहम मयखन अवधन यग - रजन 10 मनट कर",
    [string]$Description = "सतगर वण - शसतर क बत",
    [string]$AudioUrl = "",
    [string]$ThumbnailUrl = "",
    [int]$Duration = 600  # 10 minutes in seconds
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📻 Add Avdhan Audio to Database" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if file exists
if (-not (Test-Path $AudioFilePath)) {
    Write-Host "❌ Error: Audio file not found at:" -ForegroundColor Red
    Write-Host "   $AudioFilePath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please provide the correct file path." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Audio file found" -ForegroundColor Green
Write-Host "   File: $(Split-Path $AudioFilePath -Leaf)" -ForegroundColor Gray
Write-Host ""

# Get file size
$fileInfo = Get-Item $AudioFilePath
$fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
Write-Host "📊 File Info:" -ForegroundColor Cyan
Write-Host "   Size: $fileSizeMB MB" -ForegroundColor White
Write-Host ""

# Check if AudioUrl is provided
if ([string]::IsNullOrEmpty($AudioUrl)) {
    Write-Host "⚠️  IMPORTANT: Audio URL is required!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You need to upload the audio file to a cloud storage service first." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "1. Upload to Firebase Storage" -ForegroundColor White
    Write-Host "2. Upload to AWS S3" -ForegroundColor White
    Write-Host "3. Upload to any public URL" -ForegroundColor White
    Write-Host ""
    Write-Host "Once uploaded, provide the URL using -AudioUrl parameter" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Cyan
    Write-Host '   .\add_avdhan_audio.ps1 -AudioUrl "https://storage.googleapis.com/your-bucket/audio.mp4"' -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "📝 Audio Details:" -ForegroundColor Cyan
Write-Host "   Title: $Title" -ForegroundColor White
Write-Host "   Description: $Description" -ForegroundColor White
Write-Host "   Audio URL: $AudioUrl" -ForegroundColor White
Write-Host "   Duration: $Duration seconds ($([math]::Round($Duration/60, 1)) minutes)" -ForegroundColor White
Write-Host ""

# Prompt for admin token
Write-Host "🔐 Admin Authentication Required" -ForegroundColor Yellow
$adminToken = Read-Host "Enter admin JWT token (or press Enter to use test@bslnd.com token)"

if ([string]::IsNullOrEmpty($adminToken)) {
    Write-Host ""
    Write-Host "⚠️  You need to login first to get a token." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To get a token:" -ForegroundColor Cyan
    Write-Host "1. Login via the app or API" -ForegroundColor White
    Write-Host "2. Get the JWT token from the response" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use curl:" -ForegroundColor Cyan
    Write-Host '   curl -X POST http://localhost:3000/api/auth/login \' -ForegroundColor Gray
    Write-Host '     -H "Content-Type: application/json" \' -ForegroundColor Gray
    Write-Host '     -d "{\"email\":\"test@bslnd.com\",\"password\":\"Test123456\"}"' -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "🚀 Adding audio to database..." -ForegroundColor Yellow

# Prepare JSON payload
$body = @{
    title = $Title
    description = $Description
    audioUrl = $AudioUrl
    thumbnailUrl = $ThumbnailUrl
    duration = $Duration
} | ConvertTo-Json

# Make API call
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/avdhan" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $adminToken"
        } `
        -Body $body

    Write-Host ""
    Write-Host "✅ Success! Audio added to database" -ForegroundColor Green
    Write-Host "   ID: $($response.id)" -ForegroundColor White
    Write-Host ""
    Write-Host "The audio is now available in the Avdhan section!" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "❌ Error adding audio:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.ErrorDetails.Message) {
        Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
    Write-Host ""
    exit 1
}

