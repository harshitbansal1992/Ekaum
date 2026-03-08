# 🔐 Test User Credentials

## ✅ Test Account Created

A test user has been created in your database for testing the app.

---

## 📧 Login Credentials

**Email:** `test@bslnd.com`  
**Password:** `Test123456`

---

## 🚀 How to Use

1. **Open the app** (Windows/Android/iOS)
2. **Navigate to Login screen**
3. **Enter credentials:**
   - Email: `test@bslnd.com`
   - Password: `Test123456`
4. **Click Login**
5. **Start testing features!**

---

## ✅ User Details

- **Name:** Test User
- **Email:** test@bslnd.com
- **Phone:** 1234567890
- **Status:** Active account
- **Created:** Just now

---

## 🔄 Create More Test Users

You can create more test users by:

### Option 1: Via App Registration
1. Use the app's registration screen
2. Enter new email and password
3. Complete registration

### Option 2: Via Backend API
```powershell
$body = @{
    email = "newuser@example.com"
    password = "Password123"
    name = "New User"
    phone = "9876543210"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method Post -Body $body -ContentType "application/json"
```

### Option 3: Via Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to Table Editor → `users` table
4. Click "Insert row"
5. Enter user details (password must be bcrypt hashed)

---

## 🔒 Security Note

⚠️ **This is a test account with a simple password.**  
For production, use strong passwords and proper authentication.

---

## 📝 Password Hash

If you need to create users directly in the database, the password hash for `Test123456` is:
```
$2a$10$bm//SNy9/krLIbAIu5VJLe8mH.tQcRV/0VWG6TXCcBPWICPA4k28e
```

**Never store plain text passwords!** Always use bcrypt hashing.

---

## 🎯 Quick Test

Try logging in with:
- Email: `test@bslnd.com`
- Password: `Test123456`

You should be able to access all features!

