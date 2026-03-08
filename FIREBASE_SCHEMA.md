# Firebase Realtime Database Schema

This document describes the Firebase Realtime Database structure for the BSLND app.

## Database Structure

```
bslnd-database/
├── users/
│   └── {userId}/
│       ├── name: string
│       ├── email: string
│       ├── phone: string
│       └── createdAt: string (ISO 8601)
│
├── subscriptions/
│   └── {userId}/
│       ├── isActive: boolean
│       ├── amount: number
│       ├── paymentId: string
│       ├── startDate: string (ISO 8601)
│       ├── expiryDate: string (ISO 8601)
│       └── createdAt: string (ISO 8601)
│
├── avdhan/
│   └── {audioId}/
│       ├── id: string
│       ├── title: string
│       ├── description: string
│       ├── audioUrl: string
│       ├── thumbnailUrl: string (optional)
│       ├── duration: number (seconds)
│       └── createdAt: string (ISO 8601)
│
├── samagam/
│   └── {eventId}/
│       ├── id: string
│       ├── title: string
│       ├── description: string
│       ├── startDate: string (ISO 8601)
│       ├── endDate: string (ISO 8601)
│       ├── location: string
│       ├── address: string (optional)
│       └── imageUrl: string (optional)
│
├── patrika/
│   └── {issueId}/
│       ├── id: string
│       ├── title: string
│       ├── month: string
│       ├── year: number
│       ├── pdfUrl: string
│       ├── coverImageUrl: string (optional)
│       ├── price: number
│       └── publishedDate: string (ISO 8601)
│
├── patrika_purchases/
│   └── {userId}/
│       └── {issueId}/
│           ├── purchaseDate: string (ISO 8601)
│           ├── amount: number
│           └── paymentId: string
│
├── paath_forms/
│   └── {formId}/
│       ├── serviceId: string
│       ├── serviceName: string
│       ├── userId: string
│       ├── totalAmount: number
│       ├── installments: number
│       ├── installmentAmount: number
│       ├── name: string
│       ├── dateOfBirth: string (ISO 8601)
│       ├── timeOfBirth: string
│       ├── placeOfBirth: string
│       ├── fathersOrHusbandsName: string
│       ├── gotra: string
│       ├── caste: string
│       ├── familyMembers: array (optional, for family services)
│       ├── status: string (pending, approved, completed)
│       ├── paymentStatus: string (pending, partial, completed)
│       └── createdAt: string (ISO 8601)
│
├── paath_payments/
│   └── {formId}/
│       └── {installmentNumber}/
│           ├── amount: number
│           ├── paymentId: string
│           ├── paymentDate: string (ISO 8601)
│           └── status: string (pending, completed, failed)
│
├── donations/
│   └── {donationId}/
│       ├── userId: string
│       ├── amount: number
│       ├── name: string
│       ├── email: string
│       ├── phone: string
│       ├── message: string (optional)
│       ├── status: string (pending, completed, failed)
│       ├── paymentId: string (optional)
│       └── createdAt: string (ISO 8601)
│
└── payments/
    └── {paymentId}/
        ├── userId: string
        ├── type: string (subscription, patrika, paath, donation)
        ├── amount: number
        ├── status: string (pending, completed, failed)
        ├── instamojoPaymentId: string
        ├── metadata: object
        └── createdAt: string (ISO 8601)
```

## Security Rules

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
    "donations": {
      "$donationId": {
        ".read": "data.child('userId').val() === auth.uid",
        ".write": "data.child('userId').val() === auth.uid || !data.exists()"
      }
    }
  }
}
```

## Indexes

For better query performance, create indexes on:
- `samagam/startDate`
- `patrika/publishedDate`
- `avdhan/createdAt`
- `paath_forms/userId`
- `donations/userId`

