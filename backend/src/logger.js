/**
 * Logger Utility
 * Centralized logging for the application
 */

const logger = {
  /**
   * Log info level message
   * @param {...args} args - Arguments to log
   */
  info: (...args) => {
    console.log('ℹ️  [INFO]', new Date().toISOString(), ...args);
  },

  /**
   * Log error level message
   * @param {...args} args - Arguments to log
   */
  error: (...args) => {
    console.error('❌ [ERROR]', new Date().toISOString(), ...args);
  },

  /**
   * Log warning level message
   * @param {...args} args - Arguments to log
   */
  warn: (...args) => {
    console.warn('⚠️  [WARN]', new Date().toISOString(), ...args);
  },

  /**
   * Log debug level message
   * @param {...args} args - Arguments to log
   */
  debug: (...args) => {
    if (process.env.NODE_ENV !== 'production') {
      console.log('🐛 [DEBUG]', new Date().toISOString(), ...args);
    }
  },

  /**
   * Log success level message
   * @param {...args} args - Arguments to log
   */
  success: (...args) => {
    console.log('✅ [SUCCESS]', new Date().toISOString(), ...args);
  },
};

module.exports = logger;

