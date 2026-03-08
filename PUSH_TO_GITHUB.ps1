# Quick GitHub Push Script
# Usage: .\push_to_github.ps1 -Username "YOUR_GITHUB_USERNAME"

param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [string]$RepoName = "Ekaum"
)

Write-Host "=== Pushing to GitHub ===" -ForegroundColor Green
Write-Host "Username: $Username" -ForegroundColor Cyan
Write-Host "Repository: $RepoName" -ForegroundColor Cyan
Write-Host ""

# Check if remote exists
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Remote 'origin' already exists: $existingRemote" -ForegroundColor Yellow
    git remote remove origin
    Write-Host "Removed existing remote" -ForegroundColor Green
}

# Add remote
$remoteUrl = "https://github.com/$Username/$RepoName.git"
Write-Host "Adding remote: $remoteUrl" -ForegroundColor Cyan
git remote add origin $remoteUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to add remote" -ForegroundColor Red
    exit 1
}

# Check current branch
$currentBranch = git branch --show-current
Write-Host "Current branch: $currentBranch" -ForegroundColor Cyan

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Green
git push -u origin $currentBranch

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Success! ===" -ForegroundColor Green
    Write-Host "Repository: https://github.com/$Username/$RepoName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next: Enable GitHub Pages at:" -ForegroundColor Yellow
    Write-Host "https://github.com/$Username/$RepoName/settings/pages" -ForegroundColor White
    Write-Host "Source: GitHub Actions" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "=== Push Failed ===" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "1. Repository exists at: https://github.com/$Username/$RepoName" -ForegroundColor White
    Write-Host "2. You have push access" -ForegroundColor White
    Write-Host "3. You're authenticated (GitHub CLI or Personal Access Token)" -ForegroundColor White
    Write-Host ""
    Write-Host "Create repository at: https://github.com/new" -ForegroundColor Cyan
}
