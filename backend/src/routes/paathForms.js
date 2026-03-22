/**
 * Paath Forms Routes (Mobile App)
 * Create and list paath service forms for authenticated users
 */

const express = require('express');
const { pool } = require('../database');
const { authenticateToken } = require('../middleware/auth');
const { HTTP_STATUS, ERROR_MESSAGES, DB_TABLES } = require('../constants');

const router = express.Router();

/**
 * POST /api/paath-forms
 * Create a new paath form (authenticated)
 */
router.post('/', authenticateToken, async (req, res, next) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    const {
      serviceId,
      serviceName,
      totalAmount,
      installments = 6,
      installmentAmount,
      name,
      dateOfBirth,
      timeOfBirth,
      placeOfBirth,
      fathersOrHusbandsName,
      gotra,
      caste,
      familyMembers = [],
    } = req.body;

    if (!serviceId || !serviceName || !name || !dateOfBirth || !timeOfBirth
        || !placeOfBirth || !fathersOrHusbandsName || !gotra || !caste) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        error: 'Missing required fields: serviceId, serviceName, name, dateOfBirth, timeOfBirth, placeOfBirth, fathersOrHusbandsName, gotra, caste',
      });
    }

    const total = parseFloat(totalAmount) || 0;
    const installs = parseInt(installments, 10) || 6;
    const instAmount = parseFloat(installmentAmount) || total / installs;

    // Normalize dateOfBirth to YYYY-MM-DD for PostgreSQL
    let dob = dateOfBirth;
    if (typeof dob === 'string' && dob.includes('T')) {
      dob = dob.split('T')[0];
    }

    const result = await pool.query(
      `INSERT INTO ${DB_TABLES.PAATH_FORMS} (
        user_id, service_id, service_name, total_amount, installments, installment_amount,
        name, date_of_birth, time_of_birth, place_of_birth,
        fathers_or_husbands_name, gotra, caste
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING id`,
      [
        userId,
        serviceId,
        serviceName,
        total,
        installs,
        instAmount,
        name,
        dob,
        timeOfBirth,
        placeOfBirth,
        fathersOrHusbandsName,
        gotra,
        caste,
      ]
    );

    const formId = result.rows[0].id;

    // Insert family members if any
    if (Array.isArray(familyMembers) && familyMembers.length > 0) {
      for (const fm of familyMembers) {
        let fmDob = fm.dateOfBirth || fm.date_of_birth;
        if (typeof fmDob === 'string' && fmDob.includes('T')) {
          fmDob = fmDob.split('T')[0];
        }
        await pool.query(
          `INSERT INTO ${DB_TABLES.PAATH_FORM_FAMILY_MEMBERS} (
            paath_form_id, name, date_of_birth, time_of_birth, place_of_birth, relationship
          ) VALUES ($1, $2, $3, $4, $5, $6)`,
          [
            formId,
            fm.name,
            fmDob,
            fm.timeOfBirth || fm.time_of_birth,
            fm.placeOfBirth || fm.place_of_birth,
            fm.relationship || 'family',
          ]
        );
      }
    }

    // Create placeholder paath_payments records for each installment
    for (let i = 1; i <= installs; i += 1) {
      await pool.query(
        `INSERT INTO ${DB_TABLES.PAATH_PAYMENTS} (paath_form_id, installment_number, amount, status)
         VALUES ($1, $2, $3, 'pending')
         ON CONFLICT (paath_form_id, installment_number) DO NOTHING`,
        [formId, i, instAmount]
      );
    }

    return res.status(HTTP_STATUS.OK).json({ formId: formId.toString() });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/paath-forms/detail/:formId
 * Get single paath form with installments & paath status (authenticated, must own form)
 */
router.get('/detail/:formId', authenticateToken, async (req, res, next) => {
  try {
    const authUserId = req.user?.userId || req.user?.id;
    const { formId } = req.params;

    const r = await pool.query(
      `SELECT pf.* FROM ${DB_TABLES.PAATH_FORMS} pf WHERE pf.id = $1 AND pf.user_id = $2`,
      [formId, authUserId]
    );
    if (r.rows.length === 0) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Paath form not found' });
    }
    const row = r.rows[0];

    const fm = await pool.query(
      `SELECT * FROM ${DB_TABLES.PAATH_FORM_FAMILY_MEMBERS} WHERE paath_form_id = $1`,
      [formId]
    );
    const inst = await pool.query(
      `SELECT installment_number, amount, status, payment_id, payment_date
       FROM ${DB_TABLES.PAATH_PAYMENTS} WHERE paath_form_id = $1 ORDER BY installment_number ASC`,
      [formId]
    );

    return res.json({
      id: row.id,
      serviceId: row.service_id,
      serviceName: row.service_name,
      totalAmount: row.total_amount ? parseFloat(row.total_amount) : null,
      installments: row.installments,
      installmentAmount: row.installment_amount ? parseFloat(row.installment_amount) : null,
      name: row.name,
      dateOfBirth: row.date_of_birth,
      timeOfBirth: row.time_of_birth,
      placeOfBirth: row.place_of_birth,
      fathersOrHusbandsName: row.fathers_or_husbands_name,
      gotra: row.gotra,
      caste: row.caste,
      paymentStatus: row.payment_status,
      paathStatus: row.paath_status || 'pending',
      paathDoneDate: row.paath_done_date ? row.paath_done_date.toISOString().split('T')[0] : null,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      familyMembers: fm.rows.map((m) => ({
        id: m.id,
        name: m.name,
        dateOfBirth: m.date_of_birth,
        timeOfBirth: m.time_of_birth,
        placeOfBirth: m.place_of_birth,
        relationship: m.relationship,
      })),
      installmentDetails: inst.rows.map((i) => ({
        installmentNumber: i.installment_number,
        amount: i.amount ? parseFloat(i.amount) : null,
        status: i.status || 'pending',
        paymentId: i.payment_id,
        paymentDate: i.payment_date ? new Date(i.payment_date).toISOString() : null,
      })),
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/paath-forms/:userId
 * Get paath forms for a user (authenticated, userId must match token)
 */
router.get('/:userId', authenticateToken, async (req, res, next) => {
  try {
    const authUserId = req.user?.userId || req.user?.id;
    const { userId } = req.params;

    if (userId !== authUserId) {
      return res.status(HTTP_STATUS.FORBIDDEN).json({ error: ERROR_MESSAGES.ACCESS_DENIED });
    }

    const result = await pool.query(
      `SELECT id, service_id, service_name, total_amount, installments, installment_amount,
              name, date_of_birth, time_of_birth, place_of_birth,
              fathers_or_husbands_name, gotra, caste, payment_status,
              paath_status, paath_done_date, created_at
       FROM ${DB_TABLES.PAATH_FORMS}
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );

    const forms = result.rows.map((row) => ({
      id: row.id,
      formId: row.id,
      serviceId: row.service_id,
      serviceName: row.service_name,
      totalAmount: parseFloat(row.total_amount),
      installments: row.installments,
      installmentAmount: parseFloat(row.installment_amount),
      name: row.name,
      dateOfBirth: row.date_of_birth,
      timeOfBirth: row.time_of_birth,
      placeOfBirth: row.place_of_birth,
      fathersOrHusbandsName: row.fathers_or_husbands_name,
      gotra: row.gotra,
      caste: row.caste,
      paymentStatus: row.payment_status,
      paathStatus: row.paath_status || 'pending',
      paathDoneDate: row.paath_done_date ? row.paath_done_date.toISOString().split('T')[0] : null,
      createdAt: row.created_at,
    }));

    return res.json(forms);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
