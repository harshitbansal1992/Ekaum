/**
 * Validation Utilities
 * Input validation helper functions
 */

/**
 * Validate email format
 * @param {string} email - Email to validate
 * @returns {boolean} True if valid email format
 */
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Validate password strength
 * Minimum 8 characters, at least one uppercase, one lowercase, one number
 * @param {string} password - Password to validate
 * @returns {boolean} True if password meets strength requirements
 */
const isValidPassword = (password) => {
  if (!password || password.length < 8) return false;
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  return hasUppercase && hasLowercase && hasNumber;
};

/**
 * Validate phone number format
 * @param {string} phone - Phone number to validate
 * @returns {boolean} True if valid phone format
 */
const isValidPhone = (phone) => {
  if (!phone) return true; // Phone is optional
  const phoneRegex = /^[+]?[\d\s-()]+$/;
  return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10;
};

/**
 * Validate UUID format
 * @param {string} uuid - UUID to validate
 * @returns {boolean} True if valid UUID
 */
const isValidUUID = (uuid) => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
};

/**
 * Validate positive number
 * @param {any} value - Value to validate
 * @param {number} min - Minimum value (optional)
 * @param {number} max - Maximum value (optional)
 * @returns {boolean} True if valid positive number
 */
const isValidPositiveNumber = (value, min = 0, max = Infinity) => {
  const num = parseFloat(value);
  return !isNaN(num) && num >= min && num <= max;
};

/**
 * Sanitize user input to prevent XSS
 * @param {string} input - Input to sanitize
 * @returns {string} Sanitized input
 */
const sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  return input
    .trim()
    .replace(/[<>]/g, '') // Remove angle brackets
    .slice(0, 1000); // Limit length
};

/**
 * Validate required fields in object
 * @param {Object} obj - Object to validate
 * @param {string[]} requiredFields - Array of required field names
 * @returns {Object} { valid: boolean, missingFields: string[] }
 */
const validateRequiredFields = (obj, requiredFields) => {
  const missingFields = requiredFields.filter(
    (field) => !obj[field] || (typeof obj[field] === 'string' && !obj[field].trim())
  );

  return {
    valid: missingFields.length === 0,
    missingFields,
  };
};

module.exports = {
  isValidEmail,
  isValidPassword,
  isValidPhone,
  isValidUUID,
  isValidPositiveNumber,
  sanitizeInput,
  validateRequiredFields,
};

