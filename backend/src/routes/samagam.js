/**
 * Public Samagam Routes (Mobile App)
 * GET /api/samagam - List all events
 * GET /api/samagam/upcoming - List upcoming events (future only, limit 3)
 */

const express = require('express');
const { pool } = require('../database');
const { DB_TABLES } = require('../constants');
const { get: cacheGet, set: cacheSet } = require('../utils/cache');

const router = express.Router();
const CACHE_TTL = 300; // 5 min

function rowToEvent(row) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    startDate: row.start_date ? new Date(row.start_date).toISOString() : null,
    endDate: row.end_date ? new Date(row.end_date).toISOString() : null,
    location: row.location,
    address: row.address,
    imageUrl: row.image_url,
    googleMapsUrl: row.google_maps_url,
    createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
  };
}

/**
 * GET /api/samagam/upcoming?limit=3
 * Get upcoming samagam events (start_date >= NOW), ordered by start_date ASC
 */
router.get('/upcoming', async (req, res, next) => {
  try {
    const limit = Math.min(parseInt(req.query.limit, 10) || 3, 10);
    const cacheKey = `samagam:upcoming:${limit}`;
    const cached = cacheGet(cacheKey);
    if (cached !== undefined) {
      return res.json(cached);
    }

    const r = await pool.query(
      `SELECT id, title, description, start_date, end_date, location, address, image_url, google_maps_url, created_at
       FROM ${DB_TABLES.SAMAGAM}
       WHERE start_date >= NOW()
       ORDER BY start_date ASC
       LIMIT $1`,
      [limit]
    );
    const data = r.rows.map(rowToEvent);
    cacheSet(cacheKey, data, CACHE_TTL);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/samagam
 * List all samagam events (for full list page)
 */
router.get('/', async (req, res, next) => {
  try {
    const cacheKey = 'samagam:all';
    const cached = cacheGet(cacheKey);
    if (cached !== undefined) {
      return res.json(cached);
    }

    const r = await pool.query(
      `SELECT id, title, description, start_date, end_date, location, address, image_url, google_maps_url, created_at
       FROM ${DB_TABLES.SAMAGAM}
       ORDER BY start_date DESC`
    );
    const data = r.rows.map(rowToEvent);
    cacheSet(cacheKey, data, CACHE_TTL);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
