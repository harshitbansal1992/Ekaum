# BSLND Backend - Multi-Mode Setup Guide

## Overview

The BSLND Backend now supports **three deployment modes** with different configurations:

- **Development** 🚀 - For local development and debugging
- **Test** 🧪 - For running tests with isolated database
- **Production** ⚡ - For live deployment

Each mode has its own environment configuration, feature flags, and defaults.

---

## Quick Start

### Using npm scripts

```bash
# Development mode (with auto-reload via nodemon)
npm run dev

# Test mode
npm run test

# Test mode with auto-reload
npm run test:watch

# Production mode
npm start
```

### Using startup scripts (Recommended)

**macOS/Linux:**
```bash
# Make script executable (first time only)
chmod +x start.sh

# Run in development mode
./start.sh development

# Run in test mode
./start.sh test

# Run in production mode
./start.sh production
```

**Windows:**
```batch
# Run in development mode
start.bat development

# Run in test mode
start.bat test

# Run in production mode
start.bat production
```

### Using environment variables directly

```bash
# Development
NODE_ENV=development npm run dev

# Test
NODE_ENV=test npm run test

# Production
NODE_ENV=production npm start
```

---

## Mode Configurations

### 1. Development Mode (🚀)

**Purpose:** Local development with maximum debugging capabilities

**Default Settings:**
- Port: `3000`
- Log Level: `debug` (verbose logging)
- Database Pool: 2-10 connections
- CORS: Allow all origins (`*`)
- Features:
  - Request logging enabled
  - Caching disabled
  - Rate limiting disabled
  - Mock payments disabled
  - Error tracking disabled
- JWT Expiry: `7 days`

**Environment File:** `.env.development`

**Use Cases:**
- Local debugging
- Feature development
- API testing with Postman/Insomnia
- Database exploration

---

### 2. Test Mode (🧪)

**Purpose:** Running tests with isolated configuration

**Default Settings:**
- Port: `3001`
- Log Level: `warn` (minimal logging for clean output)
- Database Pool: 1-5 connections (minimal)
- CORS: Allow all origins (`*`)
- Features:
  - Request logging disabled
  - Caching disabled
  - Rate limiting disabled
  - **Mock payments enabled** ⚠️
  - Error tracking disabled
- JWT Expiry: `1 hour`

**Environment File:** `.env.test`

**Special Configuration:**
- Separate test database to avoid affecting production/dev data
- Mock payment gateway enabled to prevent real charges
- Shorter JWT expiry for test scenarios
- Minimal database pool for isolated testing

**Use Cases:**
- Running automated tests
- Integration testing
- Payment gateway testing (with mocks)
- Pre-deployment validation

---

### 3. Production Mode (⚡)

**Purpose:** Live deployment with security and performance optimizations

**Default Settings:**
- Port: `8080`
- Log Level: `info` (important messages only)
- Database Pool: 10-30 connections (high concurrency)
- CORS: Restricted to specific origins
- Features:
  - Request logging disabled
  - Caching enabled
  - Rate limiting enabled
  - Mock payments disabled
  - Error tracking enabled
- JWT Expiry: `24 hours`

**Environment File:** `.env.production`

**Security Requirements:**
- ⚠️ JWT_SECRET must be changed from default
- ⚠️ CORS_ORIGIN must be explicitly set (not `*`)
- ⚠️ DATABASE_URL must use production database
- ⚠️ Use strong, unique credentials for Instamojo

**Use Cases:**
- Live API serving
- Production deployments
- High-traffic scenarios
- Monitoring and error tracking

---

## Environment Variables

### Common Variables (All Modes)

```env
# Server Configuration
PORT=3000                    # Server port
NODE_ENV=development        # Mode: development, test, production
LOG_LEVEL=debug             # Logging level: debug, info, warn, error

# Database Configuration
DATABASE_URL=postgres://... # PostgreSQL connection string
DB_POOL_MIN=2              # Minimum pool connections
DB_POOL_MAX=10             # Maximum pool connections

# JWT Configuration
JWT_SECRET=your-secret     # JWT signing secret
JWT_EXPIRES_IN=7d          # Token expiry time

# CORS Configuration
CORS_ORIGIN=*              # Allowed origins (restrict in production)

# Payment Gateway
INSTAMOJO_API_KEY=...      # Instamojo API key
INSTAMOJO_AUTH_TOKEN=...   # Instamojo auth token

# Request Logging
REQUEST_LOGGING=true       # Enable/disable request logging
```

### Mode-Specific Defaults

| Variable | Development | Test | Production |
|----------|-------------|------|------------|
| PORT | 3000 | 3001 | 8080 |
| LOG_LEVEL | debug | warn | info |
| DB_POOL_MIN | 2 | 1 | 10 |
| DB_POOL_MAX | 10 | 5 | 30 |
| CORS_ORIGIN | * | * | (required) |
| JWT_EXPIRES_IN | 7d | 1h | 24h |
| CACHING | disabled | disabled | enabled |
| RATE_LIMIT | disabled | disabled | enabled |
| MOCK_PAYMENTS | no | yes | no |
| ERROR_TRACKING | disabled | disabled | enabled |

