# Install Fixed APK on Your Phone

## ✅ Crash Fixes Applied

The new APK has been built with all crash fixes:

1. ✅ **Firebase Double Initialization** - Fixed
2. ✅ **Error Handling** - Added to main() and all services
3. ✅ **Router Error Handling** - Added error screen
4. ✅ **Auth Provider** - Fixed initialization timing

## Install the New APK

### Option 1: Direct Install via ADB (Recommended)

```powershell
cd c:\PP\Ekaum
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

The `-r` flag replaces the existing app.

### Option 2: Manual Install

1. **Copy APK to phone:**
   - Location: `build\app\outputs\flutter-apk\app-debug.apk`
   - Transfer via USB, email, or cloud storage

2. **On your phone:**
   - Open File Manager
   - Find the APK file
   - Tap to install
   - Allow "Install from Unknown Sources" if prompted

3. **Open the app:**
   - Should now show login screen instead of black screen

## What Should Happen Now

✅ **App opens** without crashing  
✅ **Login screen appears** (not black screen)  
✅ **No immediate close**

## If Still Crashing

### Get Crash Logs:

```powershell
# Clear logs first
adb logcat -c

# Open app on phone, then run:
adb logcat | Select-String -Pattern 'flutter|BSLND|AndroidRuntime|FATAL|Exception'
```

### Common Issues:

1. **Missing google-services.json**
   - Check: `android/app/google-services.json` exists
   - If missing, copy from Downloads folder

2. **Network Required**
   - App needs internet for Firebase
   - Check phone has WiFi/data connection

3. **Permissions**
   - App needs INTERNET permission (already in manifest)
   - Location permission requested at runtime

## Test the App

1. **Open app** - Should show login screen
2. **Register** - Create a test account
3. **Login** - Sign in with credentials
4. **Navigate** - Test different features

---

**The fixed APK is ready! Install it and test!** 📱

