# APK Build Information

## Building Release APK

The release APK is being built in parallel with the debug build.

## APK Location

Once build completes, the APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## What's the Difference?

### Debug APK (currently building)
- **Purpose:** Development and testing
- **Size:** Larger (includes debug symbols)
- **Performance:** Slower
- **Use:** For testing during development

### Release APK (building now)
- **Purpose:** Production/installation
- **Size:** Smaller (optimized)
- **Performance:** Faster
- **Use:** For distributing to users

## How to Install APK on Phone

### Method 1: Direct Transfer
1. Copy `app-release.apk` to your phone (USB, email, cloud)
2. On phone: Settings → Security → Enable "Install from Unknown Sources"
3. Open the APK file and install

### Method 2: ADB Install
```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 3: Share via Cloud
- Upload to Google Drive/Dropbox
- Download on phone
- Install

## APK File Size

Expected size: ~20-30 MB (depends on assets and dependencies)

## Build Time

Release build typically takes:
- First build: 5-10 minutes
- Subsequent builds: 2-5 minutes

## Both Builds Running

✅ **Debug APK:** Building (for testing)
✅ **Release APK:** Building (for installation)

Both will complete independently.

---

**The release APK will be ready for installation once the build completes!** 📱

