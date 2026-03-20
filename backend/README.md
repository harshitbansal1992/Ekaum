# BSLND Backend API

Node.js Express backend for BSLND Flutter mobile app.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```
PORT=3000
FIREBASE_DATABASE_URL=https://ekaum-e5b36-default-rtdb.asia-southeast1.firebasedatabase.app
INSTAMOJO_API_KEY=your-instamojo-api-key
INSTAMOJO_AUTH_TOKEN=your-instamojo-auth-token
```

3. Add Firebase service account key:
   - Download `serviceAccountKey.json` from Firebase Console
   - Place it in the `backend/` directory

4. Run the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## API Endpoints

### Health Check
- `GET /health` - Check API status

### User
- `GET /api/users/:userId` - Get user details

### Subscriptions
- `POST /api/subscriptions` - Create subscription
- `GET /api/subscriptions/:userId` - Get user subscription

### Payments
- `POST /api/payments/webhook` - Instamojo webhook

### Paath Services
- `GET /api/paath-forms/:userId` - Get user's paath service forms

### Donations
- `GET /api/donations/:userId` - Get user's donations

### Admin (Content Management)
- `POST /api/admin/avdhan` - Add Avdhan audio
- `POST /api/admin/samagam` - Add Samagam event
- `POST /api/admin/patrika` - Add Patrika issue


