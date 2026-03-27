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
const compression = require('compression');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const { config, validateConfig, getModeConfig } = require('./src/config');
const { closePool } = require('./src/database');
const logger = require('./src/logger');
const { errorHandler, notFoundHandler } = require('./src/middleware/errorHandler');

// Routes
const healthRoutes = require('./src/routes/health');
const authRoutes = require('./src/routes/auth');
const settingsRoutes = require('./src/routes/settings');
const avdhanRoutes = require('./src/routes/avdhan');
const paathServicesRoutes = require('./src/routes/paathServices');
const paathFormsRoutes = require('./src/routes/paathForms');
const mantraNotesRoutes = require('./src/routes/mantraNotes');
const donationsRoutes = require('./src/routes/donations');
const adminRoutes = require('./src/routes/admin');
const paymentRoutes = require('./src/routes/payments');
const panchangRoutes = require('./src/routes/panchang');
const searchRoutes = require('./src/routes/search');
const patrikaRoutes = require('./src/routes/patrika');
const videoSatsangRoutes = require('./src/routes/videoSatsang');

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

// Security headers (production-ready)
app.use(helmet({ contentSecurityPolicy: false })); // CSP disabled - adjust if needed for your app

// Response compression (reduces bandwidth for lakh users)
app.use(compression());

// CORS
app.use(cors(config.cors));

// Rate limiting (protects against abuse at scale)
if (config.features.rateLimit) {
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // 100 requests per window per IP
    message: { error: 'Too many requests. Please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
  });
  app.use('/api/', limiter);
  // Stricter limit for auth endpoints
  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10, // 10 login/register attempts per 15 min
    message: { error: 'Too many auth attempts. Try again later.' },
  });
  app.use('/api/auth/login', authLimiter);
  app.use('/api/auth/register', authLimiter);
}

// Razorpay webhook needs raw body for signature verification (must be before json parser)
const { webhookHandler } = require('./src/routes/payments');
app.post('/api/payments/webhook', express.raw({ type: 'application/json' }), webhookHandler);

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

// Settings (key-value store for dynamic content)
app.use('/api/settings', settingsRoutes);

// Avdhan (audio files from avdhan_audio/ folder)
app.use('/api/avdhan', avdhanRoutes);

// Paath services (public catalog for mobile app)
app.use('/api/paath-services', paathServicesRoutes);

// Paath forms (create & list for mobile app)
app.use('/api/paath-forms', paathFormsRoutes);

// Mantra notes (user-stored mantras, note-taker style)
app.use('/api/mantra-notes', mantraNotesRoutes);

// Donations (create before payment for mobile app)
app.use('/api/donations', donationsRoutes);

// Samagam (public list + upcoming for mobile app home)
const samagamRoutes = require('./src/routes/samagam');
app.use('/api/samagam', samagamRoutes);

// Announcements (Vishesh Sandesh - public for mobile app home)
const announcementsRoutes = require('./src/routes/announcements');
app.use('/api/announcements', announcementsRoutes);

// Panchang (Hindu calendar - proxies Kaalchakra free API)
app.use('/api/panchang', panchangRoutes);

// Search (unified search across content)
app.use('/api/search', searchRoutes);

// Patrika (public list + purchases for mobile app)
app.use('/api/patrika', patrikaRoutes);

// Video Satsang (free YouTube video content)
app.use('/api/video-satsang', videoSatsangRoutes);

// Admin / Back office routes (same DB as Ekaum)
app.use('/api/admin', adminRoutes);
app.use('/api/payments', paymentRoutes);

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

// Handle graceful shutdown (production-ready for load balancers)
const gracefulShutdown = async (signal) => {
  logger.warn(`${signal} received: shutting down gracefully`);
  server.close(() => {
    logger.info('HTTP server closed');
  });
  await closePool();
  process.exit(0);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start server (save reference for graceful shutdown)
const server = app.listen(PORT, () => {
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

