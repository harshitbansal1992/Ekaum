/**
 * Mantra Notes Routes (Mobile App)
 * CRUD for user-stored mantras (note-taker style: heading + description)
 */

const express = require('express');
const { pool } = require('../database');
const { authenticateToken } = require('../middleware/auth');
const { HTTP_STATUS, ERROR_MESSAGES, DB_TABLES } = require('../constants');

const router = express.Router();

/**
 * GET /api/mantra-notes
 * List all mantra notes for the authenticated user
 */
router.get('/', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;

    const result = await pool.query(
      `SELECT id, heading, description, created_at, updated_at
       FROM ${DB_TABLES.MANTRA_NOTES}
       WHERE user_id = $1
       ORDER BY updated_at DESC`,
      [userId]
    );

    const notes = result.rows.map((row) => ({
      id: row.id,
      heading: row.heading,
      description: row.description || '',
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    }));

    return res.json(notes);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/mantra-notes
 * Create a new mantra note
 */
router.post('/', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    if (!userId) {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        error: 'User not identified in token',
      });
    }

    const { heading, description } = req.body;

    if (!heading || typeof heading !== 'string' || heading.trim() === '') {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'heading is required',
      });
    }

    const result = await pool.query(
      `INSERT INTO ${DB_TABLES.MANTRA_NOTES} (user_id, heading, description, updated_at)
       VALUES ($1, $2, $3, NOW())
       RETURNING id, heading, description, created_at, updated_at`,
      [userId, heading.trim(), (description || '').trim()]
    );

    const row = result.rows[0];
    return res.status(HTTP_STATUS.CREATED).json({
      id: row.id,
      heading: row.heading,
      description: row.description || '',
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/mantra-notes/:id
 * Get a single mantra note (must own it)
 */
router.get('/:id', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const { id } = req.params;

    const result = await pool.query(
      `SELECT id, heading, description, created_at, updated_at
       FROM ${DB_TABLES.MANTRA_NOTES}
       WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Mantra note not found' });
    }

    const row = result.rows[0];
    return res.json({
      id: row.id,
      heading: row.heading,
      description: row.description || '',
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/mantra-notes/:id
 * Update a mantra note
 */
router.put('/:id', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const { id } = req.params;
    const { heading, description } = req.body;

    if (!heading || typeof heading !== 'string' || heading.trim() === '') {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'heading is required',
      });
    }

    const result = await pool.query(
      `UPDATE ${DB_TABLES.MANTRA_NOTES}
       SET heading = $1, description = $2, updated_at = NOW()
       WHERE id = $3 AND user_id = $4
       RETURNING id, heading, description, created_at, updated_at`,
      [heading.trim(), (description || '').trim(), id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Mantra note not found' });
    }

    const row = result.rows[0];
    return res.json({
      id: row.id,
      heading: row.heading,
      description: row.description || '',
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * DELETE /api/mantra-notes/:id
 * Delete a mantra note
 */
router.delete('/:id', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM ${DB_TABLES.MANTRA_NOTES}
       WHERE id = $1 AND user_id = $2
       RETURNING id`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Mantra note not found' });
    }

    return res.status(HTTP_STATUS.OK).json({ message: 'Deleted' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
