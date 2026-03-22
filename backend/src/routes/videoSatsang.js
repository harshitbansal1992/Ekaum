/**
 * Video Satsang Routes (Mobile App)
 * GET /api/video-satsang - List all video satsang (free YouTube content)
 */

const express = require('express');
const { pool } = require('../database');
const { DB_TABLES } = require('../constants');

const router = express.Router();

/**
 * GET /api/video-satsang
 * List all video satsang ordered by display_order, created_at
 */
router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, title, description, youtube_video_id, thumbnail_url, duration_seconds, display_order, created_at
       FROM ${DB_TABLES.VIDEO_SATSANG}
       ORDER BY display_order DESC, created_at DESC`
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description || '',
      youtubeVideoId: row.youtube_video_id,
      thumbnailUrl: row.thumbnail_url,
      durationSeconds: row.duration_seconds || 0,
      displayOrder: row.display_order || 0,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    })));
  } catch (err) {
    next(err);
  }
});

module.exports = router;
