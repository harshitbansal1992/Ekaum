/**
 * Settings Routes
 * Key-value store for dynamic app content (e.g. home hero text)
 */

const express = require('express');
const { pool } = require('../database');
const { HTTP_STATUS, DB_TABLES } = require('../constants');
const { get: cacheGet, set: cacheSet, invalidate: cacheInvalidate } = require('../utils/cache');

const router = express.Router();
const CACHE_KEY_SETTINGS = 'settings:all';
const CACHE_TTL = 60; // 1 min - feature flags change occasionally

/** Feature flag keys (app_settings) - used by Flutter home page */
const FEATURE_KEYS = [
  'feature_kundli_lite_enabled',
  'feature_video_satsang_enabled',
  'feature_nadi_dosh_enabled',
  'feature_rahu_kaal_enabled',
  'feature_avdhan_enabled',
  'feature_panchang_enabled',
  'feature_mantra_notes_enabled',
  'feature_samagam_enabled',
  'feature_patrika_enabled',
  'feature_pooja_items_enabled',
  'feature_paath_services_enabled',
  'feature_donation_enabled',
  'feature_announcements_enabled',
  'feature_daily_ekaum_enabled',
  'feature_social_activities_enabled',
  'feature_blog_enabled',
  'feature_bslnd_centers_enabled',
];

/**
 * GET /api/settings
 * Get all feature flags (for backoffice)
 */
router.get('/', async (req, res, next) => {
  try {
    const cached = cacheGet(CACHE_KEY_SETTINGS);
    if (cached !== undefined) {
      return res.status(HTTP_STATUS.OK).json(cached);
    }

    const result = await pool.query(
      `SELECT key, value, updated_at FROM ${DB_TABLES.APP_SETTINGS}
       WHERE key = ANY($1::text[])
       ORDER BY key`,
      [FEATURE_KEYS]
    );

    const settings = result.rows.reduce((acc, row) => {
      acc[row.key] = { value: row.value, updatedAt: row.updated_at };
      return acc;
    }, {});

    // Ensure all feature keys exist with defaults
    FEATURE_KEYS.forEach((key) => {
      if (!settings[key]) {
        settings[key] = { value: 'true', updatedAt: null };
      }
    });

    cacheSet(CACHE_KEY_SETTINGS, settings, CACHE_TTL);
    res.status(HTTP_STATUS.OK).json(settings);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/settings/:key
 * Get a setting value by key (public, no auth required)
 */
router.get('/:key', async (req, res, next) => {
  try {
    const { key } = req.params;

    const result = await pool.query(
      `SELECT key, value, updated_at FROM ${DB_TABLES.APP_SETTINGS} WHERE key = $1`,
      [key]
    );

    if (result.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        error: `Setting not found for key: ${key}`,
      });
    }

    res.status(HTTP_STATUS.OK).json({
      key: result.rows[0].key,
      value: result.rows[0].value,
      updatedAt: result.rows[0].updated_at,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /api/settings/:key
 * Update a setting value (admin, no auth for now per BACK_OFFICE_CONTEXT)
 */
router.put('/:key', async (req, res, next) => {
  try {
    const { key } = req.params;
    const { value } = req.body;

    if (value === undefined || value === null) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'value is required',
      });
    }

    const result = await pool.query(
      `INSERT INTO ${DB_TABLES.APP_SETTINGS} (key, value, updated_at)
       VALUES ($1, $2, NOW())
       ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = NOW()
       RETURNING key, value, updated_at`,
      [key, String(value)]
    );

    cacheInvalidate(CACHE_KEY_SETTINGS);

    res.status(HTTP_STATUS.OK).json({
      key: result.rows[0].key,
      value: result.rows[0].value,
      updatedAt: result.rows[0].updated_at,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
