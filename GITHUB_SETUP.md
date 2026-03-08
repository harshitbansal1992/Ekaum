# GitHub Setup Guide

## ⚠️ IMPORTANT SECURITY NOTE

**You've shared your GitHub Personal Access Token!**

For security:
1. **Revoke this token** after we're done: https://github.com/settings/tokens
2. **Never commit tokens** to git repositories
3. **Use environment variables** or git credential helper instead

## Setting Up GitHub Repository

### Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `bslnd-app` (or your preferred name)
3. Description: "BSLND Organization Flutter Mobile App"
4. Choose: **Private** (recommended) or **Public**
5. **Don't** initialize with README, .gitignore, or license
6. Click "Create repository"

### Step 2: Push Code to GitHub

```powershell
cd c:\PP\Ekaum

# Add all files
git add .

# Commit
git commit -m "Initial commit - BSLND Flutter App"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://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@github.com/YOUR_USERNAME/bslnd-app.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Secure Your Token

**After pushing, revoke and regenerate your token:**

1. Go to: https://github.com/settings/tokens
2. Find the token and click "Revoke"
3. Create a new token with only needed permissions:
   - `repo` (for private repos)
   - `workflow` (if using GitHub Actions)

### Step 4: Use Git Credential Helper (Recommended)

Instead of using token in URL, use credential helper:

```powershell
# Configure credential helper
git config --global credential.helper wincred

# Then use normal URL
git remote set-url origin https://github.com/YOUR_USERNAME/bslnd-app.git

# Git will prompt for username and password (use token as password)
```

## GitHub Pages Setup (for Web Version)

### Step 1: Build Web Version

```powershell
flutter build web --release
```

### Step 2: Create gh-pages Branch

```powershell
git checkout -b gh-pages
git add build/web/*
git commit -m "Deploy web version"
git push origin gh-pages
```

### Step 3: Enable GitHub Pages

1. Go to repository Settings → Pages
2. Source: Deploy from `gh-pages` branch
3. Your app will be at: `https://YOUR_USERNAME.github.io/bslnd-app/`

## GitHub Releases (for APK Distribution)

### Create Release with APK

1. Go to repository → Releases → "Create a new release"
2. Tag: `v1.0.0`
3. Title: "BSLND App v1.0.0"
4. Upload `build/app/outputs/flutter-apk/app-release.apk`
5. Publish release

Users can download APK from: `https://github.com/YOUR_USERNAME/bslnd-app/releases`

## What NOT to Commit

Make sure `.gitignore` excludes:
- `android/local.properties` (contains local paths)
- `android/app/google-services.json` (contains Firebase keys - use template)
- `build/` folder
- `.dart_tool/`
- `*.apk` files

---

**Remember to revoke your token after setup!** 🔒

