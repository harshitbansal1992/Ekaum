/**
 * Application Constants
 * Centralized constants used throughout the backend
 */

const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL_SERVER_ERROR: 500,
};

const ERROR_MESSAGES = {
  UNAUTHORIZED: 'Access token required',
  INVALID_TOKEN: 'Invalid or expired token',
  ACCESS_DENIED: 'Access denied',
  USER_NOT_FOUND: 'User not found',
  EMAIL_PASSWORD_REQUIRED: 'Email and password are required',
  INVALID_CREDENTIALS: 'Invalid credentials',
  USER_EXISTS: 'User already exists',
  REQUIRED_FIELDS_MISSING: 'Required fields missing',
  INTERNAL_ERROR: 'Internal server error',
};

const DB_TABLES = {
  APP_SETTINGS: 'app_settings',
  USERS: 'users',
  SUBSCRIPTIONS: 'subscriptions',
  AVDHAN: 'avdhan',
  SAMAGAM: 'samagam',
  PATRIKA: 'patrika',
  PATRIKA_PURCHASES: 'patrika_purchases',
  PAATH_SERVICES: 'paath_services',
  PAATH_FORMS: 'paath_forms',
  PAATH_FORM_FAMILY_MEMBERS: 'paath_form_family_members',
  PAATH_PAYMENTS: 'paath_payments',
  DONATIONS: 'donations',
  PAYMENTS: 'payments',
  MANTRA_NOTES: 'mantra_notes',
  ANNOUNCEMENTS: 'announcements',
  VIDEO_SATSANG: 'video_satsang',
  DONATION_SUBSCRIPTIONS: 'donation_subscriptions',
};

const JWT_CONFIG = {
  EXPIRES_IN: '7d',
  ALGORITHM: 'HS256',
};

const PAYMENT_STATUS = {
  PENDING: 'pending',
  PARTIAL: 'partial',
  COMPLETED: 'completed',
};

const PAYMENT_TYPES = {
  SUBSCRIPTION: 'subscription',
  PATRIKA: 'patrika',
  PAATH: 'paath',
  DONATION: 'donation',
  UNKNOWN: 'unknown',
};

const PAYMENT_GATEWAY = {
  INSTAMOJO_API_URL: 'https://www.instamojo.com/api/1.1',
  STATUS_CREDIT: 'Credit',
};

module.exports = {
  HTTP_STATUS,
  ERROR_MESSAGES,
  DB_TABLES,
  JWT_CONFIG,
  PAYMENT_STATUS,
  PAYMENT_TYPES,
  PAYMENT_GATEWAY,
};

