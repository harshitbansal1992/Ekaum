-- Migration: Add app_settings table for key-value dynamic content
-- Run this if your database already exists and doesn't have app_settings

CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_settings (key, value) VALUES (
    'home_hero_text',
    'लो! ले आया दो हाथों में छल-छल करता पैमाना।
जितना चाहो मांगो पी लो छोड़ो अब यूं शरमाना।
प्यास बुझाने को जीवन की इक पैमाना काफी है,
बच्चे, बूढ़े सबकी खातिर खोल दिया है मयख़ाना।'
) ON CONFLICT (key) DO NOTHING;
