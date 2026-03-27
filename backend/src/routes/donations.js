/**
 * Donations Routes (Mobile App)
 * Create donation record before payment (authenticated)
 */

const express = require('express');
const { pool } = require('../database');
const { authenticateToken } = require('../middleware/auth');
const { HTTP_STATUS, ERROR_MESSAGES, DB_TABLES } = require('../constants');

const router = express.Router();

/**
 * POST /api/donations
 * Create a pending donation record (authenticated). Returns donationId for payment flow.
 * Body: { amount, isRecurring?, frequency? } - frequency: 'monthly' | 'yearly'
 */
router.post('/', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const { amount, isRecurring, frequency } = req.body;

    if (amount == null || amount === '') {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'amount is required',
      });
    }

    const amt = parseFloat(amount);
    if (Number.isNaN(amt) || amt <= 0) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Invalid amount',
      });
    }

    const result = await pool.query(
      `INSERT INTO ${DB_TABLES.DONATIONS} (user_id, amount, status)
       VALUES ($1, $2, 'pending')
       RETURNING id`,
      [userId, amt]
    );

    const donationId = result.rows[0].id;
    return res.status(HTTP_STATUS.OK).json({
      donationId: donationId.toString(),
      isRecurring: !!isRecurring,
      frequency: frequency === 'yearly' ? 'yearly' : 'monthly',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/donations/subscriptions
 * List user's recurring donation subscriptions
 */
router.get('/subscriptions', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const r = await pool.query(
      `SELECT id, amount, frequency, status, next_billing_date, created_at
       FROM ${DB_TABLES.DONATION_SUBSCRIPTIONS}
       WHERE user_id = $1 AND status = 'active'
       ORDER BY created_at DESC`,
      [userId]
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      amount: parseFloat(row.amount),
      frequency: row.frequency,
      status: row.status,
      nextBillingDate: row.next_billing_date ? row.next_billing_date.toISOString().slice(0, 10) : null,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    })));
  } catch (err) {
    next(err);
  }
});

/**
 * PATCH /api/donations/subscriptions/:id
 * Cancel a recurring donation subscription
 */
router.patch('/subscriptions/:id', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const { id } = req.params;
    const r = await pool.query(
      `UPDATE ${DB_TABLES.DONATION_SUBSCRIPTIONS}
       SET status = 'cancelled', updated_at = NOW()
       WHERE id = $1 AND user_id = $2 RETURNING id`,
      [id, userId]
    );
    if (r.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Subscription not found' });
    }
    res.json({ success: true, message: 'Recurring donation cancelled' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
