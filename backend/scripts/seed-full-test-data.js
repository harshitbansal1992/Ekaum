#!/usr/bin/env node
/**
 * Full Test Data Seed Script
 * Seeds all sections with varied scenarios for complete testing.
 *
 * Run: node scripts/seed-full-test-data.js
 * Or: npm run seed:full
 *
 * Prerequisite: Run migrations first (npm run migrate)
 * Test login: test1@ekaum.test / Test@123 (and test2, test3, admin@ekaum.test)
 */

const path = require('path');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
require('dotenv').config({ path: path.resolve(__dirname, '../.env.development') });

const { pool } = require('../src/database');
const { DB_TABLES } = require('../src/constants');

const TEST_PASSWORD = 'Test@123';
const HASH = bcrypt.hashSync(TEST_PASSWORD, 10);

async function seed() {
  console.log('Seeding full test data...\n');

  // ============= USERS =============
  const users = [
    {
      email: 'test1@ekaum.test',
      name: 'Ramesh Kumar',
      phone: '9876543210',
      date_of_birth: '1985-05-15',
      time_of_birth: '10:30 AM',
      place_of_birth: 'Mumbai, Maharashtra',
      fathers_or_husbands_name: 'Shri Hari Kumar',
      gotra: 'Kashyap',
      caste: 'Brahmin',
    },
    {
      email: 'test2@ekaum.test',
      name: 'Sita Devi',
      phone: '9876543211',
      date_of_birth: '1990-08-22',
      time_of_birth: '09:15 AM',
      place_of_birth: 'Bangalore, Karnataka',
      fathers_or_husbands_name: 'Shri Ram Prasad',
      gotra: 'Bhardwaj',
      caste: 'Kshatriya',
    },
    {
      email: 'test3@ekaum.test',
      name: 'Priya Sharma',
      phone: '9876543212',
      date_of_birth: '1988-12-10',
      time_of_birth: '02:45 PM',
      place_of_birth: 'Chennai, Tamil Nadu',
      fathers_or_husbands_name: 'Shri Dev Sharma',
      gotra: 'Vatsa',
      caste: 'Vaishya',
    },
    {
      email: 'admin@ekaum.test',
      name: 'Admin User',
      phone: '9876543200',
      date_of_birth: '1980-01-01',
      time_of_birth: '12:00 PM',
      place_of_birth: 'Delhi',
      fathers_or_husbands_name: 'System Admin',
      gotra: 'Kashyap',
      caste: 'Brahmin',
    },
  ];

  const userIds = [];
  for (const u of users) {
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.USERS} (email, password_hash, name, phone, date_of_birth, time_of_birth, place_of_birth, fathers_or_husbands_name, gotra, caste)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, phone = EXCLUDED.phone
       RETURNING id`,
      [u.email, HASH, u.name, u.phone, u.date_of_birth, u.time_of_birth, u.place_of_birth, u.fathers_or_husbands_name, u.gotra, u.caste]
    );
    userIds.push({ email: u.email, id: r.rows[0].id });
  }
  console.log('✓ Users (4 test users, password: ' + TEST_PASSWORD + ')');

  // Use first user for most seeds
  const uid = userIds[0].id;
  const uid2 = userIds[1].id;
  const uid3 = userIds[2].id;

  // ============= SUBSCRIPTIONS =============
  const now = new Date();
  const expired = new Date(now);
  expired.setMonth(expired.getMonth() - 2);
  const expiryPast = new Date(expired);
  expiryPast.setMonth(expiryPast.getMonth() + 1);
  const expiryFuture = new Date(now);
  expiryFuture.setMonth(expiryFuture.getMonth() + 1);

  await pool.query(
    `INSERT INTO ${DB_TABLES.SUBSCRIPTIONS} (user_id, is_active, amount, payment_id, start_date, expiry_date)
     VALUES ($1, true, 99.00, 'pay_sub_active', $2, $3),
            ($4, false, 99.00, 'pay_sub_expired', $5, $6)
     ON CONFLICT (user_id) DO UPDATE SET is_active = EXCLUDED.is_active, expiry_date = EXCLUDED.expiry_date`,
    [uid, now, expiryFuture, uid2, expired, expiryPast]
  );
  console.log('✓ Subscriptions (active, expired)');

  // ============= SAMAGAM =============
  const samagamDates = [
    { title: 'Past Samagam 2024', start: new Date('2024-10-15'), end: new Date('2024-10-17'), location: 'Mumbai' },
    { title: 'Recent Samagam', start: new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000), end: new Date(now.getTime() - 12 * 24 * 60 * 60 * 1000), location: 'Pune' },
    { title: 'Current Samagam', start: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000), end: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000), location: 'Bangalore' },
    { title: 'Upcoming Samagam', start: new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000), end: new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000), location: 'Chennai' },
  ];
  for (const s of samagamDates) {
    await pool.query(
      `INSERT INTO ${DB_TABLES.SAMAGAM} (title, description, start_date, end_date, location, address)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [s.title, 'Samagam event for devotees', s.start, s.end, s.location, 'Venue address']
    );
  }
  console.log('✓ Samagam (past, recent, current, upcoming)');

  // ============= PATRIKA =============
  const patrikaIssues = [];
  for (let y = 2023; y <= 2025; y++) {
    for (let m = 1; m <= 12; m++) {
      if (y === 2025 && m > 3) break; // Only up to March 2025
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const r = await pool.query(
        `INSERT INTO ${DB_TABLES.PATRIKA} (title, month, year, pdf_url, price)
         VALUES ($1, $2, $3, $4, 50.00) RETURNING id`,
        [`Patrika ${monthNames[m - 1]} ${y}`, String(m).padStart(2, '0'), y, `https://example.com/patrika-${y}-${m}.pdf`]
      );
      patrikaIssues.push(r.rows[0].id);
    }
  }
  console.log('✓ Patrika (' + patrikaIssues.length + ' issues)');

  // ============= PATRIKA PURCHASES =============
  for (let i = 0; i < Math.min(5, patrikaIssues.length); i++) {
    await pool.query(
      `INSERT INTO ${DB_TABLES.PATRIKA_PURCHASES} (user_id, patrika_id, amount, payment_id)
       VALUES ($1, $2, 50.00, $3)
       ON CONFLICT (user_id, patrika_id) DO NOTHING`,
      [uid, patrikaIssues[i], `pay_patrika_${i}`]
    );
  }
  await pool.query(
    `INSERT INTO ${DB_TABLES.PATRIKA_PURCHASES} (user_id, patrika_id, amount, payment_id)
     VALUES ($1, $2, 50.00, $3)
     ON CONFLICT (user_id, patrika_id) DO NOTHING`,
    [uid2, patrikaIssues[0], 'pay_patrika_u2']
  );
  console.log('✓ Patrika purchases');

  // ============= PAATH FORMS (all scenarios) =============
  const paathScenarios = [
    { name: 'Pending Payment', service: 'vishesh_kripa_samadhan', serviceName: 'Vishesh Kripa Samadhan', total: 1100, inst: 6, instAmt: 183.33, payment: 'pending', paath: 'pending', payAll: false, paathDoneDate: null },
    { name: 'Partial Payment', service: 'mahamritunjaya_paath', serviceName: 'Mahamritunjaya Paath', total: 125000, inst: 6, instAmt: 20833.33, payment: 'partial', paath: 'pending', payCount: 3, paathDoneDate: null },
    { name: 'Completed Payment', service: 'durga_saptashti_paath', serviceName: 'Durga Saptashti Paath', total: 21000, inst: 6, instAmt: 3500, payment: 'completed', paath: 'done', payAll: true, paathDoneDate: '2025-02-15' },
    { name: 'One-Time Paid', service: 'janam_kundli_samadhar', serviceName: 'Janam Kundli Samadhar', total: 1100, inst: 1, instAmt: 1100, payment: 'completed', paath: 'pending', payAll: true, paathDoneDate: null },
    { name: 'Family Form Pending', service: 'durga_saptashti_paath_family', serviceName: 'Durga Saptashti Paath Family', total: 51000, inst: 6, instAmt: 8500, payment: 'pending', paath: 'pending', payAll: false, hasFamily: true, paathDoneDate: null },
  ];

  for (const s of paathScenarios) {
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.PAATH_FORMS} (user_id, service_id, service_name, total_amount, installments, installment_amount, name, date_of_birth, time_of_birth, place_of_birth, fathers_or_husbands_name, gotra, caste, payment_status, paath_status, paath_done_date)
     VALUES ($1, $2, $3, $4, $5, $6, $7, '1990-01-01', '10:00 AM', 'Mumbai', 'Father Name', 'Kashyap', 'Brahmin', $8, $9, $10) RETURNING id`,
      [uid, s.service, s.serviceName, s.total, s.inst, s.instAmt, s.name, s.payment, s.paath, s.paathDoneDate || null]
    );
    const formId = r.rows[0].id;

    if (s.hasFamily) {
      await pool.query(
        `INSERT INTO ${DB_TABLES.PAATH_FORM_FAMILY_MEMBERS} (paath_form_id, name, date_of_birth, time_of_birth, place_of_birth, relationship)
         VALUES ($1, 'Spouse', '1992-05-10', '11:00 AM', 'Mumbai', 'Spouse'),
                ($1, 'Child 1', '2015-03-20', '09:00 AM', 'Mumbai', 'Child')`,
        [formId]
      );
    }

    const payCount = s.payAll ? s.inst : (s.payCount || 0);
    for (let i = 1; i <= s.inst; i++) {
      const paid = i <= payCount;
      await pool.query(
        `INSERT INTO ${DB_TABLES.PAATH_PAYMENTS} (paath_form_id, installment_number, amount, status, payment_id, payment_date)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (paath_form_id, installment_number) DO UPDATE SET status = EXCLUDED.status, payment_id = EXCLUDED.payment_id, payment_date = EXCLUDED.payment_date`,
        [formId, i, s.instAmt, paid ? 'completed' : 'pending', paid ? `pay_${s.service.slice(0, 8)}_${i}` : null, paid ? new Date() : null]
      );
    }
  }

  // Extra paath forms for user2 and user3 (for backoffice variety)
  const r2 = await pool.query(
    `INSERT INTO ${DB_TABLES.PAATH_FORMS} (user_id, service_id, service_name, total_amount, installments, installment_amount, name, date_of_birth, time_of_birth, place_of_birth, fathers_or_husbands_name, gotra, caste, payment_status, paath_status)
     VALUES ($1, 'durga_saptashti_paath', 'Durga Saptashti Paath', 21000, 6, 3500, 'Sita Devi Form', '1990-08-22', '09:15 AM', 'Bangalore', 'Shri Ram Prasad', 'Bhardwaj', 'Kshatriya', 'pending', 'pending') RETURNING id`,
    [uid2]
  );
  for (let i = 1; i <= 6; i++) {
    await pool.query(
      `INSERT INTO ${DB_TABLES.PAATH_PAYMENTS} (paath_form_id, installment_number, amount, status) VALUES ($1, $2, 3500, 'pending')
       ON CONFLICT (paath_form_id, installment_number) DO NOTHING`,
      [r2.rows[0].id, i]
    );
  }
  const r3 = await pool.query(
    `INSERT INTO ${DB_TABLES.PAATH_FORMS} (user_id, service_id, service_name, total_amount, installments, installment_amount, name, date_of_birth, time_of_birth, place_of_birth, fathers_or_husbands_name, gotra, caste, payment_status, paath_status)
     VALUES ($1, 'vishesh_kripa_samadhan', 'Vishesh Kripa Samadhan', 1100, 1, 1100, 'Priya Sharma Form', '1988-12-10', '02:45 PM', 'Chennai', 'Shri Dev Sharma', 'Vatsa', 'Vaishya', 'completed', 'done') RETURNING id`,
    [uid3]
  );
  await pool.query(
    `INSERT INTO ${DB_TABLES.PAATH_PAYMENTS} (paath_form_id, installment_number, amount, status, payment_id) VALUES ($1, 1, 1100, 'completed', 'pay_priya_1')
     ON CONFLICT (paath_form_id, installment_number) DO NOTHING`,
    [r3.rows[0].id]
  );
  await pool.query(`UPDATE ${DB_TABLES.PAATH_FORMS} SET paath_done_date = '2025-01-20' WHERE id = $1`, [r3.rows[0].id]);

  console.log('✓ Paath forms (pending, partial, completed, one-time, family)');

  // ============= DONATIONS =============
  await pool.query(
    `INSERT INTO ${DB_TABLES.DONATIONS} (user_id, amount, status, payment_id, completed_at)
     VALUES ($1, 500.00, 'pending', NULL, NULL),
            ($1, 1000.00, 'completed', 'pay_don_1', NOW()),
            ($2, 250.00, 'completed', 'pay_don_2', NOW() - INTERVAL '7 days')`,
    [uid, uid2]
  );
  console.log('✓ Donations (pending, completed)');

  // ============= PAYMENTS =============
  await pool.query(
    `INSERT INTO ${DB_TABLES.PAYMENTS} (user_id, payment_id, status, amount, type, buyer_name, buyer_email, completed_at)
     VALUES ($1, 'pay_sub_active', 'completed', 99.00, 'subscription', 'Ramesh Kumar', 'test1@ekaum.test', NOW()),
            ($1, 'pay_don_1', 'completed', 1000.00, 'donation', 'Ramesh Kumar', 'test1@ekaum.test', NOW()),
            ($2, 'pay_don_2', 'completed', 250.00, 'donation', 'Sita Devi', 'test2@ekaum.test', NOW() - INTERVAL '7 days')
     ON CONFLICT (payment_id) DO NOTHING`,
    [uid, uid2]
  );
  console.log('✓ Payments');

  // ============= APP SETTINGS (ensure hero text) =============
  await pool.query(
    `INSERT INTO app_settings (key, value) VALUES
     ('home_hero_text', 'लो! ले आया दो हाथों में छल-छल करता पैमाना।\nजितना चाहो मांगो पी लो छोड़ो अब यूं शरमाना।')
     ON CONFLICT (key) DO NOTHING`
  );
  await pool.query(
    `INSERT INTO app_settings (key, value) VALUES ('audio_preview_seconds', '120') ON CONFLICT (key) DO NOTHING`
  );
  console.log('✓ App settings');

  console.log('\n✅ Full test data seeded successfully!');
  console.log('\nTest logins (password: ' + TEST_PASSWORD + '):');
  userIds.forEach((u) => console.log('  - ' + u.email));
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seed failed:', err);
    process.exit(1);
  })
  .finally(() => pool.end());