---

## Configuration Priority

Environment variables are loaded in this order (first found wins):

1. `.env.{MODE}` file (e.g., `.env.development`, `.env.test`)
2. `.env` file (fallback)
3. Built-in mode defaults
4. Command-line overrides

**Example:**
```bash
# This will use port 5000 even if .env.development says 3000
PORT=5000 npm run dev
```

---

## Checking Mode Configuration

View current mode configuration:

```bash
npm run mode:info
```

Output example:
```json
{
  "mode": "development",
  "isDevelopment": true,
  "isTest": false,
  "isProduction": false,
  "port": 3000,
  "logLevel": "debug",
  "features": {
    "caching": false,
    "rateLimit": false,
    "errorTracking": false,
    "mockPayments": false
  }
}
```

---

## Development Workflow

### 1. Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd backend

# Install dependencies
npm install

# Copy and configure environment
cp .env.development .env

# Update database connection in .env
# DATABASE_URL=postgres://username:password@localhost:5432/bslnd_dev
```

### 2. Running Development Server

```bash
# Auto-reloads on file changes
npm run dev

# Or using startup script
./start.sh development
```

### 3. Testing Changes

```bash
# In another terminal, test the API
curl http://localhost:3000/health
curl http://localhost:3000/api/config
```

### 4. Running Tests

```bash
# Run tests once
npm run test

# Or run tests with auto-reload
npm run test:watch

# Using startup script
./start.sh test
```

---

## Production Deployment Checklist

Before deploying to production:

- [ ] Update `.env.production` with production database URL
- [ ] Set strong, unique `JWT_SECRET`
- [ ] Set `CORS_ORIGIN` to your domain(s)
- [ ] Update Instamojo production API keys
- [ ] Verify `NODE_ENV=production`
- [ ] Run tests in production mode
- [ ] Check database connection
- [ ] Enable monitoring/error tracking
- [ ] Set up log aggregation
- [ ] Configure SSL/TLS certificates
- [ ] Test graceful shutdown handling

### Production Startup

```bash
# Using npm
NODE_ENV=production npm start

# Using startup script
./start.sh production

# Using Docker (if containerized)
docker run -e NODE_ENV=production myapp:latest
```

---

## Troubleshooting

### "Missing required environment variables"

**Solution:** Create `.env.{MODE}` file with required variables:
```bash
cp .env.development .env
# Edit .env and fill in DATABASE_URL and JWT_SECRET
```

### Database connection errors in production

**Check:**
1. `DATABASE_URL` is set correctly
2. Database server is running and accessible
3. Firewall allows connection to database
4. Database user has proper permissions

### Port already in use

**Solution:** Change port in environment file:
```env
# .env.development
PORT=3001
```

Or use command-line override:
```bash
PORT=3001 npm run dev
```

### Feature not working as expected

**Check active features:**
```bash
npm run mode:info
```

**Enable specific feature:**
```bash
# Override in .env
CACHING_ENABLED=true
RATE_LIMIT_ENABLED=true
```

### Memory/Connection pool issues

**Adjust in `.env`:**
```env
DB_POOL_MIN=5
DB_POOL_MAX=15
```

---

## API Endpoints

### Health Check

```bash
# Check server status
GET http://localhost:3000/health
```

### Configuration (Dev/Test only)

```bash
# View current configuration
GET http://localhost:3000/api/config
```

Response:
```json
{
  "mode": "development",
  "port": 3000,
  "logLevel": "debug",
  "features": {
    "caching": false,
    "rateLimit": false,
    "errorTracking": false,
    "mockPayments": false
  },
  "api": {
    "version": "1.0.0",
    "prefix": "/api"
  }
}
```

---

## Best Practices

### Development
- ✅ Use `npm run dev` for auto-reload
- ✅ Enable all request logging
- ✅ Use local database
- ✅ Ignore CORS restrictions for testing

### Testing
- ✅ Use separate test database
- ✅ Enable mock payments
- ✅ Minimize logging for clean output
- ✅ Use shorter JWT expiry

### Production
- ✅ Set strong JWT_SECRET
- ✅ Restrict CORS origins
- ✅ Enable caching and rate limiting
- ✅ Enable error tracking
- ✅ Monitor logs and errors
- ✅ Use production database
- ✅ Regular backups

---

## Additional Resources

- **Configuration:** `src/config.js`
- **Logger:** `src/logger.js`
- **Database:** `src/database.js`
- **Routes:** `src/routes/`
- **Middleware:** `src/middleware/`

---

## Support

For issues or questions:
1. Check `.env.{MODE}` configuration
2. Run `npm run mode:info` to verify settings
3. Check logs for error messages
4. Review this guide's troubleshooting section

