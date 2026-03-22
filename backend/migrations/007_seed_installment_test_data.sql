-- Seed paath forms with varied installment states for testing
-- 1. Pending - all installments unpaid
-- 2. Partial - some installments paid
-- 3. Completed - all installments paid
--
-- Prerequisite: At least one user must exist.

DO $$
DECLARE
  uid UUID;
  form_pending_id UUID;
  form_partial_id UUID;
  form_completed_id UUID;
BEGIN
  SELECT id INTO uid FROM users LIMIT 1;
  IF uid IS NULL THEN
    RAISE NOTICE 'Skipping: No users found. Run npm run seed:full first for test data.';
    RETURN;
  END IF;

  -- 1. PENDING: All 6 installments unpaid (Vishesh Kripa - one-time service, but we'll use 6 for testing)
  INSERT INTO paath_forms (
    user_id, service_id, service_name, total_amount, installments, installment_amount,
    name, date_of_birth, time_of_birth, place_of_birth,
    fathers_or_husbands_name, gotra, caste, payment_status
  ) VALUES (
    uid, 'vishesh_kripa_samadhan', 'Vishesh Kripa Samadhan', 1100.00, 6, 183.33,
    'Test User Pending', '1990-01-01', '10:00 AM', 'Delhi',
    'Father Name', 'Kashyap', 'Brahmin', 'pending'
  ) RETURNING id INTO form_pending_id;

  INSERT INTO paath_payments (paath_form_id, installment_number, amount, status)
  VALUES (form_pending_id, 1, 183.33, 'pending'), (form_pending_id, 2, 183.33, 'pending'),
         (form_pending_id, 3, 183.34, 'pending'), (form_pending_id, 4, 183.33, 'pending'),
         (form_pending_id, 5, 183.33, 'pending'), (form_pending_id, 6, 183.34, 'pending')
  ON CONFLICT (paath_form_id, installment_number) DO NOTHING;

  -- 2. PARTIAL: First 3 installments paid, rest pending (Mahamritunjaya - 6 of 6)
  INSERT INTO paath_forms (
    user_id, service_id, service_name, total_amount, installments, installment_amount,
    name, date_of_birth, time_of_birth, place_of_birth,
    fathers_or_husbands_name, gotra, caste, payment_status
  ) VALUES (
    uid, 'mahamritunjaya_paath', 'Mahamritunjaya Paath', 125000.00, 6, 20833.33,
    'Test User Partial', '1985-06-15', '09:30 AM', 'Bangalore',
    'Shri Rama', 'Bhardwaj', 'Kshatriya', 'partial'
  ) RETURNING id INTO form_partial_id;

  INSERT INTO paath_payments (paath_form_id, installment_number, amount, status, payment_id, payment_date)
  VALUES
    (form_partial_id, 1, 20833.33, 'completed', 'pay_test_partial_1', NOW() - INTERVAL '60 days'),
    (form_partial_id, 2, 20833.33, 'completed', 'pay_test_partial_2', NOW() - INTERVAL '45 days'),
    (form_partial_id, 3, 20833.34, 'completed', 'pay_test_partial_3', NOW() - INTERVAL '30 days'),
    (form_partial_id, 4, 20833.33, 'pending', NULL, NULL),
    (form_partial_id, 5, 20833.33, 'pending', NULL, NULL),
    (form_partial_id, 6, 20833.34, 'pending', NULL, NULL)
  ON CONFLICT (paath_form_id, installment_number) DO UPDATE SET
    status = EXCLUDED.status,
    payment_id = EXCLUDED.payment_id,
    payment_date = EXCLUDED.payment_date;

  -- 3. COMPLETED: All 6 installments paid (Durga Saptashti)
  INSERT INTO paath_forms (
    user_id, service_id, service_name, total_amount, installments, installment_amount,
    name, date_of_birth, time_of_birth, place_of_birth,
    fathers_or_husbands_name, gotra, caste, payment_status
  ) VALUES (
    uid, 'durga_saptashti_paath', 'Durga Saptashti Paath', 21000.00, 6, 3500.00,
    'Test User Completed', '1982-11-20', '08:00 AM', 'Chennai',
    'Shri Dev', 'Vatsa', 'Vaishya', 'completed'
  ) RETURNING id INTO form_completed_id;

  INSERT INTO paath_payments (paath_form_id, installment_number, amount, status, payment_id, payment_date)
  VALUES
    (form_completed_id, 1, 3500.00, 'completed', 'pay_test_completed_1', NOW() - INTERVAL '120 days'),
    (form_completed_id, 2, 3500.00, 'completed', 'pay_test_completed_2', NOW() - INTERVAL '100 days'),
    (form_completed_id, 3, 3500.00, 'completed', 'pay_test_completed_3', NOW() - INTERVAL '80 days'),
    (form_completed_id, 4, 3500.00, 'completed', 'pay_test_completed_4', NOW() - INTERVAL '60 days'),
    (form_completed_id, 5, 3500.00, 'completed', 'pay_test_completed_5', NOW() - INTERVAL '40 days'),
    (form_completed_id, 6, 3500.00, 'completed', 'pay_test_completed_6', NOW() - INTERVAL '20 days')
  ON CONFLICT (paath_form_id, installment_number) DO UPDATE SET
    status = EXCLUDED.status,
    payment_id = EXCLUDED.payment_id,
    payment_date = EXCLUDED.payment_date;

  RAISE NOTICE 'Created installment test data: pending=%, partial=%, completed=%', form_pending_id, form_partial_id, form_completed_id;
END $$;
