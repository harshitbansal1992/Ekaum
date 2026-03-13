/**
 * Authentication Middleware
 * JWT token validation and user extraction
 */

const jwt = require('jsonwebtoken');
const { config } = require('../config');
const { HTTP_STATUS, ERROR_MESSAGES } = require('../constants');

/**
 * Middleware to authenticate JWT tokens
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        error: ERROR_MESSAGES.UNAUTHORIZED,
      });
    }

    jwt.verify(token, config.jwt.secret, (err, user) => {
      if (err) {
        return res.status(HTTP_STATUS.FORBIDDEN).json({
          error: ERROR_MESSAGES.INVALID_TOKEN,
        });
      }
      req.user = user;
      next();
    });
  } catch (error) {
    res.status(HTTP_STATUS.UNAUTHORIZED).json({
      error: ERROR_MESSAGES.UNAUTHORIZED,
    });
  }
};

module.exports = { authenticateToken };

