-- ==============================================================================
-- SUPABASE SEED DATA: Realistic Sri Lankan Household Budget (Notebook Match)
-- ==============================================================================

DO $$
DECLARE
    v_household_id UUID := 'a0000000-0000-0000-0000-000000000001';
    v_member_self UUID  := 'b0000000-0000-0000-0000-000000000001';
    v_member_wife UUID  := 'b0000000-0000-0000-0000-000000000002';
    v_cycle_id UUID     := 'c0000000-0000-0000-0000-000000000001';

    v_fix_rent UUID     := uuid_generate_v4();
    v_fix_ecb UUID      := uuid_generate_v4();
    v_fix_loan UUID     := uuid_generate_v4();
    v_fix_gold UUID     := uuid_generate_v4();

    v_sub_dialog_mob UUID := uuid_generate_v4();
    v_sub_dialog_rtr UUID := uuid_generate_v4();
    v_sub_phone_loan UUID := uuid_generate_v4();
    v_sub_netflix    UUID := uuid_generate_v4();
    v_sub_apple_mus  UUID := uuid_generate_v4();
    v_sub_apple_cld  UUID := uuid_generate_v4();
    v_sub_youtube    UUID := uuid_generate_v4();

    v_cc_combank UUID   := uuid_generate_v4();
    v_cc_sampath UUID   := uuid_generate_v4();
    v_cc_dfcc    UUID   := uuid_generate_v4();
