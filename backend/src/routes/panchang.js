/**
 * Panchang (Hindu Calendar) Routes
 * Proxies to Kaalchakra API (free tier: unlimited current-day requests)
 * Get API key at https://kaalchakra.dev/signup
 */

const express = require('express');
const https = require('https');

const router = express.Router();

const KAALCHAKRA_BASE = 'https://api.kaalchakra.dev/v1';

/**
 * GET /api/panchang/current-day
 * Returns today's Hindu panchang. Public, no auth required.
 * Requires KAALCHAKRA_API_KEY in env. If missing, returns 503.
 */
router.get('/current-day', async (req, res, next) => {
  const apiKey = process.env.KAALCHAKRA_API_KEY;
  if (!apiKey || apiKey.trim() === '') {
    return res.status(503).json({
      error: 'Hindu calendar service is not configured. Add KAALCHAKRA_API_KEY to enable.',
    });
  }

  try {
    const timeZone = req.query.timezone || 'Asia/Kolkata';
    const language = req.query.language || ''; // empty = romanized Sanskrit (free tier)
    const url = `${KAALCHAKRA_BASE}/panchang/current_day?auth=${encodeURIComponent(apiKey)}&time_zone=${encodeURIComponent(timeZone)}${language ? `&language=${encodeURIComponent(language)}` : ''}`;

    const data = await new Promise((resolve, reject) => {
      https.get(url, (resp) => {
        let body = '';
        resp.on('data', (chunk) => { body += chunk; });
        resp.on('end', () => {
          if (resp.statusCode !== 200) {
            try {
              const err = JSON.parse(body);
              reject(new Error(err.error || `Kaalchakra API ${resp.statusCode}`));
            } catch {
              reject(new Error(`Kaalchakra API error: ${resp.statusCode}`));
            }
            return;
          }
          try {
            resolve(JSON.parse(body));
          } catch (e) {
            reject(new Error('Invalid JSON from panchang API'));
          }
        });
      }).on('error', reject);
    });

    res.json(data);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
