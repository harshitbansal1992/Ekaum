/**
 * Public Announcements Routes (Vishesh Sandesh - mobile app home)
 * GET /api/announcements - List announcements for home screen
 */

const express = require('express');
const { pool } = require('../database');
const { DB_TABLES } = require('../constants');

const router = express.Router();

/**
 * GET /api/announcements
 * List announcements ordered by display_order DESC, created_at DESC
 */
router.get('/', async (req, res, next) => {
  try {
    const limit = Math.min(parseInt(req.query.limit, 10) || 10, 50);
    const r = await pool.query(
      `SELECT id, title, description, display_order, created_at, updated_at
       FROM ${DB_TABLES.ANNOUNCEMENTS}
       ORDER BY display_order DESC, created_at DESC
       LIMIT $1`,
      [limit]
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
      displayOrder: row.display_order,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    })));
  } catch (err) {
    next(err);
  }
});

module.exports = router;
