/**
 * Admin Routes
 * Back office API - uses same PostgreSQL as main app
 * Per BACK_OFFICE_CONTEXT: No JWT/auth required for now
 */

const express = require('express');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { pool } = require('../database');
const { HTTP_STATUS, DB_TABLES } = require('../constants');
const { invalidate: cacheInvalidate } = require('../utils/cache');

const router = express.Router();

const AVDHAN_AUDIO_DIR = path.resolve(__dirname, '../../../avdhan_audio');
const AUDIO_EXTENSIONS = ['.mp3', '.m4a', '.wav', '.ogg'];

// Multer config for avdhan uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (!fs.existsSync(AVDHAN_AUDIO_DIR)) fs.mkdirSync(AVDHAN_AUDIO_DIR, { recursive: true });
    cb(null, AVDHAN_AUDIO_DIR);
  },
  filename: (req, file, cb) => cb(null, file.originalname),
});
const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    const ext = path.extname(file.originalname || '').toLowerCase();
    if (AUDIO_EXTENSIONS.includes(ext)) cb(null, true);
    else cb(new Error(`Invalid file type. Allowed: ${AUDIO_EXTENSIONS.join(', ')}`));
  },
});

function filenameToTitle(filename) {
  const base = path.basename(filename, path.extname(filename));
  return base
    .split(/[-_\s]+/)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

function toCamel(obj) {
  if (!obj) return obj;
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    const camel = k.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
    out[camel] = v;
  }
  return out;
}

// ===================== AVDHAN =====================

router.get('/avdhan', async (req, res, next) => {
  try {
    if (!fs.existsSync(AVDHAN_AUDIO_DIR)) return res.json([]);
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const files = fs.readdirSync(AVDHAN_AUDIO_DIR)
      .filter((f) => AUDIO_EXTENSIONS.includes(path.extname(f).toLowerCase()))
      .map((filename) => {
        const st = fs.statSync(path.join(AVDHAN_AUDIO_DIR, filename));
        return {
          id: path.basename(filename, path.extname(filename)),
          title: filenameToTitle(filename),
          filename,
          audioUrl: `${baseUrl}/api/avdhan/audio/${encodeURIComponent(filename)}`,
          createdAt: st.mtime.toISOString(),
        };
      })
      .sort((a, b) => a.title.localeCompare(b.title));
    res.json(files);
  } catch (err) { next(err); }
});

router.post('/avdhan', upload.single('file'), (req, res, next) => {
  if (!req.file) return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'No file provided' });
  cacheInvalidate('avdhan');
  res.json({ success: true, filename: req.file.originalname });
});

router.delete('/avdhan/:filename', (req, res, next) => {
  try {
    const { filename } = req.params;
    const decoded = decodeURIComponent(filename);
    if (decoded.includes('..') || path.isAbsolute(decoded))
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'Invalid filename' });
    const filePath = path.join(AVDHAN_AUDIO_DIR, decoded);
    if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile())
      return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'File not found' });
    fs.unlinkSync(filePath);
    cacheInvalidate('avdhan');
    res.json({ success: true });
  } catch (err) { next(err); }
});

// ===================== PAATH SERVICES =====================

router.get('/paath-services', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT * FROM ${DB_TABLES.PAATH_SERVICES} ORDER BY display_order ASC, name ASC`
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        name: row.name,
        description: row.description || '',
        price: parseFloat(row.price),
        isFamilyService: !!row.is_family_service,
        installments: parseInt(row.installments, 10) || 6,
        displayOrder: row.display_order,
        isActive: !!row.is_active,
        createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
        updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
      }))
    );
  } catch (err) {
    next(err);
  }
});

router.get('/paath-services/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT * FROM ${DB_TABLES.PAATH_SERVICES} WHERE id = $1`,
      [req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Paath service not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      name: row.name,
      description: row.description || '',
      price: parseFloat(row.price),
      isFamilyService: !!row.is_family_service,
      installments: parseInt(row.installments, 10) || 6,
      displayOrder: row.display_order,
      isActive: !!row.is_active,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) {
    next(err);
  }
});

