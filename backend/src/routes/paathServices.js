/**
 * Paath Services Routes (Public)
 * Lists available paath services for the mobile app
 */

const express = require('express');
const { pool } = require('../database');
const { DB_TABLES } = require('../constants');
const { get: cacheGet, set: cacheSet } = require('../utils/cache');

const router = express.Router();
const CACHE_KEY = 'paath-services';
const CACHE_TTL = 300; // 5 min

/**
 * GET /api/paath-services
 * List all active paath services (public, no auth)
 */
router.get('/', async (req, res, next) => {
  try {
    const cached = cacheGet(CACHE_KEY);
    if (cached !== undefined) {
      return res.json(cached);
    }

    const r = await pool.query(
      `SELECT id, name, description, price, is_family_service, installments, display_order
       FROM ${DB_TABLES.PAATH_SERVICES}
       WHERE is_active = true
       ORDER BY display_order ASC, name ASC`
    );
    const data = r.rows.map((row) => ({
      id: row.id,
      name: row.name,
      description: row.description || '',
      price: parseFloat(row.price),
      isFamilyService: !!row.is_family_service,
      installments: parseInt(row.installments, 10) || 6,
      displayOrder: row.display_order,
    }));

    cacheSet(CACHE_KEY, data, CACHE_TTL);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
