# GitHub Repository Setup Script
# This script will help you push your code to GitHub

Write-Host "=== GitHub Repository Setup ===" -ForegroundColor Green
Write-Host ""

# Check if remote already exists
$remoteExists = git remote get-url origin 2>$null
if ($remoteExists) {
    Write-Host "Remote 'origin' already exists: $remoteExists" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "Exiting. Remote not changed." -ForegroundColor Yellow
        exit
    }
    git remote remove origin
}

# Get GitHub username
Write-Host "Enter your GitHub username:" -ForegroundColor Cyan
$username = Read-Host

if ([string]::IsNullOrWhiteSpace($username)) {
    Write-Host "Error: Username cannot be empty!" -ForegroundColor Red
    exit 1
}

# Get repository name (default: Ekaum)
Write-Host ""
Write-Host "Enter repository name (default: Ekaum):" -ForegroundColor Cyan
$repoName = Read-Host
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "Ekaum"
}

# Ask if repository exists
Write-Host ""
Write-Host "Does the repository '$repoName' already exist on GitHub? (y/n):" -ForegroundColor Cyan
$exists = Read-Host

if ($exists -ne "y") {
    Write-Host ""
    Write-Host "Please create the repository first:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: $repoName" -ForegroundColor White
    Write-Host "3. Make it public or private (your choice)" -ForegroundColor White
    Write-Host "4. DO NOT initialize with README, .gitignore, or license" -ForegroundColor White
    Write-Host "5. Click 'Create repository'" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Press Enter after creating the repository..."
}

# Add remote
$remoteUrl = "https://github.com/$username/$repoName.git"
Write-Host ""
Write-Host "Adding remote: $remoteUrl" -ForegroundColor Cyan
git remote add origin $remoteUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to add remote" -ForegroundColor Red
    exit 1
}

# Rename branch to main if needed
$currentBranch = git branch --show-current
if ($currentBranch -eq "master") {
    Write-Host ""
    Write-Host "Current branch is 'master'. Do you want to rename it to 'main'? (y/n):" -ForegroundColor Cyan
    $rename = Read-Host
    if ($rename -eq "y") {
        git branch -M main
        $branchName = "main"
    } else {
        $branchName = "master"
    }
} else {
    $branchName = $currentBranch
}

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Green
Write-Host "Remote: $remoteUrl" -ForegroundColor Cyan
Write-Host "Branch: $branchName" -ForegroundColor Cyan
Write-Host ""

git push -u origin $branchName

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Success! ===" -ForegroundColor Green
    Write-Host "Your code has been pushed to GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/$username/$repoName" -ForegroundColor White
    Write-Host "2. Go to Settings → Pages" -ForegroundColor White
    Write-Host "3. Source: Select 'GitHub Actions'" -ForegroundColor White
    Write-Host "4. Save" -ForegroundColor White
    Write-Host ""
    Write-Host "The GitHub Actions workflow will automatically:" -ForegroundColor Cyan
    Write-Host "- Build Android APK on every push" -ForegroundColor White
    Write-Host "- Attempt web build" -ForegroundColor White
    Write-Host "- Deploy to GitHub Pages if web build succeeds" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Error: Failed to push to GitHub" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "1. The repository exists on GitHub" -ForegroundColor White
    Write-Host "2. You have push access" -ForegroundColor White
    Write-Host "3. You're authenticated (use GitHub CLI or personal access token)" -ForegroundColor White
}



