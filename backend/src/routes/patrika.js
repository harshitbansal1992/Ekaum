/**
 * Public Patrika Routes (Mobile App)
 * GET /api/patrika - List all patrika issues
 * GET /api/patrika/purchases/:userId - User's purchases (auth)
 * POST /api/patrika/purchases - Record purchase (auth)
 */

const express = require('express');
const { pool } = require('../database');
const { DB_TABLES, HTTP_STATUS } = require('../constants');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/patrika
 * List all patrika issues (public)
 */
router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, title, month, year, pdf_url, cover_image_url, price, published_date
       FROM ${DB_TABLES.PATRIKA}
       ORDER BY year DESC, month DESC`
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      title: row.title,
      month: row.month,
      year: row.year,
      pdfUrl: row.pdf_url,
      coverImageUrl: row.cover_image_url,
      price: parseFloat(row.price),
      publishedDate: row.published_date ? new Date(row.published_date).toISOString() : null,
    })));
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/patrika/purchases/:userId
 * Get user's patrika purchases (authenticated, own userId only)
 */
router.get('/purchases/:userId', authenticateToken, async (req, res, next) => {
  try {
    const reqUserId = req.user?.userId || req.user?.id;
    const { userId } = req.params;
    if (reqUserId !== userId) {
      return res.status(HTTP_STATUS.FORBIDDEN).json({ error: 'Access denied' });
    }
    const r = await pool.query(
      `SELECT patrika_id FROM ${DB_TABLES.PATRIKA_PURCHASES} WHERE user_id = $1`,
      [userId]
    );
    res.json(r.rows.map((row) => row.patrika_id?.toString() ?? ''));
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/patrika/purchases
 * Record patrika purchase (authenticated)
 */
router.post('/purchases', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const { patrikaId, amount, paymentId } = req.body;
    if (!patrikaId || !amount || !paymentId) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'patrikaId, amount, paymentId required' });
    }
    await pool.query(
      `INSERT INTO ${DB_TABLES.PATRIKA_PURCHASES} (user_id, patrika_id, amount, payment_id)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id, patrika_id) DO UPDATE SET amount = EXCLUDED.amount, payment_id = EXCLUDED.payment_id`,
      [userId, patrikaId, parseFloat(amount), paymentId]
    );
    res.status(HTTP_STATUS.OK).json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
