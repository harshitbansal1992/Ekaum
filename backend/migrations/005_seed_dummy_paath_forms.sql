-- Seed dummy paath forms for testing
-- Single form (Vishesh Kripa Samadhan - 6 installments)
-- Family form (Durga Saptashti Paath Family - 6 installments, with family members)
--
-- Prerequisite: At least one user must exist. Run after registering in the app.
-- Or replace test_user_id with your user's UUID.

DO $$
DECLARE
  test_user_id UUID;
  single_form_id UUID;
  family_form_id UUID;
BEGIN
  -- Use first user (ensure you have registered at least one user first)
  SELECT id INTO test_user_id FROM users LIMIT 1;
  IF test_user_id IS NULL THEN
    RAISE NOTICE 'Skipping: No users found. Register in the app first, then run: npm run seed:paath-forms';
    RETURN;
  END IF;

  -- 1. SINGLE paath form - Vishesh Kripa Samadhan (₹1100, 6 installments of ~₹183.33)
  INSERT INTO paath_forms (
    user_id, service_id, service_name, total_amount, installments, installment_amount,
    name, date_of_birth, time_of_birth, place_of_birth,
    fathers_or_husbands_name, gotra, caste, payment_status
  ) VALUES (
    test_user_id,
    'vishesh_kripa_samadhan',
    'Vishesh Kripa Samadhan',
    1100.00,
    6,
    183.33,
    'Ram Kumar Sharma',
    '1985-05-15',
    '10:30 AM',
    'Mumbai, Maharashtra',
    'Shri Hari Sharma',
    'Kashyap',
    'Brahmin',
    'pending'
  ) RETURNING id INTO single_form_id;

  -- Paath payments for single form (6 installments)
  INSERT INTO paath_payments (paath_form_id, installment_number, amount, status)
  VALUES
    (single_form_id, 1, 183.33, 'pending'),
    (single_form_id, 2, 183.33, 'pending'),
    (single_form_id, 3, 183.34, 'pending'),
    (single_form_id, 4, 183.33, 'pending'),
    (single_form_id, 5, 183.33, 'pending'),
    (single_form_id, 6, 183.34, 'pending')
  ON CONFLICT (paath_form_id, installment_number) DO NOTHING;

  -- 2. FAMILY paath form - Durga Saptashti Paath Family (₹51000, 6 installments of ₹8500)
  INSERT INTO paath_forms (
    user_id, service_id, service_name, total_amount, installments, installment_amount,
    name, date_of_birth, time_of_birth, place_of_birth,
    fathers_or_husbands_name, gotra, caste, payment_status
  ) VALUES (
    test_user_id,
    'durga_saptashti_paath_family',
    'Durga Saptashti Paath Family',
    51000.00,
    6,
    8500.00,
    'Suresh Devi Patel',
    '1978-08-22',
    '08:15 AM',
    'Ahmedabad, Gujarat',
    'Shri Mahesh Patel',
    'Bhardwaj',
    'Patel',
    'pending'
  ) RETURNING id INTO family_form_id;

  -- Family members for family form
  INSERT INTO paath_form_family_members (paath_form_id, name, date_of_birth, time_of_birth, place_of_birth, relationship)
  VALUES
    (family_form_id, 'Priya Patel', '1982-03-10', '11:00 AM', 'Ahmedabad, Gujarat', 'Wife'),
    (family_form_id, 'Rahul Patel', '2005-07-18', '02:45 PM', 'Ahmedabad, Gujarat', 'Son'),
    (family_form_id, 'Anjali Patel', '2008-12-05', '09:30 AM', 'Ahmedabad, Gujarat', 'Daughter');

  -- Paath payments for family form (6 installments)
  INSERT INTO paath_payments (paath_form_id, installment_number, amount, status)
  VALUES
    (family_form_id, 1, 8500.00, 'pending'),
    (family_form_id, 2, 8500.00, 'pending'),
    (family_form_id, 3, 8500.00, 'pending'),
    (family_form_id, 4, 8500.00, 'pending'),
    (family_form_id, 5, 8500.00, 'pending'),
    (family_form_id, 6, 8500.00, 'pending')
  ON CONFLICT (paath_form_id, installment_number) DO NOTHING;

  RAISE NOTICE 'Created dummy paath forms: single_form_id=%, family_form_id=%', single_form_id, family_form_id;
END $$;
