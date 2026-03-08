# ⚠️ Important: Update Security Rules for BSLND App

## Current Situation

You've published security rules, but they appear to be for a **job portal application** (jobs, companies, applications).

The **BSLND spiritual app** needs different rules for:
- Users
- Subscriptions (Avdhan)
- Avdhan audio content
- Samagam events
- Patrika magazine issues
- Patrika purchases
- Paath service forms
- Paath payments
- Donations
- Payment records

## ✅ Correct Security Rules for BSLND App

Go to Firebase Console and update the rules:

**Firebase Console → Realtime Database → Rules**

Copy and paste these rules:

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    "subscriptions": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "false"
      }
    },
    "avdhan": {
      ".read": "auth != null",
      ".write": "false"
    },
    "samagam": {
      ".read": "auth != null",
      ".write": "false"
    },
    "patrika": {
      ".read": "auth != null",
      ".write": "false"
    },
    "patrika_purchases": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    "paath_forms": {
      "$formId": {
        ".read": "data.child('userId').val() === auth.uid",
        ".write": "data.child('userId').val() === auth.uid || !data.exists()"
      }
    },
    "paath_payments": {
      "$formId": {
        ".read": "root.child('paath_forms').child($formId).child('userId').val() === auth.uid",
        ".write": "false"
      }
    },
    "donations": {
      "$donationId": {
        ".read": "data.child('userId').val() === auth.uid",
        ".write": "data.child('userId').val() === auth.uid || !data.exists()"
      }
    },
    "payments": {
      "$paymentId": {
        ".read": "data.child('userId').val() === auth.uid",
        ".write": "false"
      }
    }
  }
}
```

## 📋 What These Rules Do

### User Data (`/users`)
- ✅ Users can only read/write their own profile
- ✅ `$userId === auth.uid` ensures privacy

### Subscriptions (`/subscriptions`)
- ✅ Users can read their own subscription status
- ✅ Write disabled (managed by backend/webhook)

### Content (`/avdhan`, `/samagam`, `/patrika`)
- ✅ Authenticated users can read content
- ✅ Write disabled (managed by admin/backend)

### Purchases (`/patrika_purchases`)
- ✅ Users can read/write their own purchases

### Forms (`/paath_forms`)
- ✅ Users can read/write their own forms
- ✅ Can create new forms

### Payments (`/paath_payments`, `/payments`)
- ✅ Users can read their own payment records
- ✅ Write disabled (managed by backend/webhook)

### Donations (`/donations`)
- ✅ Users can read/write their own donations

## 🚀 Quick Update Steps

1. **Go to Firebase Console:**
   - https://console.firebase.google.com/project/ekaum-e5b36/database

2. **Click "Realtime Database" → "Rules" tab**

3. **Replace the current rules** with the rules above

4. **Click "Publish"**

5. **Verify:** Rules should match the structure in `firebase-database-rules.json`

## ✅ After Updating

Your database will be properly secured for the BSLND app:
- User data protected
- Content accessible to authenticated users
- Payments and subscriptions secured
- Forms and donations user-controlled

## 📝 Note

The rules file `firebase-database-rules.json` in your project already contains these correct rules. Just copy from there or use the rules above.


