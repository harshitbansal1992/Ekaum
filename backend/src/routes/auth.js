/**
 * Authentication Routes
 * User registration, login, and profile endpoints
 */

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../database');
const { config } = require('../config');
const { authenticateToken } = require('../middleware/auth');
const { HTTP_STATUS, ERROR_MESSAGES, DB_TABLES, JWT_CONFIG } = require('../constants');
const {
  isValidEmail,
  isValidPassword,
  isValidPhone,
  sanitizeInput,
} = require('../utils/validation');

const router = express.Router();

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register', async (req, res, next) => {
  try {
    let { email, password, name, phone } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: ERROR_MESSAGES.EMAIL_PASSWORD_REQUIRED,
      });
    }

    // Validate email format
    if (!isValidEmail(email)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Please provide a valid email address (e.g., user@example.com)',
      });
    }

    // Validate password strength
    if (!isValidPassword(password)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Password must be at least 8 characters with uppercase, lowercase, and number',
      });
    }

    // Validate phone if provided
    if (phone && !isValidPhone(phone)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Invalid phone format. Please provide a valid phone number.',
      });
    }

    // Sanitize inputs to prevent XSS
    email = sanitizeInput(email);
    name = sanitizeInput(name);
    phone = sanitizeInput(phone);

    // Check if user exists
    const existingUser = await pool.query(
      `SELECT id FROM ${DB_TABLES.USERS} WHERE email = $1`,
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(HTTP_STATUS.CONFLICT).json({
        error: ERROR_MESSAGES.USER_EXISTS,
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const result = await pool.query(
      `INSERT INTO ${DB_TABLES.USERS} (email, password_hash, name, phone)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, name, phone, created_at`,
      [email, passwordHash, name || null, phone || null]
    );

    const user = result.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      config.jwt.secret,
      { expiresIn: JWT_CONFIG.EXPIRES_IN }
    );

    res.status(HTTP_STATUS.CREATED).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
      },
      token,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/auth/login
 * Login user
 */
router.post('/login', async (req, res, next) => {
  try {
    let { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: ERROR_MESSAGES.EMAIL_PASSWORD_REQUIRED,
      });
    }

    // Validate email format
    if (!isValidEmail(email)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Please provide a valid email address',
      });
    }

    // Sanitize email input
    email = sanitizeInput(email);

    // Find user
    const result = await pool.query(
      `SELECT id, email, password_hash, name, phone FROM ${DB_TABLES.USERS}
       WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        error: ERROR_MESSAGES.INVALID_CREDENTIALS,
      });
    }

    const user = result.rows[0];

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        error: ERROR_MESSAGES.INVALID_CREDENTIALS,
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      config.jwt.secret,
      { expiresIn: JWT_CONFIG.EXPIRES_IN }
    );

    res.status(HTTP_STATUS.OK).json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
      },
      token,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/auth/me
 * Get current authenticated user
 */
router.get('/me', authenticateToken, async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT id, email, name, phone, created_at FROM ${DB_TABLES.USERS}
       WHERE id = $1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: ERROR_MESSAGES.USER_NOT_FOUND,
      });
    }

    res.status(HTTP_STATUS.OK).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

module.exports = router;

