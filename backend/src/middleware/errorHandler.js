/**
 * Error Handling Middleware
 * Centralized error handling for the application
 */

const logger = require('../logger');
const { HTTP_STATUS } = require('../constants');

/**
 * Middleware to handle errors
 * @param {Error} error - Error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const errorHandler = (error, req, res, next) => {
  logger.error('Unhandled error:', error);

  // Default to 500 Internal Server Error
  let statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR;
  let message = 'Internal server error';

  // Handle specific error types
  if (error.statusCode) {
    statusCode = error.statusCode;
    message = error.message;
  } else if (error.name === 'ValidationError') {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    message = error.message;
  } else if (error.name === 'UnauthorizedError') {
    statusCode = HTTP_STATUS.UNAUTHORIZED;
    message = error.message;
  }

  res.status(statusCode).json({
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack }),
  });
};

/**
 * Middleware to handle 404 Not Found
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const notFoundHandler = (req, res) => {
  res.status(HTTP_STATUS.NOT_FOUND).json({
    error: `Route ${req.method} ${req.path} not found`,
  });
};

module.exports = {
  errorHandler,
  notFoundHandler,
};

