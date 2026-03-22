/**
 * Payment Routes - Razorpay Integration
 * Create orders, verify payments, and handle webhooks
 */

const express = require('express');
const Razorpay = require('razorpay');
const crypto = require('crypto');
const { pool } = require('../database');
const { config } = require('../config');
const { authenticateToken } = require('../middleware/auth');
const { HTTP_STATUS, ERROR_MESSAGES, DB_TABLES, PAYMENT_TYPES } = require('../constants');
const logger = require('../logger');

const router = express.Router();

// Razorpay instance (uses key_id and key_secret from config)
let razorpay = null;
const getRazorpay = () => {
  if (!config.razorpay?.keyId || !config.razorpay?.keySecret) {
    throw new Error('Razorpay credentials not configured');
  }
  if (!razorpay) {
    razorpay = new Razorpay({
      key_id: config.razorpay.keyId,
      key_secret: config.razorpay.keySecret,
    });
  }
  return razorpay;
};

/**
 * POST /api/payments/create-order
 * Create a Razorpay order for payment
 * Auth required
 */
router.post('/create-order', authenticateToken, async (req, res, next) => {
  try {
    const { amount, type, metadata } = req.body;
    const userId = req.user?.userId || req.user?.id;

    if (!amount || !type || !userId) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'amount, type, and user required',
      });
    }

    const rp = getRazorpay();

    // Amount in paise (1 INR = 100 paise)
    const amountPaise = Math.round(parseFloat(amount) * 100);
    if (amountPaise < 100) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Minimum amount is ₹1',
      });
    }

    const receipt = `rcpt_${type}_${Date.now()}_${userId.substring(0, 8)}`;
    const notes = {
      userId,
      type,
      ...metadata,
    };

    const order = await rp.orders.create({
      amount: amountPaise,
      currency: 'INR',
      receipt,
      notes,
    });

    return res.status(HTTP_STATUS.CREATED).json({
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: config.razorpay.keyId,
    });
  } catch (err) {
    if (err.message === 'Razorpay credentials not configured') {
      return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: 'Payment service not configured',
      });
    }
    logger.error('Create order error:', err);
    next(err);
  }
});

/**
 * POST /api/payments/verify
 * Verify payment with Razorpay and update database
 * Auth required
 */
