/**
 * BSLND Backend API Server
 * Main application entry point following best practices
 *
 * This refactored server implements:
 * - Modular route structure
 * - Centralized configuration
 * - Error handling middleware
 * - Environment validation
 * - Multi-mode support (development, test, production)
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const { config, validateConfig, getModeConfig } = require('./src/config');
const { pool } = require('./src/database');
const logger = require('./src/logger');
const { errorHandler, notFoundHandler } = require('./src/middleware/errorHandler');

// Routes
const healthRoutes = require('./src/routes/health');
const authRoutes = require('./src/routes/auth');

// Initialize Express app
const app = express();

// ============ STARTUP VALIDATION ============

// Display mode information at startup
const modeConfig = getModeConfig();
logger.info(`🔄 Starting BSLND Backend in ${modeConfig.mode.toUpperCase()} mode...`);

// Validate configuration before starting
try {
  validateConfig();
  logger.success('Configuration validated successfully');
} catch (error) {
  logger.error('Configuration validation failed:', error.message);
  process.exit(1);
}

// ============ MIDDLEWARE ============

// CORS
app.use(cors(config.cors));

// Body parsing
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging middleware (mode-aware)
if (config.debug.requestLogging) {
  app.use((req, res, next) => {
    logger.debug(`${req.method} ${req.path}`);
    next();
  });
}

// ============ ROUTES ============

// Health check
app.use('/health', healthRoutes);

// Authentication routes
app.use('/api/auth', authRoutes);

// Mode-specific endpoint for configuration info (development/test only)
if (config.isDevelopment || config.isTest) {
  app.get('/api/config', (req, res) => {
    res.json({
      mode: config.mode,
      port: config.port,
      logLevel: config.logLevel,
      features: config.features,
      api: config.api,
    });
  });
}

// ...existing routes...

// 404 handler (must be before error handler)
app.use(notFoundHandler);

// Error handler (must be last middleware)
app.use(errorHandler);

// ============ SERVER STARTUP ============

const PORT = config.port;

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  logger.warn('SIGTERM signal received: closing HTTP server');
  await pool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.warn('SIGINT signal received: closing HTTP server');
  await pool.end();
  process.exit(0);
});

// Start server
app.listen(PORT, () => {
  const mode = config.mode.toUpperCase();
  const modeEmoji = {
    DEVELOPMENT: '🚀',
    TEST: '🧪',
    PRODUCTION: '⚡',
  };

  logger.success(`${modeEmoji[mode]} BSLND Backend API [${mode}] running on port ${PORT}`);
  logger.info(`📊 Log Level: ${config.logLevel}`);
  logger.info(`🗄️  Database Pool: ${config.database.poolMin}-${config.database.poolMax} connections`);
  logger.info(`🔐 JWT Expiry: ${config.jwt.expiresIn}`);

  // Feature flags
  if (config.features.caching) logger.info('✅ Caching enabled');
  if (config.features.rateLimit) logger.info('✅ Rate limiting enabled');
  if (config.features.mockPayments) logger.info('⚠️  Mock payments enabled');
  if (config.features.errorTracking) logger.info('✅ Error tracking enabled');

  logger.info(
    `🔐 JWT Secret: ${
      config.jwt.secret === 'your-super-secret-jwt-key-change-this-in-production'
        ? '⚠️  Using default (change in production!)'
        : '✅ Set'
    }`
  );
});

module.exports = app;

