#!/usr/bin/env node
/**
 * Seed dummy paath forms for testing
 * Run: node scripts/seed-dummy-paath-forms.js
 * Or: npm run seed:paath-forms
 *
 * Prerequisite: At least one user must exist (register in the app first).
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
require('dotenv').config({ path: path.resolve(__dirname, '../.env.development') });

const fs = require('fs');
const { pool } = require('../src/database');

const sqlPath = path.resolve(__dirname, '../migrations/005_seed_dummy_paath_forms.sql');
const sql = fs.readFileSync(sqlPath, 'utf8');

async function run() {
  try {
    await pool.query(sql);
    console.log('✅ Dummy paath forms created successfully.');
    console.log('   - 1 SINGLE form (Vishesh Kripa Samadhan, 6 installments)');
    console.log('   - 1 FAMILY form (Durga Saptashti Paath Family, 6 installments, 3 family members)');
    console.log('   Forms are linked to the first user in your database.');
  } catch (err) {
    if (err.message?.includes('No users found')) {
      console.error('❌ No users in database. Register in the app first, then run this script again.');
    } else {
      console.error('❌ Error:', err.message);
    }
    process.exit(1);
  } finally {
    await pool.end();
  }
}

run();
