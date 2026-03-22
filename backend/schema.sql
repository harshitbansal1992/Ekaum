-- BSLND PostgreSQL Database Schema
-- Run this SQL script to create all tables

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    time_of_birth VARCHAR(10),
    place_of_birth VARCHAR(255),
    fathers_or_husbands_name VARCHAR(255),
    gotra VARCHAR(100),
    caste VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT false,
    amount DECIMAL(10, 2),
    payment_id VARCHAR(255),
    start_date TIMESTAMP,
    expiry_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Avdhan audio content
CREATE TABLE IF NOT EXISTS avdhan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    audio_url TEXT NOT NULL,
    thumbnail_url TEXT,
    duration INTEGER DEFAULT 0, -- in seconds
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Samagam events
CREATE TABLE IF NOT EXISTS samagam (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    location VARCHAR(255) NOT NULL,
    address TEXT,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Paath services catalog (dynamic, managed from back office)
-- installments: 1 = one-time payment, 2-12 = that many installments
CREATE TABLE IF NOT EXISTS paath_services (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    price DECIMAL(10, 2) NOT NULL,
    is_family_service BOOLEAN DEFAULT false,
    installments INTEGER DEFAULT 6,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_paath_services_display_order ON paath_services(display_order);

-- Patrika issues
CREATE TABLE IF NOT EXISTS patrika (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    month VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    pdf_url TEXT NOT NULL,
    cover_image_url TEXT,
    price DECIMAL(10, 2) NOT NULL,
    published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Mantra notes (user-stored mantras)
CREATE TABLE IF NOT EXISTS mantra_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    heading VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_mantra_notes_user_id ON mantra_notes(user_id);

-- Patrika purchases
CREATE TABLE IF NOT EXISTS patrika_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    patrika_id UUID REFERENCES patrika(id) ON DELETE CASCADE,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2),
    payment_id VARCHAR(255),
    UNIQUE(user_id, patrika_id)
);

-- Paath service forms
CREATE TABLE IF NOT EXISTS paath_forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    service_id VARCHAR(100) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    installments INTEGER DEFAULT 6,
    installment_amount DECIMAL(10, 2) NOT NULL,
    -- Personal details
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    time_of_birth VARCHAR(10) NOT NULL,
    place_of_birth VARCHAR(255) NOT NULL,
    fathers_or_husbands_name VARCHAR(255) NOT NULL,
    gotra VARCHAR(100) NOT NULL,
    caste VARCHAR(100) NOT NULL,
    -- Payment status
    payment_status VARCHAR(50) DEFAULT 'pending', -- pending, partial, completed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Family members for paath forms
CREATE TABLE IF NOT EXISTS paath_form_family_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paath_form_id UUID REFERENCES paath_forms(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    time_of_birth VARCHAR(10) NOT NULL,
    place_of_birth VARCHAR(255) NOT NULL,
    relationship VARCHAR(100) NOT NULL
);

-- Paath payments (installments)
CREATE TABLE IF NOT EXISTS paath_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paath_form_id UUID REFERENCES paath_forms(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_id VARCHAR(255),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed
    UNIQUE(paath_form_id, installment_number)
);

-- Donations
CREATE TABLE IF NOT EXISTS donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed
    payment_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Payment records
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    payment_id VARCHAR(255) UNIQUE NOT NULL,
    payment_request_id VARCHAR(255),
    status VARCHAR(50) NOT NULL, -- pending, completed, failed
    amount DECIMAL(10, 2) NOT NULL,
    type VARCHAR(50) NOT NULL, -- subscription, patrika, paath, donation
    buyer_name VARCHAR(255),
    buyer_email VARCHAR(255),
    buyer_phone VARCHAR(20),
    metadata JSONB,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- App settings (key-value store for dynamic content)
CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Paath forms: status for completion tracking
ALTER TABLE paath_forms ADD COLUMN IF NOT EXISTS paath_status VARCHAR(50) DEFAULT 'pending';
ALTER TABLE paath_forms ADD COLUMN IF NOT EXISTS paath_done_date DATE;

-- Seed default home hero text
INSERT INTO app_settings (key, value) VALUES (
    'home_hero_text',
    'लो! ले आया दो हाथों में छल-छल करता पैमाना।
जितना चाहो मांगो पी लो छोड़ो अब यूं शरमाना।
प्यास बुझाने को जीवन की इक पैमाना काफी है,
बच्चे, बूढ़े सबकी खातिर खोल दिया है मयख़ाना।'
) ON CONFLICT (key) DO NOTHING;

INSERT INTO app_settings (key, value) VALUES ('audio_preview_seconds', '120')
ON CONFLICT (key) DO NOTHING;

-- Daily Ekaum password (updated daily from backoffice)
INSERT INTO app_settings (key, value) VALUES
  ('daily_ekaum_password', 'नमो नारायण'),
  ('daily_ekaum_date', to_char(CURRENT_DATE, 'YYYY-MM-DD'))
ON CONFLICT (key) DO NOTHING;

-- Seed default paath services (installments: 1=one-time, 6=6 installments)
INSERT INTO paath_services (id, name, description, price, is_family_service, installments, display_order) VALUES
  ('durga_saptashti_paath', 'Durga Saptashti Paath', 'Durga Saptashti Paath service', 21000.0, false, 6, 1),
  ('durga_saptashti_parihar_paath', 'Durga Saptashti Parihar Paath', 'Durga Saptashti Parihar Paath service', 21000.0, false, 6, 2),
  ('durga_saptashti_paath_family', 'Durga Saptashti Paath Family', 'Durga Saptashti Paath for family', 51000.0, true, 6, 3),
  ('durga_saptashti_parihar_paath_family', 'Durga Saptashti Parihar Paath Family', 'Durga Saptashti Parihar Paath for family', 51000.0, true, 6, 4),
  ('mahamritunjaya_paath', 'Mahamritunjaya Paath', 'Mahamritunjaya Paath service', 125000.0, false, 6, 5),
  ('vishesh_kripa_samadhan', 'Vishesh Kripa Samadhan', 'Vishesh Kripa Samadhan service', 1100.0, false, 1, 6),
  ('janam_kundli_samadhar', 'Janam Kundli Samadhar', 'Janam Kundli Samadhar service', 1100.0, false, 1, 7)
ON CONFLICT (id) DO NOTHING;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_patrika_purchases_user_id ON patrika_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_patrika_purchases_patrika_id ON patrika_purchases(patrika_id);
CREATE INDEX IF NOT EXISTS idx_paath_forms_user_id ON paath_forms(user_id);
CREATE INDEX IF NOT EXISTS idx_paath_form_family_members_form_id ON paath_form_family_members(paath_form_id);
CREATE INDEX IF NOT EXISTS idx_paath_payments_form_id ON paath_payments(paath_form_id);
CREATE INDEX IF NOT EXISTS idx_donations_user_id ON donations(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_id ON payments(payment_id);
