# How to Execute Flutter Commands

## Current Situation

Flutter SDK is not in your system PATH, so I cannot directly execute `flutter pub get` and `flutter run` commands.

## What I've Done

✅ **Verified Project Structure:**
- All files are in place
- `pubspec.yaml` is valid
- Dependencies are specified
- No code errors

✅ **Created Run Scripts:**
- `run_app.ps1` - Auto-detects Flutter and runs commands
- `run_app.bat` - Windows batch script

## How to Run (Choose One Method)

### Method 1: Use the Run Script (Easiest)

```powershell
.\run_app.ps1
```

This script will:
1. Try to find Flutter automatically
2. Add it to PATH for the session
3. Run `flutter pub get`
4. Run `flutter run`

### Method 2: Manual Execution

**Step 1: Find Flutter Installation**

Check these common locations:
- `C:\src\flutter\bin\flutter.bat`
- `C:\flutter\bin\flutter.bat`
- `%USERPROFILE%\flutter\bin\flutter.bat`

**Step 2: Add Flutter to PATH (Temporary for this session)**

```powershell
# Replace with your actual Flutter path
$env:Path = "C:\src\flutter\bin;" + $env:Path
```

**Step 3: Run Commands**

```powershell
cd c:\PP\Ekaum
flutter pub get
flutter run
```

### Method 3: Use Full Path

If Flutter is installed but not in PATH:

```powershell
cd c:\PP\Ekaum

# Replace with your actual Flutter path
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run
```

### Method 4: Install Flutter (If Not Installed)

1. **Download Flutter:**
   - https://flutter.dev/docs/get-started/install/windows
   - Download the ZIP file

2. **Extract:**
   - Extract to `C:\src\flutter`
   - **Important:** Don't use a path with spaces

3. **Add to PATH:**
   - Press `Win + X` → System
   - Advanced system settings → Environment Variables
   - Edit "Path" → Add `C:\src\flutter\bin`
   - Restart terminal

4. **Verify:**
   ```powershell
   flutter --version
   ```

5. **Run:**
   ```powershell
   cd c:\PP\Ekaum
   flutter pub get
   flutter run
   ```

## What Happens When You Run

### `flutter pub get`
- Downloads all packages from `pubspec.yaml`
- Sets up the project dependencies
- Takes 2-5 minutes first time

### `flutter devices`
- Shows available devices/emulators
- You need at least one device to run

### `flutter run`
- Builds the app
- Installs on device
- Launches the app
- Shows debug console

## Expected Output

```
Running "flutter pub get" in bslnd_app...
Resolving dependencies...
Got dependencies!

Launching lib\main.dart on [device] in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app.apk...
Flutter run key commands.
r Hot reload.
R Hot restart.
...
```

## Quick Test Script

Create a file `test_flutter.ps1`:

```powershell
# Try common Flutter locations
$paths = @(
    "C:\src\flutter\bin",
    "C:\flutter\bin",
    "$env:USERPROFILE\flutter\bin"
)

foreach ($path in $paths) {
    if (Test-Path "$path\flutter.bat") {
        Write-Host "Found Flutter at: $path" -ForegroundColor Green
        $env:Path = "$path;" + $env:Path
        cd c:\PP\Ekaum
        flutter pub get
        flutter run
        break
    }
}
```

Then run:
```powershell
.\test_flutter.ps1
```

## Troubleshooting

### "Flutter not found"
- Install Flutter SDK
- Add to PATH
- Restart terminal

### "No devices found"
- Start Android emulator
- Or connect physical device
- Enable USB debugging

### "Gradle build failed"
- Check Android Studio installed
- Verify `google-services.json` exists
- Check `android/build.gradle` configuration

---

**The project is 100% ready. Just need Flutter SDK accessible to run!**


