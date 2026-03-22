#!/usr/bin/env node
/**
 * Run pending migrations
 * Usage: node scripts/run-migrations.js
 * Or: npm run migrate
 */

const path = require('path');
const fs = require('fs');

require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
require('dotenv').config({ path: path.resolve(__dirname, '../.env.development') });

const { pool } = require('../src/database');

const MIGRATIONS_DIR = path.resolve(__dirname, '../migrations');

async function run() {
  const files = fs.readdirSync(MIGRATIONS_DIR).filter((f) => f.endsWith('.sql')).sort();
  console.log(`Found ${files.length} migration(s)`);

  for (const file of files) {
    const sqlPath = path.join(MIGRATIONS_DIR, file);
    const sql = fs.readFileSync(sqlPath, 'utf8');
    console.log(`Running ${file}...`);
    try {
      await pool.query(sql);
      console.log(`  ✓ ${file}`);
    } catch (err) {
      if (err.message && err.message.includes('already exists')) {
        console.log(`  - ${file} (already applied)`);
      } else {
        console.error(`  ✗ ${file} failed:`, err.message);
        throw err;
      }
    }
  }

  console.log('Migrations complete.');
}

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => pool.end());
