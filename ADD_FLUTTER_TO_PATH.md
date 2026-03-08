# How to Add Flutter to PATH Permanently (Windows)

## Method 1: Using System Settings (Recommended)

### Steps:

1. **Open System Properties**
   - Press `Win + X` and select **System**
   - Or: Right-click **This PC** → **Properties**
   - Click **Advanced system settings**

2. **Open Environment Variables**
   - Click **Environment Variables** button (bottom right)

3. **Edit PATH**
   - Under **User variables** (or **System variables**), find **Path**
   - Click **Edit**

4. **Add Flutter**
   - Click **New**
   - Paste: `C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin`
   - Click **OK** on all dialogs

5. **Restart Terminal**
   - Close all PowerShell/Command Prompt windows
   - Open a new terminal
   - Test with: `flutter --version`

## Method 2: Using PowerShell (Quick)

Run this in PowerShell **as Administrator**:

```powershell
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin",
    "User"
)
```

Then restart your terminal.

## Method 3: Using Command Prompt (Quick)

Run this in Command Prompt **as Administrator**:

```cmd
setx PATH "%PATH%;C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin"
```

Then restart your terminal.

## Verify It Works

After restarting terminal:

```powershell
flutter --version
flutter doctor
```

You should see Flutter version and doctor output without errors.

## Current Temporary Solution

Until you add it permanently, use this in each terminal session:

```powershell
$env:Path = "C:\Users\DhaneshMadhukarMengi\Downloads\flutter_windows_3.38.3-stable\flutter\bin;" + $env:Path
```

---

**Note:** After adding to PATH, you can run `flutter` commands from anywhere without specifying the full path!

