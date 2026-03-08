const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

// Test database connection
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ PostgreSQL connection error:', err);
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// JWT authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-change-in-production', (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid or expired token' });
    req.user = user;
    next();
  });
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'BSLND Backend API is running', database: 'PostgreSQL' });
});

// ============ AUTHENTICATION ROUTES ============

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Check if user exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const result = await pool.query(
      'INSERT INTO users (email, password_hash, name, phone) VALUES ($1, $2, $3, $4) RETURNING id, email, name, phone, created_at',
      [email, passwordHash, name || null, phone || null]
    );

    const user = result.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key-change-in-production',
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
      },
      token,
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const result = await pool.query(
      'SELECT id, email, password_hash, name, phone FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key-change-in-production',
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
      },
      token,
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get current user
app.get('/api/auth/me', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, name, phone, created_at FROM users WHERE id = $1',
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ USER ROUTES ============

app.get('/api/users/:userId', authenticateToken, async (req, res) => {
  try {
    if (req.params.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await pool.query(
      'SELECT id, email, name, phone, created_at FROM users WHERE id = $1',
      [req.params.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ SUBSCRIPTION ROUTES ============

app.post('/api/subscriptions', authenticateToken, async (req, res) => {
  try {
    const { amount, paymentId } = req.body;
    const userId = req.user.userId;

    const expiryDate = new Date();
    expiryDate.setMonth(expiryDate.getMonth() + 1);

    await pool.query(
      `INSERT INTO subscriptions (user_id, is_active, amount, payment_id, start_date, expiry_date)
       VALUES ($1, true, $2, $3, $4, $5)
       ON CONFLICT (user_id) DO UPDATE SET
         is_active = true,
         amount = $2,
         payment_id = $3,
         start_date = $4,
         expiry_date = $5,
         updated_at = CURRENT_TIMESTAMP`,
      [userId, amount, paymentId, new Date(), expiryDate]
    );

    res.json({ success: true, message: 'Subscription activated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/subscriptions/:userId', authenticateToken, async (req, res) => {
  try {
    if (req.params.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await pool.query(
      'SELECT * FROM subscriptions WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1',
      [req.params.userId]
    );

    if (result.rows.length === 0) {
      return res.json({ isActive: false });
    }

    const subscription = result.rows[0];

    // Check if subscription is still valid
    if (subscription.expiry_date && new Date(subscription.expiry_date) < new Date()) {
      await pool.query(
        'UPDATE subscriptions SET is_active = false WHERE id = $1',
        [subscription.id]
      );
      return res.json({ isActive: false });
    }

    res.json({
      isActive: subscription.is_active,
      amount: subscription.amount,
      paymentId: subscription.payment_id,
      startDate: subscription.start_date,
      expiryDate: subscription.expiry_date,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ AVDHAN ROUTES ============

app.get('/api/avdhan', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, description, audio_url as "audioUrl", thumbnail_url as "thumbnailUrl", duration, created_at as "createdAt" FROM avdhan ORDER BY created_at DESC'
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ SAMAGAM ROUTES ============

app.get('/api/samagam', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, title, description, start_date as "startDate", end_date as "endDate", 
       location, address, image_url as "imageUrl"
       FROM samagam WHERE end_date >= CURRENT_DATE ORDER BY start_date ASC`
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ PATRIKA ROUTES ============

app.get('/api/patrika', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, title, month, year, pdf_url as "pdfUrl", cover_image_url as "coverImageUrl", 
       price, published_date as "publishedDate"
       FROM patrika ORDER BY published_date DESC`
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/patrika/purchases/:userId', authenticateToken, async (req, res) => {
  try {
    if (req.params.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await pool.query(
      'SELECT patrika_id FROM patrika_purchases WHERE user_id = $1',
      [req.params.userId]
    );

    const purchasedIds = result.rows.map(row => row.patrika_id);
    res.json(purchasedIds);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/patrika/purchases', authenticateToken, async (req, res) => {
  try {
    const { patrikaId, amount, paymentId } = req.body;
    const userId = req.user.userId;

    await pool.query(
      'INSERT INTO patrika_purchases (user_id, patrika_id, amount, payment_id) VALUES ($1, $2, $3, $4)',
      [userId, patrikaId, amount, paymentId]
    );

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ PAATH FORMS ROUTES ============

app.post('/api/paath-forms', authenticateToken, async (req, res) => {
  try {
    const {
      serviceId,
      serviceName,
      totalAmount,
      installments,
      installmentAmount,
      name,
      dateOfBirth,
      timeOfBirth,
      placeOfBirth,
      fathersOrHusbandsName,
      gotra,
      caste,
      familyMembers,
    } = req.body;

    const userId = req.user.userId;

    // Insert form
    const formResult = await pool.query(
      `INSERT INTO paath_forms (
        user_id, service_id, service_name, total_amount, installments, installment_amount,
        name, date_of_birth, time_of_birth, place_of_birth,
        fathers_or_husbands_name, gotra, caste
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING id`,
      [
        userId, serviceId, serviceName, totalAmount, installments, installmentAmount,
        name, dateOfBirth, timeOfBirth, placeOfBirth,
        fathersOrHusbandsName, gotra, caste,
      ]
    );

    const formId = formResult.rows[0].id;

    // Insert family members if any
    if (familyMembers && familyMembers.length > 0) {
      for (const member of familyMembers) {
        await pool.query(
          `INSERT INTO paath_form_family_members (
            paath_form_id, name, date_of_birth, time_of_birth, place_of_birth, relationship
          ) VALUES ($1, $2, $3, $4, $5, $6)`,
          [
            formId,
            member.name,
            member.dateOfBirth,
            member.timeOfBirth,
            member.placeOfBirth,
            member.relationship,
          ]
        );
      }
    }

    res.json({ success: true, formId });
  } catch (error) {
    console.error('Paath form error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/paath-forms/:userId', authenticateToken, async (req, res) => {
  try {
    if (req.params.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await pool.query(
      `SELECT f.*, 
       COALESCE(
         json_agg(
           json_build_object(
             'name', m.name,
             'dateOfBirth', m.date_of_birth,
             'timeOfBirth', m.time_of_birth,
             'placeOfBirth', m.place_of_birth,
             'relationship', m.relationship
           )
         ) FILTER (WHERE m.id IS NOT NULL),
         '[]'
       ) as family_members
       FROM paath_forms f
       LEFT JOIN paath_form_family_members m ON f.id = m.paath_form_id
       WHERE f.user_id = $1
       GROUP BY f.id
       ORDER BY f.created_at DESC`,
      [req.params.userId]
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ DONATIONS ROUTES ============

app.post('/api/donations', authenticateToken, async (req, res) => {
  try {
    const { amount } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      'INSERT INTO donations (user_id, amount) VALUES ($1, $2) RETURNING id',
      [userId, amount]
    );

    res.json({ success: true, donationId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/donations/:userId', authenticateToken, async (req, res) => {
  try {
    if (req.params.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await pool.query(
      'SELECT * FROM donations WHERE user_id = $1 ORDER BY created_at DESC',
      [req.params.userId]
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ PAYMENT WEBHOOK ============

app.post('/api/payments/webhook', async (req, res) => {
  try {
    const {
      payment_id,
      payment_request_id,
      payment_status,
      amount,
      buyer_name,
      buyer_email,
      buyer_phone,
    } = req.body;

    // Verify payment with Instamojo
    const instamojoApiKey = process.env.INSTAMOJO_API_KEY;
    const instamojoAuthToken = process.env.INSTAMOJO_AUTH_TOKEN;

    try {
      const verifyResponse = await axios.get(
        `https://www.instamojo.com/api/1.1/payment-requests/${payment_request_id}/`,
        {
          headers: {
            'X-Api-Key': instamojoApiKey,
            'X-Auth-Token': instamojoAuthToken,
          },
        }
      );

      const paymentRequest = verifyResponse.data.payment_request;
      const metadata = paymentRequest.metadata || {};

      if (payment_status === 'Credit') {
        // Save payment record
        await pool.query(
          `INSERT INTO payments (
            user_id, payment_id, payment_request_id, status, amount, type,
            buyer_name, buyer_email, buyer_phone, metadata, completed_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
          [
            metadata.userId,
            payment_id,
            payment_request_id,
            'completed',
            amount,
            metadata.type || 'unknown',
            buyer_name,
            buyer_email,
            buyer_phone,
            JSON.stringify(metadata),
            new Date(),
          ]
        );

        // Handle based on payment type
        const paymentType = metadata.type;
        const userId = metadata.userId;

        if (paymentType === 'subscription' && userId) {
          // Activate subscription
          const expiryDate = new Date();
          expiryDate.setMonth(expiryDate.getMonth() + 1);

          await pool.query(
            `INSERT INTO subscriptions (user_id, is_active, amount, payment_id, start_date, expiry_date)
             VALUES ($1, true, $2, $3, $4, $5)
             ON CONFLICT (user_id) DO UPDATE SET
               is_active = true,
               amount = $2,
               payment_id = $3,
               start_date = $4,
               expiry_date = $5,
               updated_at = CURRENT_TIMESTAMP`,
            [userId, amount, payment_id, new Date(), expiryDate]
          );
        } else if (paymentType === 'patrika' && userId && metadata.issueId) {
          // Record patrika purchase
          await pool.query(
            'INSERT INTO patrika_purchases (user_id, patrika_id, amount, payment_id) VALUES ($1, $2, $3, $4)',
            [userId, metadata.issueId, amount, payment_id]
          );
        } else if (paymentType === 'paath' && userId && metadata.formId) {
          // Record paath payment
          await pool.query(
            `INSERT INTO paath_payments (paath_form_id, installment_number, amount, payment_id, status)
             VALUES ($1, $2, $3, $4, 'completed')
             ON CONFLICT (paath_form_id, installment_number) DO UPDATE SET
               amount = $3,
               payment_id = $4,
               status = 'completed'`,
            [metadata.formId, parseInt(metadata.installmentNumber || '1'), amount, payment_id]
          );

          // Update form payment status
          const formResult = await pool.query(
            'SELECT installments FROM paath_forms WHERE id = $1',
            [metadata.formId]
          );

          if (formResult.rows.length > 0) {
            const totalInstallments = formResult.rows[0].installments;
            const paidResult = await pool.query(
              'SELECT COUNT(*) as paid FROM paath_payments WHERE paath_form_id = $1 AND status = $2',
              [metadata.formId, 'completed']
            );

            const paidInstallments = parseInt(paidResult.rows[0].paid);
            let paymentStatus = 'partial';
            if (paidInstallments >= totalInstallments) {
              paymentStatus = 'completed';
            }

            await pool.query(
              'UPDATE paath_forms SET payment_status = $1 WHERE id = $2',
              [paymentStatus, metadata.formId]
            );
          }
        } else if (paymentType === 'donation' && userId) {
          // Update donation status
          await pool.query(
            `UPDATE donations SET status = 'completed', payment_id = $1, completed_at = $2
             WHERE user_id = $3 AND status = 'pending'
             ORDER BY created_at DESC LIMIT 1`,
            [payment_id, new Date(), userId]
          );
        }
      }
    } catch (verifyError) {
      console.error('Payment verification error:', verifyError);
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============ ADMIN ROUTES ============

app.post('/api/admin/avdhan', authenticateToken, async (req, res) => {
  try {
    const { title, description, audioUrl, thumbnailUrl, duration } = req.body;

    if (!title || !audioUrl) {
      return res.status(400).json({ error: 'Title and audioUrl are required' });
    }

    const result = await pool.query(
      'INSERT INTO avdhan (title, description, audio_url, thumbnail_url, duration) VALUES ($1, $2, $3, $4, $5) RETURNING id',
      [title, description || '', audioUrl, thumbnailUrl || '', duration || 0]
    );

    res.json({ success: true, id: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/samagam', authenticateToken, async (req, res) => {
  try {
    const { title, description, startDate, endDate, location, address, imageUrl } = req.body;

    if (!title || !startDate || !endDate || !location) {
      return res.status(400).json({ error: 'Required fields missing' });
    }

    const result = await pool.query(
      'INSERT INTO samagam (title, description, start_date, end_date, location, address, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id',
      [title, description || '', startDate, endDate, location, address || '', imageUrl || '']
    );

    res.json({ success: true, id: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/patrika', authenticateToken, async (req, res) => {
  try {
    const { title, month, year, pdfUrl, coverImageUrl, price } = req.body;

    if (!title || !month || !year || !pdfUrl || price === undefined) {
      return res.status(400).json({ error: 'Required fields missing' });
    }

    const result = await pool.query(
      'INSERT INTO patrika (title, month, year, pdf_url, cover_image_url, price) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
      [title, month, year, pdfUrl, coverImageUrl || '', price]
    );

    res.json({ success: true, id: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 BSLND Backend API running on port ${PORT}`);
  console.log(`📊 Database: PostgreSQL`);
  console.log(`🔐 JWT Secret: ${process.env.JWT_SECRET ? '✅ Set' : '⚠️  Using default (change in production!)'}`);
});