BEGIN
    -- 1. Create Household
    INSERT INTO public.households (id, name, currency_symbol, currency_code, cycle_start_day)
    VALUES (v_household_id, 'Our Home Budget', 'LKR', 'Rs.', 25)
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

    -- 2. Household Members
    INSERT INTO public.household_members (id, household_id, name, role, avatar_color, regular_monthly_salary)
    VALUES 
        (v_member_self, v_household_id, 'Sathsara', 'husband', '#10B981', 249585.00),
        (v_member_wife, v_household_id, 'Dhiyan', 'wife', '#EC4899', 150000.00)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Cycle: Aug 25 - Sep 25, 2026
    INSERT INTO public.cycles (id, household_id, name, start_date, end_date, status, notes)
    VALUES (v_cycle_id, v_household_id, 'Aug 25 - Sep 25, 2026', '2026-08-25', '2026-09-24', 'open', 'Current active salary cycle')
    ON CONFLICT (id) DO NOTHING;

    -- 4. Income Entries
    INSERT INTO public.income_entries (household_id, cycle_id, member_id, source, amount, date, notes)
    VALUES 
        (v_household_id, v_cycle_id, v_member_self, 'Salary', 249585.00, '2026-08-24', 'Monthly IT salary credited'),
        (v_household_id, v_cycle_id, v_member_wife, 'Salary', 150000.00, '2026-08-25', 'Monthly salary credited')
    ON CONFLICT DO NOTHING;

    -- 5. Fixed Payments & Logs
    INSERT INTO public.fixed_payments (id, household_id, name, amount, due_day_of_month, category, transfer_destination, is_recurring)
    VALUES 
        (v_fix_rent, v_household_id, 'Apartment Rent', 70000.00, 25, 'Housing', 'BOC Account (Reserve 100k with ECB)', true),
        (v_fix_ecb, v_household_id, 'Apartment ECB + Water', 20000.00, 25, 'Utilities', 'BOC Account', true),
        (v_fix_loan, v_household_id, 'Commercial Bank Personal Loan', 47544.00, 26, 'Loan', 'Commercial Bank', true),
        (v_fix_gold, v_household_id, 'Gold Loan Interest (Bracelet & Rings)', 8500.00, 26, 'Loan', 'Commercial Bank', true)
    ON CONFLICT DO NOTHING;

    INSERT INTO public.fixed_payment_logs (household_id, cycle_id, fixed_payment_id, is_paid, paid_date, paid_amount)
    VALUES
        (v_household_id, v_cycle_id, v_fix_rent, true, '2026-08-26', 70000.00),
        (v_household_id, v_cycle_id, v_fix_ecb, true, '2026-08-26', 20000.00),
        (v_household_id, v_cycle_id, v_fix_loan, true, '2026-08-26', 47544.00),
        (v_household_id, v_cycle_id, v_fix_gold, false, NULL, 0.00)
    ON CONFLICT DO NOTHING;

    -- 6. Subscriptions
    INSERT INTO public.subscriptions (id, household_id, name, original_currency, original_amount, amount_lkr, billing_day, category)
    VALUES
        (v_sub_dialog_mob, v_household_id, 'Dialog Mobile', 'LKR', 2054.00, 2054.00, 24, 'Telecom'),
        (v_sub_dialog_rtr, v_household_id, 'Dialog Broadband Router', 'LKR', 5000.00, 5000.00, 24, 'Telecom'),
        (v_sub_phone_loan, v_household_id, 'Office Phone Loan', 'LKR', 4500.00, 4500.00, 24, 'Telecom'),
        (v_sub_netflix,    v_household_id, 'Netflix Basic', 'USD', 3.99, 1400.00, 24, 'Entertainment'),
        (v_sub_apple_mus,  v_household_id, 'Apple Music', 'USD', 3.29, 1080.00, 26, 'Entertainment'),
        (v_sub_apple_cld,  v_household_id, 'Apple iCloud Storage', 'USD', 2.99, 1000.00, 26, 'Cloud'),
        (v_sub_youtube,    v_household_id, 'YouTube Premium', 'LKR', 1200.00, 1200.00, 28, 'Entertainment')
    ON CONFLICT DO NOTHING;

    INSERT INTO public.subscription_payment_logs (household_id, cycle_id, subscription_id, is_paid, paid_date)
    VALUES
        (v_household_id, v_cycle_id, v_sub_dialog_mob, true, '2026-08-24'),
        (v_household_id, v_cycle_id, v_sub_netflix, true, '2026-08-24'),
        (v_household_id, v_cycle_id, v_sub_apple_mus, true, '2026-08-26'),
        (v_household_id, v_cycle_id, v_sub_apple_cld, true, '2026-08-26')
    ON CONFLICT DO NOTHING;

    -- 7. Credit Cards
    INSERT INTO public.credit_cards (id, household_id, member_id, bank_name, card_name, credit_limit, due_day)
    VALUES
        (v_cc_combank, v_household_id, v_member_self, 'Commercial Bank', 'Combank Platinum', 250000.00, 26),
        (v_cc_sampath, v_household_id, v_member_self, 'Sampath Bank', 'Sampath Signature', 200000.00, 26),
        (v_cc_dfcc,    v_household_id, v_member_self, 'DFCC', 'DFCC Visa', 150000.00, 28)
    ON CONFLICT DO NOTHING;

    INSERT INTO public.credit_card_cycle_dues (household_id, cycle_id, credit_card_id, statement_amount, minimum_due, due_date, is_paid, paid_amount)
    VALUES
        (v_household_id, v_cycle_id, v_cc_combank, 40000.00, 5000.00, '2026-08-26', true, 40000.00),
        (v_household_id, v_cycle_id, v_cc_sampath, 5000.00, 2000.00, '2026-08-26', true, 5000.00),
        (v_household_id, v_cycle_id, v_cc_dfcc, 0.00, 0.00, '2026-08-28', true, 0.00)
    ON CONFLICT DO NOTHING;

    -- 8. Installments (Koko / Mintpay / PayZy)
    -- Dhiyan's Koko
    INSERT INTO public.installment_plans (household_id, member_id, platform, item_name, vendor, total_amount, monthly_installment, remaining_balance, total_installments, installments_paid, due_day_of_month, start_date)
    VALUES
        (v_household_id, v_member_wife, 'Koko', 'Water Filter', 'Dinapala Group', 13647.00, 4549.00, 4549.00, 3, 2, 27, '2026-06-27'),
        (v_household_id, v_member_wife, 'Koko', 'Supplements', 'Strong.lk', 14424.00, 4808.00, 4808.00, 3, 2, 27, '2026-06-27'),
        (v_household_id, v_member_wife, 'Koko', 'Vacuum Cleaner', 'Dmart', 2850.00, 950.00, 950.00, 3, 2, 7, '2026-07-07'),
        (v_household_id, v_member_wife, 'Koko', 'Supplements 2', 'Strong.lk', 8220.00, 2740.00, 2740.00, 3, 2, 6, '2026-07-06'),
        (v_household_id, v_member_wife, 'Koko', 'Clothes', 'Candy', 5316.00, 1772.00, 1772.00, 3, 2, 2, '2026-07-02'),
        (v_household_id, v_member_wife, 'Koko', 'Bag', 'Artic Hunter', 11070.00, 3690.00, 0.00, 3, 3, 6, '2026-06-06'),
        (v_household_id, v_member_wife, 'Koko', 'Dresses', 'Cool Planet', 7191.00, 2397.00, 2397.00, 3, 2, 22, '2026-07-22'),
        
        -- Sathsara's Koko
        (v_household_id, v_member_self, 'Koko', 'Perfume', 'Sensara', 16131.00, 5377.00, 10754.00, 3, 1, 29, '2026-07-29'),
        (v_household_id, v_member_self, 'Koko', 'Shirt', 'Deedat', 3990.00, 1330.00, 2660.00, 3, 1, 29, '2026-07-29'),
        (v_household_id, v_member_self, 'Koko', 'Cosmetics', 'Cosmetic.lk', 6000.00, 2000.00, 4000.00, 3, 1, 30, '2026-07-30'),
        (v_household_id, v_member_self, 'Koko', 'Bed Sheet', 'Lassan.com', 5250.00, 1750.00, 3500.00, 3, 1, 13, '2026-08-13'),
        
        -- Sathsara's Mintpay & PayZy
        (v_household_id, v_member_self, 'Mintpay', 'Online Grocery 1', 'Online Kade', 16941.00, 5647.00, 5647.00, 3, 2, 30, '2026-06-30'),
        (v_household_id, v_member_self, 'Mintpay', 'Online Grocery 2', 'Online Kade', 16941.00, 5647.00, 5647.00, 3, 2, 1, '2026-07-01'),
        (v_household_id, v_member_self, 'PayZy', 'Cosmetics Set', 'Beauty Harbour lk', 16500.00, 5500.00, 11000.00, 3, 1, 31, '2026-07-31')
    ON CONFLICT DO NOTHING;

    -- 9. Wishlist Items
    INSERT INTO public.wishlist_items (household_id, item_name, category, estimated_cost, priority, is_planned_for_current_cycle)
    VALUES
        (v_household_id, 'Spice Bottles (Glass)', 'Kitchen', 1500.00, 'medium', false),
        (v_household_id, 'Coconut Oil Glass Bottle', 'Kitchen', 1200.00, 'low', false),
        (v_household_id, 'Potato Smasher', 'Kitchen', 800.00, 'high', true),
        (v_household_id, 'Plastic / Food Storage Rack', 'Kitchen', 3500.00, 'medium', false),
        (v_household_id, 'Litro Gas Cylinder Refill', 'Kitchen', 4200.00, 'high', true),
        (v_household_id, 'Clay Cooking Pots', 'Kitchen', 2000.00, 'low', false),
        (v_household_id, 'Air Fryer / Convection Oven', 'Kitchen', 38000.00, 'medium', false),
        (v_household_id, 'Stainless Steel Bowls Set', 'Kitchen', 2500.00, 'medium', false),
        (v_household_id, 'Glass Lid for Nonstick Pan', 'Kitchen', 1800.00, 'low', false),
        (v_household_id, 'Cooking Heat Gloves', 'Kitchen', 600.00, 'low', false),
        (v_household_id, 'Soap Holder', 'Bathroom', 950.00, 'medium', true),
        (v_household_id, 'Sanitary Item Holder', 'Bathroom', 1400.00, 'medium', true),
        (v_household_id, 'Toothbrush Holder', 'Bathroom', 850.00, 'high', true),
        (v_household_id, 'New Bidet Shower Sprayer', 'Bathroom', 2800.00, 'high', true),
        (v_household_id, 'Floor Wiper', 'Bathroom', 1100.00, 'medium', true)
    ON CONFLICT DO NOTHING;

    -- 10. Daily Spends
    INSERT INTO public.daily_spends (household_id, cycle_id, member_id, date, amount, category, payment_method, title, notes)
    VALUES
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 200.00, 'Health / Gym', 'Cash', 'Gym Pure Water', 'Pre-workout'),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 220.00, 'Groceries', 'Cash', 'Pure for Cooking', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 1400.00, 'Groceries', 'Cash', 'Chicken 1.1kg', 'Fresh meat'),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 300.00, 'Kitchen', 'Cash', 'Potato Smasher Hand Tool', 'Street vendor'),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 6802.00, 'Groceries', 'Commercial Debit Card', 'Food City Supermarket Groceries', 'Milk, cheese, soap, eno, mosquito repellent'),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 406.00, 'Transport / PickMe', 'Cash', 'PickMe Tuk to Grocery', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 340.00, 'Food & Dining', 'Cash', 'Spar Supermarket Snack', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 4100.00, 'Food & Dining', 'Commercial Debit Card', 'Spar Bar Beverages', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-25', 467.00, 'Transport / PickMe', 'Cash', 'PickMe Tuk Coming Home', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-26', 10000.00, 'Other', 'Fund Transfer', 'Transfer to Wife Combank Account', 'Monthly personal pocket allowance'),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-26', 4500.00, 'Other', 'Cash', 'ATM Cash Withdrawal', 'Wallet cash fund'),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-26', 225.00, 'Transport / PickMe', 'Cash', 'Metro Transit to Office', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-26', 500.00, 'Food & Dining', 'Cash', 'Office Lunch', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-26', 225.00, 'Transport / PickMe', 'Cash', 'Metro Transit Returning Home', ''),
        (v_household_id, v_cycle_id, v_member_self, '2026-08-26', 520.00, 'Personal Care', 'Cash', 'Saloon Haircut & Grooming', '')
    ON CONFLICT DO NOTHING;

END $$;
