/**
 * Configuration Management
 * Centralized configuration for the application with support for
 * development, test, and production modes
 */

const path = require('path');

// Load environment variables based on NODE_ENV
const nodeEnv = process.env.NODE_ENV || 'development';
const envFile = path.resolve(__dirname, `../.env.${nodeEnv}`);

require('dotenv').config({ path: envFile });
// Also load .env as fallback
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

// Mode-specific configuration profiles
const modeProfiles = {
  development: {
    port: 3000,
    logLevel: 'debug',
    corsOrigin: '*',
    sslEnabled: false,
    requestLogging: true,
    cachingEnabled: false,
    rateLimitEnabled: false,
    jwtExpiresIn: '7d',
    dbPoolMin: 2,
    dbPoolMax: 10,
    mockPayments: false,
    errorTracking: false,
  },
  test: {
    port: 3001,
    logLevel: 'warn',
    corsOrigin: '*',
    sslEnabled: false,
    requestLogging: false,
    cachingEnabled: false,
    rateLimitEnabled: false,
    jwtExpiresIn: '1h',
    dbPoolMin: 1,
    dbPoolMax: 5,
    mockPayments: true,
    errorTracking: false,
  },
  production: {
    port: 8080,
    logLevel: 'info',
    corsOrigin: process.env.CORS_ORIGIN,
    sslEnabled: true,
    requestLogging: false,
    cachingEnabled: true,
    rateLimitEnabled: true,
    jwtExpiresIn: '24h',
    dbPoolMin: 10,
    dbPoolMax: 30,
    mockPayments: false,
    errorTracking: true,
  },
};

const currentProfile = modeProfiles[nodeEnv] || modeProfiles.development;

const config = {
  // Environment & Mode
  nodeEnv,
  mode: nodeEnv,
  isDevelopment: nodeEnv === 'development',
  isTest: nodeEnv === 'test',
  isProduction: nodeEnv === 'production',

  // Server
  port: parseInt(process.env.PORT, 10) || currentProfile.port,
  logLevel: process.env.LOG_LEVEL || currentProfile.logLevel,
  requestLogging: process.env.REQUEST_LOGGING !== 'false' && currentProfile.requestLogging,

  // Database
  database: {
    url: process.env.DATABASE_URL,
    ssl: currentProfile.sslEnabled ? { rejectUnauthorized: false } : false,
    poolMin: parseInt(process.env.DB_POOL_MIN, 10) || currentProfile.dbPoolMin,
    poolMax: parseInt(process.env.DB_POOL_MAX, 10) || currentProfile.dbPoolMax,
  },

  // JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || currentProfile.jwtExpiresIn,
  },

  // Razorpay Payment Gateway
  razorpay: {
    keyId: process.env.RAZORPAY_KEY_ID,
    keySecret: process.env.RAZORPAY_KEY_SECRET,
    webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET,
  },

  // Instamojo (legacy, deprecated in favor of Razorpay)
  instamojo: {
    apiKey: process.env.INSTAMOJO_API_KEY,
    authToken: process.env.INSTAMOJO_AUTH_TOKEN,
  },

  // CORS
  cors: {
    origin: process.env.CORS_ORIGIN || currentProfile.corsOrigin,
    credentials: true,
  },

  // Feature flags
  features: {
    caching: currentProfile.cachingEnabled,
    rateLimit: currentProfile.rateLimitEnabled,
    errorTracking: currentProfile.errorTracking,
    mockPayments: currentProfile.mockPayments,
  },

  // API
  api: {
    version: '1.0.0',
    prefix: '/api',
  },

  // Debugging
  debug: {
    requestLogging: currentProfile.requestLogging,
    sqlLogging: nodeEnv === 'development',
  },
};

/**
 * Validate required environment variables
 */
const validateConfig = () => {
  const requiredVars = ['DATABASE_URL', 'JWT_SECRET'];
  const missing = requiredVars.filter(
    (variable) => !process.env[variable] && variable !== 'JWT_SECRET'
  );

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}`
    );
  }

  if (config.isProduction) {
    if (config.jwt.secret === 'your-super-secret-jwt-key-change-this-in-production') {
      throw new Error('JWT_SECRET must be set in production');
    }
    if (!config.cors.origin || config.cors.origin === '*') {
      throw new Error('CORS_ORIGIN must be explicitly set in production');
    }
  }

  if (!config.database.url) {
    throw new Error('DATABASE_URL is required');
  }
};

/**
 * Get mode-specific configuration
 */
const getModeConfig = () => ({
  mode: config.mode,
  isDevelopment: config.isDevelopment,
  isTest: config.isTest,
  isProduction: config.isProduction,
  port: config.port,
  logLevel: config.logLevel,
  features: config.features,
});

module.exports = {
  config,
  validateConfig,
  getModeConfig,
  modeProfiles,
};

