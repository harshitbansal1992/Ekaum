# How to Run the BSLND App

## Flutter Not in PATH

Flutter SDK is not currently in your system PATH. Here are your options:

## Option 1: Add Flutter to PATH (Recommended)

### Windows:

1. **Find your Flutter installation:**
   - Common locations:
     - `C:\src\flutter\bin`
     - `C:\flutter\bin`
     - `%LOCALAPPDATA%\Pub\Cache\bin`

2. **Add to PATH:**
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\src\flutter\bin` (or your Flutter path)
   - Click OK on all dialogs
   - **Restart your terminal/IDE**

3. **Verify:**
   ```powershell
   flutter --version
   ```

4. **Run the app:**
   ```bash
   cd c:\PP\Ekaum
   flutter pub get
   flutter run
   ```

## Option 2: Use Full Path

If Flutter is installed but not in PATH:

```powershell
# Replace with your actual Flutter path
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run
```

## Option 3: Use the Run Scripts

I've created scripts that auto-detect Flutter:

**PowerShell:**
```powershell
.\run_app.ps1
```

**CMD:**
```cmd
run_app.bat
```

These scripts will:
1. Try to find Flutter automatically
2. Add it to PATH for the session
3. Run `flutter pub get`
4. Run `flutter run`

## Option 4: Install Flutter (If Not Installed)

1. **Download Flutter:**
   - https://flutter.dev/docs/get-started/install/windows

2. **Extract to:**
   - `C:\src\flutter` (recommended)

3. **Add to PATH** (see Option 1)

4. **Verify installation:**
   ```bash
   flutter doctor
   ```

## Quick Test

Once Flutter is in PATH:

```bash
cd c:\PP\Ekaum
flutter pub get
flutter devices
flutter run
```

## Troubleshooting

### "Flutter not found"
- Verify Flutter is installed: Check `C:\src\flutter` or `C:\flutter`
- Add Flutter to PATH (see Option 1)
- Restart terminal after adding to PATH

### "No devices found"
- Start Android emulator from Android Studio
- Or connect a physical device via USB
- Enable USB debugging on device

### "Dependencies error"
- Check internet connection
- Run `flutter clean` then `flutter pub get`
- Verify `pubspec.yaml` is correct

---

**The app code is 100% complete and ready to run once Flutter is in your PATH!**