router.post('/paath-services', async (req, res, next) => {
  try {
    const { id, name, description, price, isFamilyService, installments, displayOrder, isActive } = req.body;
    if (!id || !name || price === undefined) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'id, name, and price are required' });
    }
    const inst = Math.min(12, Math.max(1, parseInt(installments, 10) || 6));
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.PAATH_SERVICES} (id, name, description, price, is_family_service, installments, display_order, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        String(id).trim().toLowerCase().replace(/\s+/g, '_'),
        String(name).trim(),
        description != null ? String(description) : '',
        parseFloat(price),
        !!isFamilyService,
        inst,
        displayOrder != null ? parseInt(displayOrder, 10) : 0,
        isActive !== false,
      ]
    );
    const row = r.rows[0];
    cacheInvalidate('paath-services');
    res.status(HTTP_STATUS.CREATED).json({
      id: row.id,
      name: row.name,
      description: row.description || '',
      price: parseFloat(row.price),
      isFamilyService: !!row.is_family_service,
      installments: parseInt(row.installments, 10) || 6,
      displayOrder: row.display_order,
      isActive: !!row.is_active,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(HTTP_STATUS.CONFLICT).json({ error: 'A paath service with this id already exists' });
    }
    next(err);
  }
});

router.put('/paath-services/:id', async (req, res, next) => {
  try {
    const { name, description, price, isFamilyService, installments, displayOrder, isActive } = req.body;
    const inst = installments !== undefined ? Math.min(12, Math.max(1, parseInt(installments, 10) || 6)) : null;
    const r = await pool.query(
      `UPDATE ${DB_TABLES.PAATH_SERVICES}
       SET name = COALESCE($2, name),
           description = COALESCE($3, description),
           price = COALESCE($4, price),
           is_family_service = COALESCE($5, is_family_service),
           installments = COALESCE($6, installments),
           display_order = COALESCE($7, display_order),
           is_active = COALESCE($8, is_active),
           updated_at = NOW()
       WHERE id = $1
       RETURNING *`,
      [
        req.params.id,
        name != null ? String(name).trim() : null,
        description !== undefined ? String(description) : null,
        price !== undefined ? parseFloat(price) : null,
        isFamilyService !== undefined ? !!isFamilyService : null,
        inst,
        displayOrder !== undefined ? parseInt(displayOrder, 10) : null,
        isActive !== undefined ? !!isActive : null,
      ]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Paath service not found' });
    const row = r.rows[0];
    cacheInvalidate('paath-services');
    res.json({
      id: row.id,
      name: row.name,
      description: row.description || '',
      price: parseFloat(row.price),
      isFamilyService: !!row.is_family_service,
      installments: parseInt(row.installments, 10) || 6,
      displayOrder: row.display_order,
      isActive: !!row.is_active,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) {
    next(err);
  }
});

router.delete('/paath-services/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `DELETE FROM ${DB_TABLES.PAATH_SERVICES} WHERE id = $1 RETURNING id`,
      [req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Paath service not found' });
    cacheInvalidate('paath-services');
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// ===================== SAMAGAM =====================

router.get('/samagam', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, title, description, start_date, end_date, location, address, image_url, google_maps_url, created_at
       FROM ${DB_TABLES.SAMAGAM} ORDER BY start_date DESC`
    );
    res.json(r.rows.map((row) => ({
      ...toCamel(row),
      startDate: row.start_date ? new Date(row.start_date).toISOString() : null,
      endDate: row.end_date ? new Date(row.end_date).toISOString() : null,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      googleMapsUrl: row.google_maps_url,
    })));
  } catch (err) { next(err); }
});

router.post('/samagam', async (req, res, next) => {
  try {
    const { title, description, startDate, endDate, location, address, imageUrl, googleMapsUrl } = req.body;
    if (!title || !startDate || !endDate || !location)
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title, startDate, endDate, location required' });
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.SAMAGAM} (title, description, start_date, end_date, location, address, image_url, google_maps_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [title, description || null, startDate, endDate, location, address || null, imageUrl || null, googleMapsUrl || null]
    );
    const row = r.rows[0];
    cacheInvalidate('samagam');
    res.status(HTTP_STATUS.CREATED).json({
      id: row.id,
      title: row.title,
      description: row.description,
      startDate: row.start_date ? new Date(row.start_date).toISOString() : null,
      endDate: row.end_date ? new Date(row.end_date).toISOString() : null,
      location: row.location,
      address: row.address,
      imageUrl: row.image_url,
      googleMapsUrl: row.google_maps_url,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.get('/samagam/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT * FROM ${DB_TABLES.SAMAGAM} WHERE id = $1`,
      [req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Samagam not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      title: row.title,
      description: row.description,
      startDate: row.start_date ? new Date(row.start_date).toISOString() : null,
      endDate: row.end_date ? new Date(row.end_date).toISOString() : null,
      location: row.location,
      address: row.address,
      imageUrl: row.image_url,
      googleMapsUrl: row.google_maps_url,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.put('/samagam/:id', async (req, res, next) => {
  try {
    const { title, description, startDate, endDate, location, address, imageUrl, googleMapsUrl } = req.body;
    if (!title || !startDate || !endDate || !location)
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title, startDate, endDate, location required' });
    const r = await pool.query(
      `UPDATE ${DB_TABLES.SAMAGAM} SET title=$1, description=$2, start_date=$3, end_date=$4, location=$5, address=$6, image_url=$7, google_maps_url=$8
       WHERE id=$9 RETURNING *`,
      [title, description || null, startDate, endDate, location, address || null, imageUrl || null, googleMapsUrl || null, req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Samagam not found' });
    const row = r.rows[0];
    cacheInvalidate('samagam');
    res.json({
      id: row.id,
      title: row.title,
      description: row.description,
      startDate: row.start_date ? new Date(row.start_date).toISOString() : null,
      endDate: row.end_date ? new Date(row.end_date).toISOString() : null,
      location: row.location,
      address: row.address,
      imageUrl: row.image_url,
      googleMapsUrl: row.google_maps_url,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.delete('/samagam/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`DELETE FROM ${DB_TABLES.SAMAGAM} WHERE id=$1 RETURNING id`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Samagam not found' });
    cacheInvalidate('samagam');
    res.json({ success: true });
  } catch (err) { next(err); }
});

// ===================== ANNOUNCEMENTS (VISHESH SANDESH) =====================

router.get('/announcements', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, title, description, display_order, created_at, updated_at
       FROM ${DB_TABLES.ANNOUNCEMENTS}
       ORDER BY display_order DESC, created_at DESC`
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
      displayOrder: row.display_order,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    })));
  } catch (err) { next(err); }
});

router.post('/announcements', async (req, res, next) => {
  try {
    const { title, description, displayOrder } = req.body;
    if (!title || !description) return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title and description required' });
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.ANNOUNCEMENTS} (title, description, display_order)
       VALUES ($1, $2, $3) RETURNING *`,
      [title, description, displayOrder != null ? parseInt(displayOrder, 10) : 0]
    );
    const row = r.rows[0];
    res.status(HTTP_STATUS.CREATED).json({
      id: row.id,
      title: row.title,
      description: row.description,
      displayOrder: row.display_order,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.get('/announcements/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`SELECT * FROM ${DB_TABLES.ANNOUNCEMENTS} WHERE id = $1`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Announcement not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      title: row.title,
      description: row.description,
      displayOrder: row.display_order,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.put('/announcements/:id', async (req, res, next) => {
  try {
    const { title, description, displayOrder } = req.body;
    if (!title || !description) return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title and description required' });
    const r = await pool.query(
      `UPDATE ${DB_TABLES.ANNOUNCEMENTS} SET title=$1, description=$2, display_order=$3, updated_at=NOW()
       WHERE id=$4 RETURNING *`,
      [title, description, displayOrder != null ? parseInt(displayOrder, 10) : 0, req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Announcement not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      title: row.title,
      description: row.description,
      displayOrder: row.display_order,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.delete('/announcements/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`DELETE FROM ${DB_TABLES.ANNOUNCEMENTS} WHERE id=$1 RETURNING id`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Announcement not found' });
    res.json({ success: true });
  } catch (err) { next(err); }
});

// ===================== VIDEO SATSANG =====================

router.get('/video-satsang', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT * FROM ${DB_TABLES.VIDEO_SATSANG} ORDER BY display_order DESC, created_at DESC`
    );
    res.json(r.rows.map(toCamel));
  } catch (err) { next(err); }
});

router.post('/video-satsang', async (req, res, next) => {
  try {
    const { title, description, youtubeVideoId, thumbnailUrl, durationSeconds, displayOrder } = req.body;
    if (!title || !youtubeVideoId) return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title, youtubeVideoId required' });
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.VIDEO_SATSANG} (title, description, youtube_video_id, thumbnail_url, duration_seconds, display_order)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [title || '', description || '', youtubeVideoId, thumbnailUrl || null, durationSeconds || 0, displayOrder || 0]
    );
    res.status(HTTP_STATUS.CREATED).json(toCamel(r.rows[0]));
  } catch (err) { next(err); }
});

router.get('/video-satsang/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`SELECT * FROM ${DB_TABLES.VIDEO_SATSANG} WHERE id = $1`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Video not found' });
    res.json(toCamel(r.rows[0]));
  } catch (err) { next(err); }
});

router.put('/video-satsang/:id', async (req, res, next) => {
  try {
    const { title, description, youtubeVideoId, thumbnailUrl, durationSeconds, displayOrder } = req.body;
    const r = await pool.query(
      `UPDATE ${DB_TABLES.VIDEO_SATSANG}
       SET title=COALESCE($2, title), description=COALESCE($3, description), youtube_video_id=COALESCE($4, youtube_video_id),
           thumbnail_url=COALESCE($5, thumbnail_url), duration_seconds=COALESCE($6, duration_seconds),
           display_order=COALESCE($7, display_order), updated_at=NOW()
       WHERE id=$1 RETURNING *`,
      [req.params.id, title, description, youtubeVideoId, thumbnailUrl, durationSeconds, displayOrder]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Video not found' });
    res.json(toCamel(r.rows[0]));
  } catch (err) { next(err); }
});

router.delete('/video-satsang/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`DELETE FROM ${DB_TABLES.VIDEO_SATSANG} WHERE id=$1 RETURNING id`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Video not found' });
    res.json({ success: true });
  } catch (err) { next(err); }
});

// ===================== PATRIKA =====================

router.get('/patrika', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT * FROM ${DB_TABLES.PATRIKA} ORDER BY year DESC, month DESC`
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      title: row.title,
      month: row.month,
      year: row.year,
      pdfUrl: row.pdf_url,
      coverImageUrl: row.cover_image_url,
      price: parseFloat(row.price),
      publishedDate: row.published_date ? new Date(row.published_date).toISOString() : null,
    })));
  } catch (err) { next(err); }
});

router.post('/patrika', async (req, res, next) => {
  try {
    const { title, month, year, pdfUrl, coverImageUrl, price } = req.body;
    if (!title || !month || year == null || !pdfUrl || price == null)
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title, month, year, pdfUrl, price required' });
    const r = await pool.query(
      `INSERT INTO ${DB_TABLES.PATRIKA} (title, month, year, pdf_url, cover_image_url, price)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [title, month, year, pdfUrl, coverImageUrl || null, price]
    );
    const row = r.rows[0];
    res.status(HTTP_STATUS.CREATED).json({
      id: row.id,
      title: row.title,
      month: row.month,
      year: row.year,
      pdfUrl: row.pdf_url,
      coverImageUrl: row.cover_image_url,
      price: parseFloat(row.price),
      publishedDate: row.published_date ? new Date(row.published_date).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.get('/patrika/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`SELECT * FROM ${DB_TABLES.PATRIKA} WHERE id = $1`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Patrika not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      title: row.title,
      month: row.month,
      year: row.year,
      pdfUrl: row.pdf_url,
      coverImageUrl: row.cover_image_url,
      price: parseFloat(row.price),
      publishedDate: row.published_date ? new Date(row.published_date).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.put('/patrika/:id', async (req, res, next) => {
  try {
    const { title, month, year, pdfUrl, coverImageUrl, price } = req.body;
    if (!title || !month || year == null || !pdfUrl || price == null)
      return res.status(HTTP_STATUS.BAD_REQUEST).json({ error: 'title, month, year, pdfUrl, price required' });
    const r = await pool.query(
      `UPDATE ${DB_TABLES.PATRIKA} SET title=$1, month=$2, year=$3, pdf_url=$4, cover_image_url=$5, price=$6
       WHERE id=$7 RETURNING *`,
      [title, month, year, pdfUrl, coverImageUrl || null, price, req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Patrika not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      title: row.title,
      month: row.month,
      year: row.year,
      pdfUrl: row.pdf_url,
      coverImageUrl: row.cover_image_url,
      price: parseFloat(row.price),
      publishedDate: row.published_date ? new Date(row.published_date).toISOString() : null,
    });
  } catch (err) { next(err); }
});

router.delete('/patrika/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`DELETE FROM ${DB_TABLES.PATRIKA} WHERE id=$1 RETURNING id`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Patrika not found' });
    res.json({ success: true });
  } catch (err) { next(err); }
});

// ===================== PATRIKA PURCHASES =====================

router.get('/patrika-purchases', async (req, res, next) => {
  try {
    const { userId, patrikaId } = req.query;
    let sql = `
      SELECT pp.*, u.name as user_name, u.email as user_email, p.title as patrika_title
      FROM ${DB_TABLES.PATRIKA_PURCHASES} pp
      LEFT JOIN ${DB_TABLES.USERS} u ON pp.user_id = u.id
      LEFT JOIN ${DB_TABLES.PATRIKA} p ON pp.patrika_id = p.id
      ORDER BY pp.purchase_date DESC
    `;
    const params = [];
    const where = [];
    if (userId) { params.push(userId); where.push(`pp.user_id = $${params.length}`); }
    if (patrikaId) { params.push(patrikaId); where.push(`pp.patrika_id = $${params.length}`); }
    if (where.length) sql = sql.replace('ORDER BY', `WHERE ${where.join(' AND ')} ORDER BY`);
    const r = await pool.query(sql, params);
    res.json(r.rows.map((row) => ({
      id: row.id,
      userId: row.user_id,
      patrikaId: row.patrika_id,
      purchaseDate: row.purchase_date ? new Date(row.purchase_date).toISOString() : null,
      amount: row.amount ? parseFloat(row.amount) : null,
      paymentId: row.payment_id,
      userName: row.user_name,
      userEmail: row.user_email,
      patrikaTitle: row.patrika_title,
    })));
  } catch (err) { next(err); }
});

// ===================== PAATH FORMS =====================

router.get('/paath-forms', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT pf.*, u.name as user_name, u.email as user_email
       FROM ${DB_TABLES.PAATH_FORMS} pf
       LEFT JOIN ${DB_TABLES.USERS} u ON pf.user_id = u.id
       ORDER BY pf.created_at DESC`
    );
    res.json(r.rows.map((row) => ({
      id: row.id,
      userId: row.user_id,
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
      paathDoneDate: row.paath_done_date,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
      userName: row.user_name,
      userEmail: row.user_email,
    })));
  } catch (err) { next(err); }
});

router.get('/paath-forms/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT pf.*, u.name as user_name, u.email as user_email
       FROM ${DB_TABLES.PAATH_FORMS} pf
       LEFT JOIN ${DB_TABLES.USERS} u ON pf.user_id = u.id
       WHERE pf.id = $1`,
      [req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Paath form not found' });
    const row = r.rows[0];
    const fm = await pool.query(
      `SELECT * FROM ${DB_TABLES.PAATH_FORM_FAMILY_MEMBERS} WHERE paath_form_id = $1`,
      [req.params.id]
    );
    const inst = await pool.query(
      `SELECT installment_number, amount, status, payment_id, payment_date
       FROM ${DB_TABLES.PAATH_PAYMENTS} WHERE paath_form_id = $1 ORDER BY installment_number ASC`,
      [req.params.id]
    );
    res.json({
      id: row.id,
      userId: row.user_id,
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
      paathDoneDate: row.paath_done_date,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
      userName: row.user_name,
      userEmail: row.user_email,
      familyMembers: fm.rows.map((m) => ({
        id: m.id,
        paathFormId: m.paath_form_id,
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
  } catch (err) { next(err); }
});

router.patch('/paath-forms/:id', async (req, res, next) => {
  try {
    const { paathStatus, paathDoneDate } = req.body;
    const status = paathStatus || 'pending';
    const doneDate =
      paathDoneDate && typeof paathDoneDate === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(paathDoneDate.trim())
        ? paathDoneDate.trim()
        : null;

    const r = await pool.query(
      `UPDATE ${DB_TABLES.PAATH_FORMS}
       SET paath_status = $1, paath_done_date = $2, updated_at = NOW()
       WHERE id = $3
       RETURNING id`,
      [status, doneDate, req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'Paath form not found' });
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// ===================== DONATION SUBSCRIPTIONS =====================

router.get('/donation-subscriptions', async (req, res, next) => {
  try {
    const { userId, status } = req.query;
    let sql = `
      SELECT ds.*, u.name as user_name, u.email as user_email
      FROM ${DB_TABLES.DONATION_SUBSCRIPTIONS} ds
      LEFT JOIN ${DB_TABLES.USERS} u ON ds.user_id = u.id
      ORDER BY ds.created_at DESC
    `;
    const params = [];
    const where = [];
    if (userId) { params.push(userId); where.push(`ds.user_id = $${params.length}`); }
    if (status) { params.push(status); where.push(`ds.status = $${params.length}`); }
    if (where.length) sql = sql.replace('ORDER BY', `WHERE ${where.join(' AND ')} ORDER BY`);
    const r = await pool.query(sql, params);
    res.json(r.rows.map((row) => ({
      id: row.id,
      userId: row.user_id,
      amount: row.amount ? parseFloat(row.amount) : null,
      frequency: row.frequency,
      status: row.status,
      razorpaySubscriptionId: row.razorpay_subscription_id,
      nextBillingDate: row.next_billing_date ? row.next_billing_date.toISOString().slice(0, 10) : null,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
      userName: row.user_name,
      userEmail: row.user_email,
    })));
  } catch (err) { next(err); }
});

// ===================== DONATIONS =====================

router.get('/donations', async (req, res, next) => {
  try {
    const { userId, status } = req.query;
    let sql = `
      SELECT d.*, u.name as user_name, u.email as user_email
      FROM ${DB_TABLES.DONATIONS} d
      LEFT JOIN ${DB_TABLES.USERS} u ON d.user_id = u.id
      ORDER BY d.created_at DESC
    `;
    const params = [];
    const where = [];
    if (userId) { params.push(userId); where.push(`d.user_id = $${params.length}`); }
    if (status) { params.push(status); where.push(`d.status = $${params.length}`); }
    if (where.length) sql = sql.replace('ORDER BY', `WHERE ${where.join(' AND ')} ORDER BY`);
    const r = await pool.query(sql, params);
    res.json(r.rows.map((row) => ({
      id: row.id,
      userId: row.user_id,
      amount: row.amount ? parseFloat(row.amount) : null,
      status: row.status,
      paymentId: row.payment_id,
      createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
      completedAt: row.completed_at ? new Date(row.completed_at).toISOString() : null,
      userName: row.user_name,
      userEmail: row.user_email,
    })));
  } catch (err) { next(err); }
});

// ===================== USERS =====================

const USER_SELECT = 'id, email, name, phone, date_of_birth, time_of_birth, place_of_birth, fathers_or_husbands_name, gotra, caste, created_at, updated_at';

function toUserJson(row) {
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    phone: row.phone,
    dateOfBirth: row.date_of_birth ? row.date_of_birth.toISOString().slice(0, 10) : null,
    timeOfBirth: row.time_of_birth,
    placeOfBirth: row.place_of_birth,
    fathersOrHusbandsName: row.fathers_or_husbands_name,
    gotra: row.gotra,
    caste: row.caste,
    createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
  };
}

router.get('/users', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT ${USER_SELECT} FROM ${DB_TABLES.USERS} ORDER BY created_at DESC`
    );
    res.json(r.rows.map(toUserJson));
  } catch (err) { next(err); }
});

router.get('/users/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT ${USER_SELECT} FROM ${DB_TABLES.USERS} WHERE id = $1`,
      [req.params.id]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'User not found' });
    res.json(toUserJson(r.rows[0]));
  } catch (err) { next(err); }
});

router.patch('/users/:id', async (req, res, next) => {
  try {
    const { name, phone, dateOfBirth, timeOfBirth, placeOfBirth, fathersOrHusbandsName, gotra, caste } = req.body;
    const r = await pool.query(
      `UPDATE ${DB_TABLES.USERS}
       SET name = COALESCE($2, name),
           phone = COALESCE($3, phone),
           date_of_birth = COALESCE($4, date_of_birth),
           time_of_birth = COALESCE($5, time_of_birth),
           place_of_birth = COALESCE($6, place_of_birth),
           fathers_or_husbands_name = COALESCE($7, fathers_or_husbands_name),
           gotra = COALESCE($8, gotra),
           caste = COALESCE($9, caste),
           updated_at = NOW()
       WHERE id = $1
       RETURNING ${USER_SELECT}`,
      [
        req.params.id,
        name != null ? String(name).trim() : null,
        phone != null ? String(phone).trim() : null,
        dateOfBirth || null,
        timeOfBirth || null,
        placeOfBirth || null,
        fathersOrHusbandsName || null,
        gotra || null,
        caste || null,
      ]
    );
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'User not found' });
    res.json(toUserJson(r.rows[0]));
  } catch (err) { next(err); }
});

