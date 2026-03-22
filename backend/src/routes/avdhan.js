/**
 * Avdhan Routes
 * Lists audio files from avdhan_audio/ folder and serves them
 */

const express = require('express');
const path = require('path');
const fs = require('fs');
const { HTTP_STATUS } = require('../constants');
const { get: cacheGet, set: cacheSet } = require('../utils/cache');

const router = express.Router();
const CACHE_KEY = 'avdhan:list';
const CACHE_TTL = 300; // 5 min

// Path to avdhan_audio folder (project_root/avdhan_audio)
const AVDHAN_AUDIO_DIR = path.resolve(__dirname, '../../../avdhan_audio');

const AUDIO_EXTENSIONS = ['.mp3', '.m4a', '.wav', '.ogg'];

/**
 * Get a human-friendly title from filename (e.g. "mykhanaji-avdhan.mp3" -> "Mykhanaji Avdhan")
 */
function filenameToTitle(filename) {
  const base = path.basename(filename, path.extname(filename));
  return base
    .split(/[-_\s]+/)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

/**
 * GET /api/avdhan
 * List all audio files from avdhan_audio/ folder
 */
router.get('/', async (req, res, next) => {
  try {
    const cached = cacheGet(CACHE_KEY);
    if (cached !== undefined) {
      return res.status(HTTP_STATUS.OK).json(cached);
    }

    if (!fs.existsSync(AVDHAN_AUDIO_DIR)) {
      return res.status(HTTP_STATUS.OK).json([]);
    }

    const files = fs.readdirSync(AVDHAN_AUDIO_DIR);
    const baseUrl = `${req.protocol}://${req.get('host')}`;

    const audios = files
      .filter((f) => AUDIO_EXTENSIONS.includes(path.extname(f).toLowerCase()))
      .map((filename) => {
        const ext = path.extname(filename);
        const baseName = path.basename(filename, ext);
        const title = filenameToTitle(filename);
        const audioUrl = `${baseUrl}/api/avdhan/audio/${encodeURIComponent(filename)}`;

        return {
          id: baseName,
          title,
          description: title,
          audioUrl,
          thumbnailUrl: null,
          createdAt: new Date().toISOString(),
          duration: 0,
        };
      })
      .sort((a, b) => a.title.localeCompare(b.title));

    cacheSet(CACHE_KEY, audios, CACHE_TTL);
    res.status(HTTP_STATUS.OK).json(audios);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/avdhan/audio/:filename
 * Serve the actual audio file
 */
router.get('/audio/:filename', (req, res, next) => {
  try {
    const { filename } = req.params;
    const decodedFilename = decodeURIComponent(filename);

    // Security: prevent path traversal
    if (decodedFilename.includes('..') || path.isAbsolute(decodedFilename)) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'Invalid filename' });
    }

    if (!AUDIO_EXTENSIONS.includes(path.extname(decodedFilename).toLowerCase())) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'Invalid audio file type' });
    }

    const filePath = path.join(AVDHAN_AUDIO_DIR, decodedFilename);

    if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Audio file not found' });
    }

    res.setHeader('Content-Type', 'audio/mpeg');
    res.setHeader('Accept-Ranges', 'bytes');
    res.sendFile(filePath);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
