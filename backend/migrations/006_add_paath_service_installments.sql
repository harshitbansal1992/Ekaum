-- Add installments to paath_services
-- 1 = one-time payment (full amount at once)
-- 2-12 = that many installments (user can choose within range)
-- Default 6 for existing services (backward compatible)

ALTER TABLE paath_services ADD COLUMN IF NOT EXISTS installments INTEGER DEFAULT 6;

-- Update existing services: smaller amounts one-time, larger amounts keep 6
-- vishesh_kripa_samadhan, janam_kundli_samadhar (1100) -> one-time
UPDATE paath_services SET installments = 1 WHERE id IN ('vishesh_kripa_samadhan', 'janam_kundli_samadhar');
-- Others keep 6 installments (default)