router.delete('/users/:id', async (req, res, next) => {
  try {
    const r = await pool.query(`DELETE FROM ${DB_TABLES.USERS} WHERE id=$1 RETURNING id`, [req.params.id]);
    if (r.rows.length === 0) return res.status(HTTP_STATUS.NOT_FOUND).json({ error: 'User not found' });
    res.json({ success: true });
  } catch (err) { next(err); }
});

// ===================== DASHBOARD =====================

router.get('/dashboard/stats', async (req, res, next) => {
  try {
    const users = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.USERS}`);
    const samagam = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.SAMAGAM}`);
    const patrika = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.PATRIKA}`);
    const pendingPaath = await pool.query(
      `SELECT COUNT(*) FROM ${DB_TABLES.PAATH_FORMS} WHERE COALESCE(paath_status, 'pending') != 'done'`
    );
    const completedPaath = await pool.query(
      `SELECT COUNT(*) FROM ${DB_TABLES.PAATH_FORMS} WHERE paath_status = 'done'`
    );
    const donations = await pool.query(
      `SELECT COALESCE(SUM(amount::numeric), 0) FROM ${DB_TABLES.DONATIONS} WHERE status = 'completed'`
    );
    const patrikaPurchases = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.PATRIKA_PURCHASES}`);
    const paathServices = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.PAATH_SERVICES}`);
    const announcements = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.ANNOUNCEMENTS}`);
    const videoSatsang = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.VIDEO_SATSANG}`);
    const donationSubscriptions = await pool.query(`SELECT COUNT(*) FROM ${DB_TABLES.DONATION_SUBSCRIPTIONS}`);

    let totalAvdhan = 0;
    if (fs.existsSync(AVDHAN_AUDIO_DIR)) {
      totalAvdhan = fs.readdirSync(AVDHAN_AUDIO_DIR)
        .filter((f) => AUDIO_EXTENSIONS.includes(path.extname(f).toLowerCase())).length;
    }

    res.json({
      totalUsers: parseInt(users.rows[0].count, 10),
      totalSamagam: parseInt(samagam.rows[0].count, 10),
      totalPatrika: parseInt(patrika.rows[0].count, 10),
      pendingPaath: parseInt(pendingPaath.rows[0].count, 10),
      completedPaath: parseInt(completedPaath.rows[0].count, 10),
      totalDonations: parseFloat(donations.rows[0].coalesce || 0),
      totalPatrikaPurchases: parseInt(patrikaPurchases.rows[0].count, 10),
      totalPaathServices: parseInt(paathServices.rows[0].count, 10),
      totalAnnouncements: parseInt(announcements.rows[0].count, 10),
      totalVideoSatsang: parseInt(videoSatsang.rows[0].count, 10),
      totalDonationSubscriptions: parseInt(donationSubscriptions.rows[0].count, 10),
      totalAvdhan,
    });
  } catch (err) { next(err); }
});

module.exports = router;
