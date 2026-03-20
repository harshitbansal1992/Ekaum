# Environment Configuration Templates

This file contains template configurations for setting up your environment files.

## Development Setup (.env.development)

Copy and paste into `.env.development`:

```env
# BSLND Backend - Development Configuration
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# Local PostgreSQL Development Database
DATABASE_URL=postgres://postgres:password@localhost:5432/bslnd_dev

# Database Pool (Small for development)
DB_POOL_MIN=2
DB_POOL_MAX=10

# JWT Configuration (Simple key for development)
JWT_SECRET=dev-secret-key-not-for-production
JWT_EXPIRES_IN=7d

# CORS (Allow all for development)
CORS_ORIGIN=*

# Request Logging
REQUEST_LOGGING=true

# Instamojo (Optional - dev keys)
INSTAMOJO_API_KEY=dev-api-key
INSTAMOJO_AUTH_TOKEN=dev-auth-token

# Feature Flags (Development defaults)
CACHING_ENABLED=false
RATE_LIMIT_ENABLED=false
MOCK_PAYMENTS=false
ERROR_TRACKING=false
```

---

## Test Setup (.env.test)

Copy and paste into `.env.test`:

```env
# BSLND Backend - Test Configuration
NODE_ENV=test
PORT=3001
LOG_LEVEL=warn

# Separate Test Database (Prevent data pollution)
DATABASE_URL=postgres://postgres:password@localhost:5432/bslnd_test

# Database Pool (Minimal for testing)
DB_POOL_MIN=1
DB_POOL_MAX=5

# JWT Configuration (Short expiry for tests)
JWT_SECRET=test-secret-key-for-testing-only
JWT_EXPIRES_IN=1h

# CORS (Allow all for testing)
CORS_ORIGIN=*

# Request Logging (Disabled for clean test output)
REQUEST_LOGGING=false

# Instamojo (Mock keys for testing)
INSTAMOJO_API_KEY=test-mock-key
INSTAMOJO_AUTH_TOKEN=test-mock-token

# Feature Flags (Test-specific)
CACHING_ENABLED=false
RATE_LIMIT_ENABLED=false
MOCK_PAYMENTS=true
ERROR_TRACKING=false
```

---

## Production Setup (.env.production)

Copy and paste into `.env.production` and **fill in your actual values**:

```env
# BSLND Backend - Production Configuration
NODE_ENV=production
PORT=8080
LOG_LEVEL=info

# ⚠️  PRODUCTION DATABASE - Use managed service (Supabase, Neon, Railway, etc.)
# Example Supabase: postgresql://postgres:password@aws-0-region.pooler.supabase.com:6543/postgres
# Example Neon: postgresql://user:password@ep-host.neon.tech/neondb
DATABASE_URL=postgresql://prod_user:STRONG_PASSWORD@prod-db-host.com:5432/bslnd_prod

# Database Pool (Large for production traffic)
DB_POOL_MIN=10
DB_POOL_MAX=30

# ⚠️  CRITICAL: Generate strong JWT secret
# Command: openssl rand -base64 32
JWT_SECRET=REPLACE_WITH_STRONG_PRODUCTION_SECRET_HERE
JWT_EXPIRES_IN=24h

# ⚠️  CRITICAL: Restrict to your domain(s)
# Single domain: https://yourdomain.com
# Multiple domains: https://yourdomain.com,https://app.yourdomain.com
CORS_ORIGIN=https://yourdomain.com

# Request Logging (Minimal for production)
REQUEST_LOGGING=false

# ⚠️  CRITICAL: Use production API keys
INSTAMOJO_API_KEY=PRODUCTION_API_KEY_HERE
INSTAMOJO_AUTH_TOKEN=PRODUCTION_AUTH_TOKEN_HERE

# Feature Flags (Production-optimized)
CACHING_ENABLED=true
RATE_LIMIT_ENABLED=true
MOCK_PAYMENTS=false
ERROR_TRACKING=true
```

---

## Docker Environment (.env.docker)

If using Docker, copy and paste into `.env.docker`:

```env
# BSLND Backend - Docker Configuration
NODE_ENV=production
PORT=3000

# Docker Network Database Connection
DATABASE_URL=postgres://postgres:password@postgres-service:5432/bslnd

# Database Pool (Medium for containers)
DB_POOL_MIN=5
DB_POOL_MAX=20

# JWT Configuration
JWT_SECRET=REPLACE_WITH_DOCKER_SECRET
JWT_EXPIRES_IN=24h

# CORS (Your domain)
CORS_ORIGIN=https://yourdomain.com

# Instamojo
INSTAMOJO_API_KEY=YOUR_KEY
INSTAMOJO_AUTH_TOKEN=YOUR_TOKEN

# Feature Flags
CACHING_ENABLED=true
RATE_LIMIT_ENABLED=true
MOCK_PAYMENTS=false
ERROR_TRACKING=true
```

---

## Supabase Setup

If using Supabase as your database:

1. Go to Supabase dashboard: https://supabase.com
2. Select your project
3. Click "Settings" → "Database" 
4. Copy the connection string (URI format)
5. Paste into your `.env.{MODE}`:

