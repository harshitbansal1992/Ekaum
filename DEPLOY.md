# Deployment Guide

## Push to GitHub

1. **Create a GitHub repository** (if not already created):
   - Go to https://github.com/new
   - Repository name: `Ekaum` (or your preferred name)
   - Make it public or private
   - Don't initialize with README (we already have one)

2. **Add remote and push**:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/Ekaum.git
   git branch -M main
   git push -u origin main
   ```

   Or if using SSH:
   ```bash
   git remote add origin git@github.com:YOUR_USERNAME/Ekaum.git
   git branch -M main
   git push -u origin main
   ```

## GitHub Pages Setup

1. **Enable GitHub Pages**:
   - Go to your repository on GitHub
   - Settings → Pages
   - Source: Select "GitHub Actions"
   - Save

2. **The GitHub Actions workflow will**:
   - Build Android APK on every push
   - Attempt to build web version (may fail due to Firebase web compatibility)
   - Deploy web build to GitHub Pages if successful

## APK Distribution

The built APK will be available as an artifact in GitHub Actions:
- Go to Actions tab
- Click on the latest workflow run
- Download the `release-apk` artifact

Or create a GitHub Release:
1. Go to Releases → Create a new release
2. Tag: `v1.0.0`
3. Upload the APK from `build/app/outputs/flutter-apk/app-release.apk`
4. Publish release

## Web Build Note

The web build currently has Firebase compatibility issues. The workflow will:
- Try to build web version
- Continue even if it fails
- Deploy if successful

To fix web build later:
- Update Firebase packages to web-compatible versions
- Or use Firebase Hosting instead of GitHub Pages



