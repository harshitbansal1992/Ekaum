/**
 * Database Connection Pool
 * Manages PostgreSQL connections
 */

const { Pool } = require('pg');
const { config } = require('./config');
const logger = require('./logger');

const pool = new Pool({
  connectionString: config.database.url,
  ssl: config.database.ssl,
});

/**
 * Event handlers for pool
 */
pool.on('connect', () => {
  logger.info('Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  logger.error('PostgreSQL connection error:', err);
});

/**
 * Health check for database connection
 * @async
 * @returns {Promise<boolean>} True if database is accessible
 */
const checkConnection = async () => {
  try {
    const result = await pool.query('SELECT 1');
    return !!result;
  } catch (error) {
    logger.error('Database health check failed:', error);
    return false;
  }
};

/**
 * Close database connection pool
 * @async
 */
const closePool = async () => {
  try {
    await pool.end();
    logger.info('Database connection pool closed');
  } catch (error) {
    logger.error('Error closing database pool:', error);
  }
};

module.exports = {
  pool,
  checkConnection,
  closePool,
};

