# Setup Scripts

## Firebase Configuration Scripts

### `setup_firebase.bat` (Windows)
Automated script to configure Firebase using FlutterFire CLI.

**Usage:**
```bash
scripts\setup_firebase.bat
```

**Requirements:**
- Flutter in PATH
- Firebase CLI installed and logged in
- Access to project `ekaum-e5b36`

### `setup_firebase.sh` (Linux/Mac)
Same as above but for Unix systems.

**Usage:**
```bash
chmod +x scripts/setup_firebase.sh
./scripts/setup_firebase.sh
```

### `configure_firebase.js` (Node.js)
Creates a template `firebase_options.dart` file with project ID pre-filled.

**Usage:**
```bash
node scripts/configure_firebase.js
```

**Note:** This only creates a template. You still need to fill in API keys manually.

## Manual Setup

If scripts don't work, see `FIREBASE_AUTO_SETUP.md` for manual configuration steps.


