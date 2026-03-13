/**
 * User Model and Utilities
 * Centralized user-related database operations
 */

const { pool } = require('../database');
const { DB_TABLES, HTTP_STATUS } = require('../constants');

/**
 * Find user by email
 * @async
 * @param {string} email - User email
 * @returns {Promise<Object|null>} User object or null
 */
const findByEmail = async (email) => {
  const result = await pool.query(
    `SELECT id, email, password_hash, name, phone, created_at FROM ${DB_TABLES.USERS}
     WHERE email = $1`,
    [email]
  );
  return result.rows[0] || null;
};

/**
 * Find user by ID
 * @async
 * @param {string} userId - User ID
 * @returns {Promise<Object|null>} User object or null
 */
const findById = async (userId) => {
  const result = await pool.query(
    `SELECT id, email, name, phone, created_at FROM ${DB_TABLES.USERS}
     WHERE id = $1`,
    [userId]
  );
  return result.rows[0] || null;
};

/**
 * Create new user
 * @async
 * @param {Object} userData - User data
 * @param {string} userData.email - User email
 * @param {string} userData.passwordHash - Hashed password
 * @param {string} userData.name - User name
 * @param {string} userData.phone - User phone
 * @returns {Promise<Object>} Created user object
 */
const create = async ({ email, passwordHash, name, phone }) => {
  const result = await pool.query(
    `INSERT INTO ${DB_TABLES.USERS} (email, password_hash, name, phone)
     VALUES ($1, $2, $3, $4)
     RETURNING id, email, name, phone, created_at`,
    [email, passwordHash, name, phone]
  );
  return result.rows[0];
};

module.exports = {
  findByEmail,
  findById,
  create,
};