router.post('/verify', authenticateToken, async (req, res, next) => {
  try {
    const { orderId, paymentId } = req.body;
    const userId = req.user?.userId || req.user?.id;

    if (!orderId || !paymentId) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'orderId and paymentId required',
      });
    }

    const rp = getRazorpay();

    // Fetch payment from Razorpay to verify
    const payment = await rp.payments.fetch(paymentId);

    if (payment.status !== 'captured') {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        success: false,
        error: 'Payment not captured',
      });
    }

    if (payment.order_id !== orderId) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        success: false,
        error: 'Order mismatch',
      });
    }

    const amount = payment.amount / 100; // paise to INR
    let notes = payment.notes || {};

    // If payment has no notes, fetch order for metadata
    if (!notes.type) {
      try {
        const order = await rp.orders.fetch(orderId);
        notes = order.notes || {};
      } catch (e) {
        logger.warn('Could not fetch order for notes:', e.message);
      }
    }
    const type = notes.type || 'unknown';

    // Insert payment record
    await pool.query(
      `INSERT INTO ${DB_TABLES.PAYMENTS} (user_id, payment_id, payment_request_id, status, amount, type, buyer_name, buyer_email, buyer_phone, metadata, completed_at)
       VALUES ($1, $2, $3, 'completed', $4, $5, $6, $7, $8, $9, NOW())
       ON CONFLICT (payment_id) DO UPDATE SET status = 'completed', completed_at = NOW()`,
      [
        userId,
        paymentId,
        orderId,
        amount,
        type,
        notes.name || null,
        notes.email || null,
        notes.phone || null,
        JSON.stringify(notes),
      ]
    );

    // Update type-specific records
    switch (type) {
      case PAYMENT_TYPES.SUBSCRIPTION: {
        const startDate = new Date();
        const expiryDate = new Date();
        expiryDate.setMonth(expiryDate.getMonth() + 1);

        await pool.query(
          `INSERT INTO ${DB_TABLES.SUBSCRIPTIONS} (user_id, is_active, amount, payment_id, start_date, expiry_date)
           VALUES ($1, true, $2, $3, $4, $5)
           ON CONFLICT (user_id) DO UPDATE SET
             is_active = true,
             amount = EXCLUDED.amount,
             payment_id = EXCLUDED.payment_id,
             start_date = EXCLUDED.start_date,
             expiry_date = EXCLUDED.expiry_date`,
          [userId, amount, paymentId, startDate, expiryDate]
        );
        break;
      }
      case PAYMENT_TYPES.PATRIKA: {
        const issueId = notes.issueId;
        if (issueId) {
          await pool.query(
            `INSERT INTO ${DB_TABLES.PATRIKA_PURCHASES} (user_id, patrika_id, amount, payment_id)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (user_id, patrika_id) DO UPDATE SET amount = EXCLUDED.amount, payment_id = EXCLUDED.payment_id`,
            [userId, issueId, amount, paymentId]
          );
        }
        break;
      }
      case PAYMENT_TYPES.PAATH: {
        const formId = notes.formId;
        const installmentNumber = parseInt(notes.installmentNumber, 10);
        const payRemainingInFull = notes.payRemainingInFull === 'true' || notes.payRemainingInFull === true;
        if (formId && !Number.isNaN(installmentNumber)) {
          if (payRemainingInFull) {
            const formRow = await pool.query(
              `SELECT installments, installment_amount, total_amount FROM ${DB_TABLES.PAATH_FORMS} WHERE id = $1`,
              [formId]
            );
            const totalInstallments = parseInt(formRow.rows[0]?.installments || 6, 10);
            const totalAmount = parseFloat(formRow.rows[0]?.total_amount || 0);

            const paidRows = await pool.query(
              `SELECT COALESCE(SUM(amount), 0) AS paid_amount
               FROM ${DB_TABLES.PAATH_PAYMENTS}
               WHERE paath_form_id = $1 AND status = 'completed'`,
              [formId]
            );
            const alreadyPaidAmount = parseFloat(paidRows.rows[0]?.paid_amount || 0);
            const remainingAmount = Math.max(0, totalAmount - alreadyPaidAmount);

            const remainingCount = Math.max(1, totalInstallments - installmentNumber + 1);
            const baseAmount = Math.floor((remainingAmount / remainingCount) * 100) / 100;
            let allocated = 0;

            for (let n = installmentNumber; n <= totalInstallments; n += 1) {
              const isLast = n === totalInstallments;
              const currentAmount = isLast
                ? Math.max(0, Math.round((remainingAmount - allocated) * 100) / 100)
                : baseAmount;
              allocated += currentAmount;

              await pool.query(
                `INSERT INTO ${DB_TABLES.PAATH_PAYMENTS} (paath_form_id, installment_number, amount, payment_id, status, payment_date)
                 VALUES ($1, $2, $3, $4, 'completed', NOW())
                 ON CONFLICT (paath_form_id, installment_number) DO UPDATE SET
                   payment_id = EXCLUDED.payment_id,
                   status = 'completed',
                   amount = EXCLUDED.amount,
                   payment_date = NOW()`,
                [formId, n, currentAmount, paymentId]
              );
            }
          } else {
            await pool.query(
              `INSERT INTO ${DB_TABLES.PAATH_PAYMENTS} (paath_form_id, installment_number, amount, payment_id, status, payment_date)
               VALUES ($1, $2, $3, $4, 'completed', NOW())
               ON CONFLICT (paath_form_id, installment_number) DO UPDATE SET
                 payment_id = EXCLUDED.payment_id,
                 status = 'completed',
                 amount = EXCLUDED.amount,
                 payment_date = NOW()`,
              [formId, installmentNumber, amount, paymentId]
            );
          }

          // Check amount paid and update form payment status
          const paidAmountRow = await pool.query(
            `SELECT COALESCE(SUM(amount), 0) AS paid_amount
             FROM ${DB_TABLES.PAATH_PAYMENTS}
             WHERE paath_form_id = $1 AND status = 'completed'`,
            [formId]
          );
          const formTotalRow = await pool.query(
            `SELECT total_amount FROM ${DB_TABLES.PAATH_FORMS} WHERE id = $1`,
            [formId]
          );
          const paidAmount = parseFloat(paidAmountRow.rows[0]?.paid_amount || 0);
          const totalAmount = parseFloat(formTotalRow.rows[0]?.total_amount || 0);
          const newStatus = paidAmount >= totalAmount
            ? 'completed'
            : paidAmount > 0 ? 'partial' : 'pending';

          await pool.query(
            `UPDATE ${DB_TABLES.PAATH_FORMS} SET payment_status = $1, updated_at = NOW() WHERE id = $2`,
            [newStatus, formId]
          );
        }
        break;
      }
      case PAYMENT_TYPES.DONATION: {
        const donationId = notes.donationId;
        if (donationId) {
          await pool.query(
            `UPDATE ${DB_TABLES.DONATIONS}
             SET status = 'completed', payment_id = $1, completed_at = NOW()
             WHERE id = $2 AND user_id = $3`,
            [paymentId, donationId, userId]
          );
        } else {
          await pool.query(
            `INSERT INTO ${DB_TABLES.DONATIONS} (user_id, amount, status, payment_id, completed_at)
             VALUES ($1, $2, 'completed', $3, NOW())`,
            [userId, amount, paymentId]
          );
        }
        // Create recurring donation subscription if requested
        const isRecurring = notes.isRecurring === 'true' || notes.isRecurring === true;
        const frequency = notes.frequency || 'monthly';
        if (isRecurring) {
          const nextBilling = new Date();
          if (frequency === 'yearly') {
            nextBilling.setFullYear(nextBilling.getFullYear() + 1);
          } else {
            nextBilling.setMonth(nextBilling.getMonth() + 1);
          }
          await pool.query(
            `INSERT INTO ${DB_TABLES.DONATION_SUBSCRIPTIONS} (user_id, amount, frequency, status, next_billing_date)
             VALUES ($1, $2, $3, 'active', $4)`,
            [userId, amount, frequency, nextBilling]
          );
        }
        break;
      }
      default:
        break;
    }

    return res.status(HTTP_STATUS.OK).json({
      success: true,
      paymentId,
      type,
    });
  } catch (err) {
    if (err.message === 'Razorpay credentials not configured') {
      return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: 'Payment service not configured',
      });
    }
    logger.error('Verify payment error:', err);
    next(err);
  }
});

