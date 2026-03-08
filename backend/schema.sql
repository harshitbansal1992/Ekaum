-- BSLND PostgreSQL Database Schema
-- Run this SQL script to create all tables

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    phone VARCHAR(20),
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


