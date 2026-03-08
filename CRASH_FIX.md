# App Crash Fix

## Issue
App shows black screen and closes immediately when opened on Android phone.

## Root Cause
Firebase was being initialized twice:
1. In `main()` with proper options
2. In `FirebaseService.initialize()` without options (causing conflict)

## Fixes Applied

### 1. ✅ Fixed Firebase Double Initialization
- **File:** `lib/main.dart`
- **Change:** Check if Firebase is already initialized before initializing
- **Change:** Removed duplicate initialization in `FirebaseService.initialize()`

### 2. ✅ Added Error Handling
- Wrapped Firebase initialization in try-catch
- App won't crash if Firebase fails to initialize
- Errors are logged but app continues

### 3. ✅ Fixed FirebaseService
- Removed `Firebase.initializeApp()` call from `FirebaseService.initialize()`
- Now just gets instances (Firebase already initialized in main)

## Testing

After rebuilding, the app should:
1. ✅ Initialize Firebase properly
2. ✅ Show login screen (not black screen)
3. ✅ Not crash on startup

## If Still Crashing

Check logs with:
```powershell
adb logcat | Select-String -Pattern 'flutter|BSLND|AndroidRuntime|FATAL'
```

Common issues:
- Missing `google-services.json` in `android/app/`
- Firebase project not active
- Network connectivity issues
- Missing permissions

---

**Rebuilding APK with fixes...** 🔄

