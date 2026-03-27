#!/usr/bin/env node
/**
 * Debug script: Find "Test User Completed" form and check paath_payments
 * Run: node scripts/debug-installments.js
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
require('dotenv').config({ path: path.resolve(__dirname, '../.env.development') });

const { pool } = require('../src/database');

async function run() {
  const email = 'dhanesh.m.india@gmail.com';
  const serviceName = 'Durga Saptashti Paath';
  const totalAmount = 21000;

  const formRes = await pool.query(
    `SELECT pf.id, pf.name, pf.service_name, pf.total_amount, pf.installments, pf.payment_status, u.email
     FROM paath_forms pf
     JOIN users u ON pf.user_id = u.id
     WHERE u.email = $1 AND pf.service_name = $2 AND pf.total_amount = $3
     ORDER BY pf.created_at DESC LIMIT 1`,
    [email, serviceName, totalAmount]
  );

  if (formRes.rows.length === 0) {
    console.log('No form found for', email, serviceName, totalAmount);
    return;
  }

  const form = formRes.rows[0];
  console.log('Form found:', {
    id: form.id,
    name: form.name,
    service: form.service_name,
    total: form.total_amount,
    installments: form.installments,
    paymentStatus: form.payment_status,
  });

  const payRes = await pool.query(
    `SELECT installment_number, amount, status, payment_id, payment_date
     FROM paath_payments WHERE paath_form_id = $1 ORDER BY installment_number`,
    [form.id]
  );

  console.log('Paath payments count:', payRes.rows.length);
  console.log('Paath payments:', payRes.rows);
}

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => pool.end());
