# ⚠️ Flutter Installation Required

Flutter is not currently installed or not in your system PATH.

---

## 🚀 Quick Install Guide

### Step 1: Download Flutter

1. Go to: **https://flutter.dev/docs/get-started/install/windows**
2. Download the latest stable Flutter SDK (ZIP file)
3. File size: ~1.5 GB

### Step 2: Extract Flutter

1. Extract the ZIP file to a location **without spaces** in the path
2. **Recommended location**: `C:\src\flutter`
3. **Alternative**: `C:\flutter`
4. ⚠️ **Don't extract to**: `C:\Program Files\` (has spaces)

### Step 3: Add Flutter to PATH

**Windows 10/11:**

1. Press `Win + X` → Click **"System"**
2. Click **"Advanced system settings"** (right side)
3. Click **"Environment Variables"** button
4. Under **"System variables"**, find **"Path"** → Click **"Edit"**
5. Click **"New"** → Add: `C:\src\flutter\bin` (or your Flutter path)
6. Click **OK** on all dialogs
7. **Close and reopen your terminal/IDE**

### Step 4: Verify Installation

Open a **new** terminal/PowerShell and run:

```powershell
flutter --version
flutter doctor
```

You should see Flutter version information.

---

## ✅ After Installation

Once Flutter is installed, you can continue with:

```powershell
cd C:\PP\Ekaum
flutter pub get
flutter run -d windows
```

Or use the script:
```powershell
.\run_app.ps1
```

---

## 🔧 Alternative: Use Flutter Without PATH

If you don't want to add Flutter to PATH, you can use the full path:

```powershell
# Replace with your actual Flutter path
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run -d windows
```

---

## 📝 Current Status

- ✅ Backend: Running and connected
- ✅ Database: Ready
- ⚠️ Flutter: Needs installation

Once Flutter is installed, everything else is ready to go!