/**
 * Webhook handler - mounted in server.js with express.raw() for signature verification
 * Razorpay webhook - verify signature and process payment.captured events
 */
const webhookHandler = (req, res) => {
  try {
    const webhookSecret = config.razorpay?.webhookSecret;
    if (!webhookSecret) {
      logger.warn('Razorpay webhook secret not configured');
      return res.status(HTTP_STATUS.OK).json({ received: true });
    }

    const signature = req.headers['x-razorpay-signature'];
    if (!signature) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'Missing signature' });
    }

    // req.body is Buffer from express.raw()
    const rawBody = req.body?.toString?.() || (Buffer.isBuffer(req.body) ? req.body.toString('utf8') : '');
    if (!rawBody) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'Invalid body' });
    }

    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(rawBody)
      .digest('hex');

    if (expectedSignature !== signature) {
      logger.warn('Razorpay webhook signature mismatch');
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'Invalid signature' });
    }

    const body = JSON.parse(rawBody);
    const event = body.event;
    if (event === 'payment.captured') {
      const payment = body.payload?.payment?.entity;
      if (payment) {
        processWebhookPayment(payment).catch((err) => logger.error('Webhook process error:', err));
      }
    }

    return res.status(HTTP_STATUS.OK).json({ received: true });
  } catch (err) {
    logger.error('Webhook error:', err);
    return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({ error: 'Webhook failed' });
  }
};

async function processWebhookPayment(payment) {
  const notes = payment.notes || {};
  const userId = notes.userId;
  const type = notes.type;
  const amount = payment.amount / 100;

  if (!userId) return;

  await pool.query(
    `INSERT INTO ${DB_TABLES.PAYMENTS} (user_id, payment_id, payment_request_id, status, amount, type, buyer_name, buyer_email, buyer_phone, metadata, completed_at)
     VALUES ($1, $2, $3, 'completed', $4, $5, $6, $7, $8, $9, NOW())
     ON CONFLICT (payment_id) DO NOTHING`,
    [
      userId,
      payment.id,
      payment.order_id,
      amount,
      type || 'unknown',
      notes.name || null,
      notes.email || null,
      notes.phone || null,
      JSON.stringify(notes),
    ]
  );

  // Same type-specific updates as verify (simplified - main updates happen in app verify)
  if (type === PAYMENT_TYPES.SUBSCRIPTION) {
    const startDate = new Date();
    const expiryDate = new Date();
    expiryDate.setMonth(expiryDate.getMonth() + 1);
    await pool.query(
      `INSERT INTO ${DB_TABLES.SUBSCRIPTIONS} (user_id, is_active, amount, payment_id, start_date, expiry_date)
       VALUES ($1, true, $2, $3, $4, $5)
       ON CONFLICT (user_id) DO UPDATE SET is_active = true, payment_id = $3, start_date = $4, expiry_date = $5`,
      [userId, amount, payment.id, startDate, expiryDate]
    );
  }
}

module.exports = router;
module.exports.webhookHandler = webhookHandler;
