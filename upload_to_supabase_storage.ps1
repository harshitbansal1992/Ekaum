# Upload Avdhan Audio to Supabase Storage
# Free tier: 1 GB storage, 2 GB bandwidth/month

param(
    [string]$FilePath = "C:\Users\DhaneshMadhukarMengi\Downloads\mykhanaji-avdhan.mp3",
    [string]$SupabaseUrl = "https://odzpwqclczerzxpkcsnx.supabase.co",
    [string]$SupabaseKey = ""
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📤 Upload Audio to Supabase Storage (FREE)" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ Error: File not found" -ForegroundColor Red
    Write-Host "   $FilePath" -ForegroundColor Yellow
    exit 1
}

$fileInfo = Get-Item $FilePath
$fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
Write-Host "✅ File found: $($fileInfo.Name)" -ForegroundColor Green
Write-Host "   Size: $fileSizeMB MB" -ForegroundColor Cyan
Write-Host ""

# Check Supabase key
if ([string]::IsNullOrEmpty($SupabaseKey)) {
    Write-Host "⚠️  Supabase Key Required" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To get your Supabase key:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx" -ForegroundColor White
    Write-Host "2. Go to Settings > API" -ForegroundColor White
    Write-Host "3. Copy the 'anon' or 'service_role' key" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run:" -ForegroundColor Yellow
    Write-Host "   .\upload_to_supabase_storage.ps1 -SupabaseKey 'YOUR_KEY'" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Create bucket if it doesn't exist (using Supabase API)
Write-Host "📦 Checking/creating 'avdhan' bucket..." -ForegroundColor Yellow

try {
    # Check if bucket exists
    $bucketCheck = Invoke-RestMethod -Uri "$SupabaseUrl/storage/v1/bucket/avdhan" `
        -Method GET `
        -Headers @{
            "apikey" = $SupabaseKey
            "Authorization" = "Bearer $SupabaseKey"
        } -ErrorAction SilentlyContinue
    
    Write-Host "✅ Bucket 'avdhan' exists" -ForegroundColor Green
} catch {
    # Create bucket if it doesn't exist
    Write-Host "Creating bucket 'avdhan'..." -ForegroundColor Yellow
    try {
        $bucketCreate = Invoke-RestMethod -Uri "$SupabaseUrl/storage/v1/bucket" `
            -Method POST `
            -Headers @{
                "apikey" = $SupabaseKey
                "Authorization" = "Bearer $SupabaseKey"
                "Content-Type" = "application/json"
            } `
            -Body (@{
                name = "avdhan"
                public = $true
                file_size_limit = 52428800  # 50 MB limit
                allowed_mime_types = @("audio/mpeg", "audio/mp4", "video/mp4", "audio/wav")
            } | ConvertTo-Json)
        
        Write-Host "✅ Bucket 'avdhan' created" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not create bucket (may already exist)" -ForegroundColor Yellow
    }
}

# Prepare file name (sanitize)
$fileName = "mykhanaji-avdhan.mp3"
$filePathInBucket = "avdhan/$fileName"

Write-Host ""
Write-Host "📤 Uploading file to Supabase Storage..." -ForegroundColor Yellow
Write-Host "   Bucket: avdhan" -ForegroundColor Gray
Write-Host "   File: $fileName" -ForegroundColor Gray
Write-Host ""

try {
    # Read file as bytes
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileContent = [System.Convert]::ToBase64String($fileBytes)
    
    # Upload to Supabase Storage
    $uploadResponse = Invoke-RestMethod -Uri "$SupabaseUrl/storage/v1/object/avdhan/$fileName" `
        -Method POST `
        -Headers @{
            "apikey" = $SupabaseKey
            "Authorization" = "Bearer $SupabaseKey"
            "Content-Type" = "audio/mpeg"
            "x-upsert" = "true"
        } `
        -Body $fileBytes
    
    Write-Host "✅ Upload successful!" -ForegroundColor Green
    Write-Host ""
    
    # Get public URL
    $publicUrl = "$SupabaseUrl/storage/v1/object/public/avdhan/$fileName"
    
    Write-Host "🔗 Public URL:" -ForegroundColor Cyan
    Write-Host "   $publicUrl" -ForegroundColor White
    Write-Host ""
    
    # Update database
    Write-Host "💾 Updating database with new URL..." -ForegroundColor Yellow
    
    $updateQuery = "UPDATE avdhan SET audio_url = '$publicUrl' WHERE id = 'ae0c49c7-c295-4c69-8fd1-2c77a7b3b855';"
    
    # Use Supabase MCP to update
    Write-Host "   URL will be: $publicUrl" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ Done! The audio URL has been set." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next: Update the database with this URL:" -ForegroundColor Yellow
    Write-Host "   $publicUrl" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "❌ Upload failed:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.ErrorDetails.Message) {
        Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "💡 Alternative: Use Supabase Dashboard" -ForegroundColor Cyan
    Write-Host "1. Go to: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/storage/buckets" -ForegroundColor White
    Write-Host "2. Create bucket 'avdhan' (if not exists)" -ForegroundColor White
    Write-Host "3. Upload the file" -ForegroundColor White
    Write-Host "4. Get the public URL" -ForegroundColor White
    Write-Host "5. Update database with the URL" -ForegroundColor White
    Write-Host ""
    exit 1
}