```env
DATABASE_URL=postgresql://postgres:[YOUR_PASSWORD]@aws-0-region.pooler.supabase.com:6543/postgres
```

---

## Neon Database Setup

If using Neon as your database:

1. Go to Neon console: https://console.neon.tech
2. Select your project and branch
3. Click "Connection String"
4. Copy the connection URI
5. Paste into your `.env.{MODE}`:

```env
DATABASE_URL=postgresql://[user]:[password]@[ep-xxxx].neon.tech/[dbname]
```

---

## Railway Database Setup

If using Railway:

1. Go to Railway dashboard
2. Select your PostgreSQL service
3. Click "Connect"
4. Copy the "Database URL"
5. Paste into your `.env.{MODE}`:

```env
DATABASE_URL=postgresql://postgres:[password]@[host]:[port]/[database]
```

---

## Generating Secrets

### JWT Secret (Linux/macOS)
```bash
openssl rand -base64 32
```

### JWT Secret (Windows PowerShell)
```powershell
[Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

### JWT Secret (Node.js)
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

---

## Environment Variable Reference

| Variable | Development | Test | Production | Required |
|----------|-----------|------|-----------|----------|
| NODE_ENV | development | test | production | ✅ Yes |
| PORT | 3000 | 3001 | 8080 | ❌ No |
| LOG_LEVEL | debug | warn | info | ❌ No |
| DATABASE_URL | local | test db | prod db | ✅ Yes |
| JWT_SECRET | simple | simple | strong | ✅ Yes |
| JWT_EXPIRES_IN | 7d | 1h | 24h | ❌ No |
| CORS_ORIGIN | * | * | domain | ✅ (prod) |
| INSTAMOJO_API_KEY | optional | optional | required | ✅ (prod) |
| INSTAMOJO_AUTH_TOKEN | optional | optional | required | ✅ (prod) |

---

## File Locations

After setup, your structure should look like:

```
backend/
├── .env                    # Fallback/default (git-ignored)
├── .env.development        # Development (git-ignored)
├── .env.test              # Test (git-ignored)
├── .env.production        # Production ⚠️ KEEP SECURE (git-ignored)
├── .env.example           # Template for documentation
├── server.js
├── package.json
└── src/
    ├── config.js
    └── ...
```

---

## Security Notes

### Development
- ✅ Simple secrets are fine
- ✅ Any database is OK
- ✅ Open CORS is acceptable

### Test  
- ✅ Mock/test secrets acceptable
- ✅ Use separate database
- ⚠️ Don't use production data

### Production
- ⚠️ **CRITICAL:** Use strong, unique JWT_SECRET
- ⚠️ **CRITICAL:** Restrict CORS_ORIGIN
- ⚠️ **CRITICAL:** Use production-grade database
- ⚠️ **CRITICAL:** Never commit `.env.production`
- ⚠️ **CRITICAL:** Store secrets securely (use secrets manager)
- ⚠️ **CRITICAL:** Enable error tracking and monitoring

---

## Quick Copy-Paste Setup

### For Development

```bash
# Create development .env file
cat > .env.development << 'EOF'
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
DATABASE_URL=postgres://postgres:password@localhost:5432/bslnd_dev
JWT_SECRET=dev-secret-key
CORS_ORIGIN=*
EOF

# Verify
npm run mode:info
```

### For Testing

```bash
# Create test .env file
cat > .env.test << 'EOF'
NODE_ENV=test
PORT=3001
LOG_LEVEL=warn
DATABASE_URL=postgres://postgres:password@localhost:5432/bslnd_test
JWT_SECRET=test-secret-key
CORS_ORIGIN=*
EOF
```

### For Production

```bash
# Create production .env file (UPDATE WITH YOUR VALUES!)
cat > .env.production << 'EOF'
NODE_ENV=production
PORT=8080
LOG_LEVEL=info
DATABASE_URL=postgresql://YOUR_USER:YOUR_PASSWORD@your-db-host:5432/your_db
JWT_SECRET=YOUR_STRONG_SECRET_HERE
CORS_ORIGIN=https://yourdomain.com
INSTAMOJO_API_KEY=YOUR_API_KEY
INSTAMOJO_AUTH_TOKEN=YOUR_AUTH_TOKEN
EOF

# ⚠️ EDIT FILE AND UPDATE ALL REPLACE_ME VALUES!
nano .env.production
```

---

## Verification Commands

```bash
# View current mode configuration
npm run mode:info

# Test database connection (within Node app)
npm run dev
curl http://localhost:3000/api/config

# List all environment files
ls -la .env*

# Check if variables are loaded (development mode)
NODE_ENV=development node -e "require('dotenv').config(); console.log(process.env.DATABASE_URL)"
```

---

## Next Steps

1. Copy the appropriate template for your mode
2. Update with your actual values
3. For production: use a secrets manager (AWS Secrets, HashiCorp Vault, etc.)
4. Never commit `.env` files to git
5. Always use `.env.example` for documentation

---

## Help & Support

- Check current config: `npm run mode:info`
- View full guide: `MULTI_MODE_SETUP.md`
- Quick reference: `MODE_QUICK_REFERENCE.md`

