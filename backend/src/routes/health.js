/**
 * Health Check Route
 * Basic health check endpoint
 */

const express = require('express');
const { checkConnection } = require('../database');
const { HTTP_STATUS } = require('../constants');

const router = express.Router();

/**
 * GET /health
 * Health check endpoint
 * @returns {Object} Health status information
 */
router.get('/health', async (req, res) => {
  try {
    const dbHealthy = await checkConnection();

    res.status(HTTP_STATUS.OK).json({
      status: 'ok',
      message: 'BSLND Backend API is running',
      database: dbHealthy ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      status: 'error',
      message: 'Health check failed',
      error: error.message,
    });
  }
});

module.exports = router;

