# 🔐 Login Credentials for Testing

## ✅ Test User Account

A test user has been created in your database.

---

## 📧 Login Information

**Email:** `test@bslnd.com`  
**Password:** `Test123456`

---

## 🚀 How to Login

1. **Open your BSLND app** (Windows/Android/iOS)
2. **Navigate to the Login screen**
3. **Enter the credentials:**
   ```
   Email:    test@bslnd.com
   Password: Test123456
   ```
4. **Click "Login" or "Sign In"**
5. **You should be logged in successfully!**

---

## ✅ User Details

- **User ID:** e6e08bff-a1b7-4bb3-980f-709f375ddfa2
- **Email:** test@bslnd.com
- **Name:** Test User
- **Phone:** 1234567890
- **Status:** Active
- **Created:** 2026-01-03

---

## 🔄 Create Additional Test Users

### Via App Registration (Recommended)
1. Use the app's registration screen
2. Enter a new email and password
3. Complete the registration form
4. The user will be created automatically

### Via Backend API
```powershell
$body = @{
    email = "newuser@example.com"
    password = "YourPassword123"
    name = "New User Name"
    phone = "9876543210"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method Post -Body $body -ContentType "application/json"
```

---

## 🎯 What You Can Test

Once logged in, you can test:
- ✅ Home screen navigation
- ✅ Nadi Dosh Calculator
- ✅ Rahu Kaal Calculator
- ✅ Avdhan Audio Player
- ✅ Samagam Events
- ✅ Patrika PDF Viewer
- ✅ Pooja Items
- ✅ Paath Services Forms
- ✅ Donations
- ✅ Payment Integration

---

## 🔒 Security Notes

⚠️ **This is a test account:**
- Simple password for easy testing
- For production, use strong passwords
- Never share production credentials

---

## 📝 Troubleshooting

### Can't Login?
1. **Check backend is running:**
   - Open: http://localhost:3000/health
   - Should show: `{"status":"ok"}`

2. **Verify database connection:**
   - Backend should show: `✅ Connected to PostgreSQL database`

3. **Try registering a new account:**
   - Use the app's registration screen
   - This will test the full flow

### Backend Not Running?
```powershell
cd C:\PP\Ekaum\backend
npm start
```

---

## ✅ Ready to Test!

Your test account is ready. Use these credentials to login and explore all features!

**Email:** `test@bslnd.com`  
**Password:** `Test123456`

