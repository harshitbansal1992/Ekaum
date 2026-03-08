# Quick GitHub Push Guide

## Option 1: Use the Setup Script (Recommended)

Run the interactive script:
```powershell
.\setup_github.ps1
```

The script will guide you through:
1. Entering your GitHub username
2. Entering repository name (default: Ekaum)
3. Creating the repository on GitHub (if needed)
4. Adding remote and pushing

## Option 2: Manual Setup

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `Ekaum` (or your preferred name)
3. Description: "BSLND Flutter Mobile App"
4. Choose Public or Private
5. **DO NOT** initialize with README, .gitignore, or license
6. Click "Create repository"

### Step 2: Add Remote and Push

Replace `YOUR_USERNAME` with your actual GitHub username:

```powershell
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/Ekaum.git

# Rename branch to main (optional, GitHub uses 'main' by default)
git branch -M main

# Push to GitHub
git push -u origin main
```

Or if you want to keep 'master' branch:
```powershell
git remote add origin https://github.com/YOUR_USERNAME/Ekaum.git
git push -u origin master
```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. Click **Save**

## What Happens Next?

Once you push, the GitHub Actions workflow (`.github/workflows/deploy.yml`) will automatically:

1. ✅ **Build Android APK** - Available as artifact in Actions tab
2. ⚠️ **Attempt Web Build** - May fail due to Firebase compatibility (won't block)
3. ✅ **Deploy to GitHub Pages** - If web build succeeds

## Access Your App

- **GitHub Repository**: `https://github.com/YOUR_USERNAME/Ekaum`
- **GitHub Pages** (if web build succeeds): `https://YOUR_USERNAME.github.io/Ekaum/`
- **APK Download**: Go to Actions → Latest workflow run → Download `release-apk` artifact

## Troubleshooting

### Authentication Issues

If push fails due to authentication:
- Use GitHub CLI: `gh auth login`
- Or use Personal Access Token: https://github.com/settings/tokens

### Repository Already Exists

If you get "repository already exists" error:
- The repository might already be created
- Just add the remote and push

### Branch Name Mismatch

If GitHub expects 'main' but you have 'master':
```powershell
git branch -M main
git push -u origin main
```



