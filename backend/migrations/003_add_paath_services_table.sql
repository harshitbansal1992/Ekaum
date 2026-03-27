-- Migration: Create paath_services table for dynamic paath service definitions
-- Run this after schema.sql / existing migrations

-- Paath services catalog (replaces hardcoded list in Flutter)
CREATE TABLE IF NOT EXISTS paath_services (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    price DECIMAL(10, 2) NOT NULL,
    is_family_service BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optional: Add FK from paath_forms.service_id to paath_services.id (soft - existing data may not match)
-- ALTER TABLE paath_forms ADD CONSTRAINT fk_paath_forms_service 
--   FOREIGN KEY (service_id) REFERENCES paath_services(id) ON DELETE SET NULL;
-- Skipping FK for now to allow existing forms to reference legacy service_ids

-- Index for ordering
CREATE INDEX IF NOT EXISTS idx_paath_services_display_order ON paath_services(display_order);
CREATE INDEX IF NOT EXISTS idx_paath_services_is_active ON paath_services(is_active) WHERE is_active = true;

-- Seed default services (from current Flutter hardcoded list)
INSERT INTO paath_services (id, name, description, price, is_family_service, display_order) VALUES
  ('durga_saptashti_paath', 'Durga Saptashti Paath', 'Durga Saptashti Paath service', 21000.0, false, 1),
  ('durga_saptashti_parihar_paath', 'Durga Saptashti Parihar Paath', 'Durga Saptashti Parihar Paath service', 21000.0, false, 2),
  ('durga_saptashti_paath_family', 'Durga Saptashti Paath Family', 'Durga Saptashti Paath for family', 51000.0, true, 3),
  ('durga_saptashti_parihar_paath_family', 'Durga Saptashti Parihar Paath Family', 'Durga Saptashti Parihar Paath for family', 51000.0, true, 4),
  ('mahamritunjaya_paath', 'Mahamritunjaya Paath', 'Mahamritunjaya Paath service', 125000.0, false, 5),
  ('vishesh_kripa_samadhan', 'Vishesh Kripa Samadhan', 'Vishesh Kripa Samadhan service', 1100.0, false, 6),
  ('janam_kundli_samadhar', 'Janam Kundli Samadhar', 'Janam Kundli Samadhar service', 1100.0, false, 7)
ON CONFLICT (id) DO NOTHING;
