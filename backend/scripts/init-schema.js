#!/usr/bin/env node
/**
 * Initialize database with base schema
 * Run this before migrations on a fresh database
 * Usage: node scripts/init-schema.js
 * Or: npm run schema:init
 */

const path = require('path');
const fs = require('fs');

require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
require('dotenv').config({ path: path.resolve(__dirname, '../.env.development') });

const { pool } = require('../src/database');

const SCHEMA_PATH = path.resolve(__dirname, '../schema.sql');

async function run() {
  const sql = fs.readFileSync(SCHEMA_PATH, 'utf8');
  console.log('Running base schema...');
  try {
    await pool.query(sql);
    console.log('Base schema applied successfully.');
  } catch (err) {
    console.error('Schema init failed:', err.message);
    throw err;
  }
}

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => pool.end());
