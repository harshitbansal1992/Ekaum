/**
 * Unified Search Routes
 * GET /api/search?q={term} - Search across Avdhan, Patrika, Samagam, Mantra Notes, Announcements
 */

const express = require('express');
const path = require('path');
const fs = require('fs');
const { pool } = require('../database');
const { DB_TABLES, HTTP_STATUS } = require('../constants');
const { optionalAuthenticateToken } = require('../middleware/auth');

const router = express.Router();

const AVDHAN_AUDIO_DIR = path.resolve(__dirname, '../../../avdhan_audio');
const AUDIO_EXTENSIONS = ['.mp3', '.m4a', '.wav', '.ogg'];

function filenameToTitle(filename) {
  const base = path.basename(filename, path.extname(filename));
  return base
    .split(/[-_\s]+/)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

/**
 * GET /api/search?q={term}&limit=20
 * Optional auth - if authenticated, includes mantra notes
 */
router.get('/', optionalAuthenticateToken, async (req, res, next) => {
  try {
    const q = (req.query.q || '').trim().toLowerCase();
    const limit = Math.min(parseInt(req.query.limit, 10) || 20, 50);
    const results = { avdhan: [], patrika: [], samagam: [], mantraNotes: [], announcements: [], videoSatsang: [] };

    if (q.length === 0) {
      return res.status(HTTP_STATUS.OK).json(results);
    }

    const searchPattern = `%${q.replace(/%/g, '\\%')}%`;

    // Avdhan (from files)
    if (fs.existsSync(AVDHAN_AUDIO_DIR)) {
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      const files = fs.readdirSync(AVDHAN_AUDIO_DIR)
        .filter((f) => AUDIO_EXTENSIONS.includes(path.extname(f).toLowerCase()));
      const avdhanItems = files
        .map((filename) => {
          const title = filenameToTitle(filename);
          const baseName = path.basename(filename, path.extname(filename));
          return {
            id: baseName,
            title,
            description: title,
            audioUrl: `${baseUrl}/api/avdhan/audio/${encodeURIComponent(filename)}`,
            thumbnailUrl: null,
          };
        })
        .filter((a) => a.title.toLowerCase().includes(q))
        .slice(0, limit);
      results.avdhan = avdhanItems;
    }

    // Patrika
    const patrikaResult = await pool.query(
      `SELECT id, title, month, year, pdf_url, cover_image_url, price
       FROM ${DB_TABLES.PATRIKA}
       WHERE LOWER(title) LIKE $1 OR LOWER(month::text) LIKE $1 OR LOWER(year::text) LIKE $1
       ORDER BY year DESC, month DESC
       LIMIT $2`,
      [searchPattern, limit]
    );
    results.patrika = patrikaResult.rows.map((row) => ({
      id: row.id,
      title: row.title,
      month: row.month,
      year: row.year,
      pdfUrl: row.pdf_url,
      coverImageUrl: row.cover_image_url,
      price: parseFloat(row.price),
      publishedDate: row.published_date ? new Date(row.published_date).toISOString() : new Date().toISOString(),
    }));

    // Samagam
    const samagamResult = await pool.query(
      `SELECT id, title, description, start_date, end_date, location, address
       FROM ${DB_TABLES.SAMAGAM}
       WHERE LOWER(title) LIKE $1 OR LOWER(COALESCE(description, '')) LIKE $1 OR LOWER(COALESCE(location, '')) LIKE $1
       ORDER BY start_date DESC
       LIMIT $2`,
      [searchPattern, limit]
    );
    results.samagam = samagamResult.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
      startDate: row.start_date ? new Date(row.start_date).toISOString() : null,
      endDate: row.end_date ? new Date(row.end_date).toISOString() : null,
      location: row.location,
      address: row.address,
    }));

    // Announcements
    const announcementsResult = await pool.query(
      `SELECT id, title, description
       FROM ${DB_TABLES.ANNOUNCEMENTS}
       WHERE LOWER(title) LIKE $1 OR LOWER(COALESCE(description, '')) LIKE $1
       ORDER BY display_order DESC, created_at DESC
       LIMIT $2`,
      [searchPattern, limit]
    );
    results.announcements = announcementsResult.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
    }));

    // Video Satsang
    const videoResult = await pool.query(
      `SELECT id, title, description, youtube_video_id
       FROM ${DB_TABLES.VIDEO_SATSANG}
       WHERE LOWER(title) LIKE $1 OR LOWER(COALESCE(description, '')) LIKE $1
       ORDER BY display_order DESC, created_at DESC
       LIMIT $2`,
      [searchPattern, limit]
    );
    results.videoSatsang = videoResult.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description || '',
      youtubeVideoId: row.youtube_video_id,
    }));

    // Mantra Notes (authenticated users only)
    if (req.user?.userId) {
      const userId = req.user.userId;
          const mantraResult = await pool.query(
            `SELECT id, heading, description
             FROM ${DB_TABLES.MANTRA_NOTES}
             WHERE user_id = $1 AND (LOWER(heading) LIKE $2 OR LOWER(COALESCE(description, '')) LIKE $2)
             ORDER BY updated_at DESC
             LIMIT $3`,
            [userId, searchPattern, limit]
          );
      results.mantraNotes = mantraResult.rows.map((row) => ({
        id: row.id,
        heading: row.heading,
        description: row.description || '',
      }));
    }

    res.status(HTTP_STATUS.OK).json(results);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
