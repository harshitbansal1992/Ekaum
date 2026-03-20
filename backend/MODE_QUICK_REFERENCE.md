# BSLND Backend - Quick Reference

## Running the Backend

### Fastest Way (Recommended)

**macOS/Linux:**
```bash
chmod +x start.sh
./start.sh development    # or: test, production
```

**Windows:**
```batch
start.bat development     # or: test, production
```

### Using npm

```bash
npm run dev          # Development mode 🚀
npm run test         # Test mode 🧪
npm run test:watch   # Test mode with auto-reload
npm start            # Production mode ⚡
```

### Using Environment Variable

```bash
NODE_ENV=development npm run dev
NODE_ENV=test npm run test
NODE_ENV=production npm start
```

---

## Configuration Files

- **`.env.development`** - Development configuration
- **`.env.test`** - Test configuration  
- **`.env.production`** - Production configuration
- **`.env`** - Fallback/default configuration

---

## Mode Comparison

| Feature | Development | Test | Production |
|---------|-------------|------|------------|
| Port | 3000 | 3001 | 8080 |
| Logging | Verbose (debug) | Quiet (warn) | Info only |
| Auto-reload | Yes (nodemon) | Yes (nodemon watch) | No |
| CORS | Open (*) | Open (*) | Restricted |
| Caching | Off | Off | On |
| Rate Limiting | Off | Off | On |
| Mock Payments | No | **Yes** | No |
| Database Pool | 2-10 | 1-5 | 10-30 |
| JWT Expiry | 7 days | 1 hour | 24 hours |

---

## View Configuration

```bash
npm run mode:info
```

---

## Common Commands

```bash
# Development workflow
npm install          # Install dependencies
npm run dev          # Start with auto-reload
npm run lint         # Check code style
npm run format       # Auto-fix formatting

# Testing
npm run test         # Run once
npm run test:watch   # Run with auto-reload

# Production
npm start            # Start production server

# Utilities
npm run mode:info    # Show current mode config
npm run lint:fix     # Fix linting issues
```

---

## Environment Variables (Quick Setup)

### Development (.env.development)
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgres://user:pass@localhost:5432/bslnd_dev
JWT_SECRET=dev-secret
CORS_ORIGIN=*
```

### Test (.env.test)
```env
NODE_ENV=test
PORT=3001
DATABASE_URL=postgres://user:pass@localhost:5432/bslnd_test
JWT_SECRET=test-secret
CORS_ORIGIN=*
```

### Production (.env.production)
```env
NODE_ENV=production
PORT=8080
DATABASE_URL=postgres://prod_user:strong_pass@prod.db.com/bslnd
JWT_SECRET=STRONG_PRODUCTION_SECRET
CORS_ORIGIN=https://yourdomain.com
```

---

## Health Check

```bash
# API is running
curl http://localhost:3000/health

# Get config (dev/test only)
curl http://localhost:3000/api/config
```

---

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| "Missing DATABASE_URL" | Create `.env.{MODE}` file with DATABASE_URL |
| Port 3000 in use | Change PORT in `.env` or: `PORT=3001 npm run dev` |
| Auth errors | Check JWT_SECRET in `.env` |
| DB connection error | Verify DATABASE_URL and database is running |
| Old changes still running | Kill nodemon process and restart `npm run dev` |

---

## File Locations

```
backend/
├── .env                      # Fallback config
├── .env.development          # Dev mode config
├── .env.test                 # Test mode config
├── .env.production           # Prod mode config
├── src/
│   ├── config.js             # Configuration system
│   ├── logger.js             # Logging utility
│   ├── database.js           # Database connection
│   ├── routes/               # API endpoints
│   └── middleware/           # Express middleware
├── server.js                 # Entry point
├── start.sh                  # macOS/Linux startup script
├── start.bat                 # Windows startup script
├── package.json              # Dependencies & scripts
└── MULTI_MODE_SETUP.md       # Full documentation
```

---

## Next Steps

1. **Setup development environment:**
   ```bash
   cp .env.development .env
   npm install
   npm run dev
   ```

2. **Configure test mode:**
   Update `.env.test` with test database URL

3. **Prepare production:**
   Update `.env.production` with production secrets

4. **Deploy:**
   ```bash
   NODE_ENV=production npm start
   ```

---

For detailed information, see **MULTI_MODE_SETUP.md**

