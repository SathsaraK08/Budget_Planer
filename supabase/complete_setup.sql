-- ==============================================================================
-- HOMEBUDGET: COMPLETE DATABASE SETUP SCRIPT
-- Run this ONCE on a fresh Supabase project (SQL Editor → Run).
-- This combines the base schema + Phase 1 migration into a single script.
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- TABLES
-- ==============================================================================

-- 1. Households
CREATE TABLE IF NOT EXISTS public.households (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL DEFAULT 'My Household',
    currency_symbol TEXT NOT NULL DEFAULT 'Rs.',    -- display symbol  e.g. 'Rs.'
    currency_code TEXT NOT NULL DEFAULT 'LKR',      -- ISO code        e.g. 'LKR'
    cycle_start_day INT NOT NULL DEFAULT 25,
    gemini_api_key TEXT,                            -- legacy; use ai_settings table
    setup_completed BOOLEAN NOT NULL DEFAULT FALSE, -- wizard completion flag
    app_name TEXT NOT NULL DEFAULT 'HomeBudget',    -- branding / appearance
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Household Members
CREATE TABLE IF NOT EXISTS public.household_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_color TEXT NOT NULL DEFAULT '#10B981',
    regular_monthly_salary NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Household Theme Presets
CREATE TABLE IF NOT EXISTS public.household_themes (
    household_id UUID PRIMARY KEY REFERENCES public.households(id) ON DELETE CASCADE,
    theme_preset TEXT NOT NULL DEFAULT 'emerald',
    primary_color TEXT NOT NULL DEFAULT '#10B981',
    accent_color TEXT NOT NULL DEFAULT '#6366F1',
    mode TEXT NOT NULL DEFAULT 'dark',
    app_name TEXT NOT NULL DEFAULT 'HomeBudget',
    logo_url TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. UI Labels (optional dynamic text)
CREATE TABLE IF NOT EXISTS public.ui_labels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    label_key TEXT NOT NULL,
    label_value TEXT NOT NULL,
    UNIQUE(household_id, label_key)
);

-- 5. Forecast Settings
CREATE TABLE IF NOT EXISTS public.forecast_settings (
    household_id UUID PRIMARY KEY REFERENCES public.households(id) ON DELETE CASCADE,
    survival_buffer_days INT NOT NULL DEFAULT 30,
    reserve_percentage NUMERIC(5, 2) NOT NULL DEFAULT 5.00,
    committed_categories JSONB NOT NULL DEFAULT '["Housing","Utilities","Loan","Insurance","Telecom"]',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. AI Settings
CREATE TABLE IF NOT EXISTS public.ai_settings (
    household_id UUID PRIMARY KEY REFERENCES public.households(id) ON DELETE CASCADE,
    provider TEXT NOT NULL DEFAULT 'none',  -- 'gemini' | 'openai' | 'none'
    api_key TEXT,
    custom_instructions TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Lookup: BNPL Platforms
CREATE TABLE IF NOT EXISTS public.lookup_bnpl_platforms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(household_id, name)
);

-- 8. Lookup: Expense Categories
CREATE TABLE IF NOT EXISTS public.lookup_expense_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon_name TEXT NOT NULL DEFAULT 'receipt',
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(household_id, name)
);

-- 9. Lookup: Wishlist Categories
CREATE TABLE IF NOT EXISTS public.lookup_wishlist_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(household_id, name)
);

-- 10. Budget Cycles
CREATE TABLE IF NOT EXISTS public.cycles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. Income Entries
CREATE TABLE IF NOT EXISTS public.income_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    cycle_id UUID NOT NULL REFERENCES public.cycles(id) ON DELETE CASCADE,
    member_id UUID REFERENCES public.household_members(id) ON DELETE SET NULL,
    source TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. Fixed Payments (bills, loans, utilities)
CREATE TABLE IF NOT EXISTS public.fixed_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    due_day_of_month INT NOT NULL DEFAULT 25,
    category TEXT NOT NULL DEFAULT 'Housing',
    transfer_destination TEXT,
    is_recurring BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. Installment Plans (BNPL)
CREATE TABLE IF NOT EXISTS public.installment_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    member_id UUID REFERENCES public.household_members(id) ON DELETE SET NULL,
    platform TEXT NOT NULL DEFAULT 'Koko',
    item_name TEXT NOT NULL,
    vendor TEXT,
    total_amount NUMERIC(12, 2) NOT NULL,
    monthly_installment NUMERIC(12, 2) NOT NULL,
    remaining_balance NUMERIC(12, 2) NOT NULL,
    total_installments INT NOT NULL DEFAULT 3,
    installments_paid INT NOT NULL DEFAULT 0,
    due_day_of_month INT NOT NULL DEFAULT 26,
    start_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. Credit Cards
CREATE TABLE IF NOT EXISTS public.credit_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    member_id UUID REFERENCES public.household_members(id) ON DELETE SET NULL,
    bank_name TEXT NOT NULL,
    card_name TEXT NOT NULL,
    statement_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    due_day INT NOT NULL DEFAULT 26,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. Subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    original_currency TEXT NOT NULL DEFAULT 'LKR',
    original_amount NUMERIC(12, 2) NOT NULL,
    amount_lkr NUMERIC(12, 2) NOT NULL,
    billing_day INT NOT NULL DEFAULT 24,
    category TEXT NOT NULL DEFAULT 'Entertainment',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. Wishlist Items
CREATE TABLE IF NOT EXISTS public.wishlist_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Kitchen',
    estimated_cost NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    priority TEXT NOT NULL DEFAULT 'medium',
    is_purchased BOOLEAN NOT NULL DEFAULT FALSE,
    is_planned_for_current_cycle BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 17. Daily Spends
CREATE TABLE IF NOT EXISTS public.daily_spends (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    cycle_id UUID NOT NULL REFERENCES public.cycles(id) ON DELETE CASCADE,
    member_id UUID REFERENCES public.household_members(id) ON DELETE SET NULL,
    date DATE NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    category TEXT NOT NULL DEFAULT 'Groceries',
    payment_method TEXT NOT NULL DEFAULT 'Cash',
    title TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- ROW LEVEL SECURITY
-- ==============================================================================

ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ui_labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forecast_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lookup_bnpl_platforms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lookup_expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lookup_wishlist_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.income_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fixed_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installment_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_spends ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- HELPER FUNCTIONS
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.is_household_admin(check_household_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.household_members
        WHERE household_id = check_household_id
        AND user_id = auth.uid()
        AND is_admin = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_household_member(check_household_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.household_members
        WHERE household_id = check_household_id
        AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- RLS POLICIES
-- Note: DROP before CREATE makes this script safe to re-run.
-- Explicit ::uuid casts prevent the 42883 type-resolution error in Supabase.
-- ==============================================================================

-- households
DROP POLICY IF EXISTS "Members can view their household" ON public.households;
DROP POLICY IF EXISTS "Admins can update their household" ON public.households;
CREATE POLICY "Members can view their household" ON public.households
    FOR SELECT USING (public.is_household_member(id::uuid));
CREATE POLICY "Admins can update their household" ON public.households
    FOR UPDATE USING (public.is_household_admin(id::uuid));

-- household_members
DROP POLICY IF EXISTS "Members can view other members" ON public.household_members;
DROP POLICY IF EXISTS "Admins can manage members" ON public.household_members;
CREATE POLICY "Members can view other members" ON public.household_members
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage members" ON public.household_members
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- household_themes
DROP POLICY IF EXISTS "Members can view themes" ON public.household_themes;
DROP POLICY IF EXISTS "Admins can manage themes" ON public.household_themes;
CREATE POLICY "Members can view themes" ON public.household_themes
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage themes" ON public.household_themes
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- ui_labels
DROP POLICY IF EXISTS "Members can view labels" ON public.ui_labels;
DROP POLICY IF EXISTS "Admins can manage labels" ON public.ui_labels;
CREATE POLICY "Members can view labels" ON public.ui_labels
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage labels" ON public.ui_labels
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- forecast_settings
DROP POLICY IF EXISTS "Members can view forecast settings" ON public.forecast_settings;
DROP POLICY IF EXISTS "Admins can manage forecast settings" ON public.forecast_settings;
CREATE POLICY "Members can view forecast settings" ON public.forecast_settings
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage forecast settings" ON public.forecast_settings
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- ai_settings
DROP POLICY IF EXISTS "Members can view AI settings" ON public.ai_settings;
DROP POLICY IF EXISTS "Admins can manage AI settings" ON public.ai_settings;
CREATE POLICY "Members can view AI settings" ON public.ai_settings
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage AI settings" ON public.ai_settings
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- lookup_bnpl_platforms
DROP POLICY IF EXISTS "Members can view BNPL platforms" ON public.lookup_bnpl_platforms;
DROP POLICY IF EXISTS "Admins can manage BNPL platforms" ON public.lookup_bnpl_platforms;
CREATE POLICY "Members can view BNPL platforms" ON public.lookup_bnpl_platforms
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage BNPL platforms" ON public.lookup_bnpl_platforms
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- lookup_expense_categories
DROP POLICY IF EXISTS "Members can view expense categories" ON public.lookup_expense_categories;
DROP POLICY IF EXISTS "Admins can manage expense categories" ON public.lookup_expense_categories;
CREATE POLICY "Members can view expense categories" ON public.lookup_expense_categories
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage expense categories" ON public.lookup_expense_categories
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- lookup_wishlist_categories
DROP POLICY IF EXISTS "Members can view wishlist categories" ON public.lookup_wishlist_categories;
DROP POLICY IF EXISTS "Admins can manage wishlist categories" ON public.lookup_wishlist_categories;
CREATE POLICY "Members can view wishlist categories" ON public.lookup_wishlist_categories
    FOR SELECT USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Admins can manage wishlist categories" ON public.lookup_wishlist_categories
    FOR ALL USING (public.is_household_admin(household_id::uuid));

-- data tables (all household members can fully manage their data)
DROP POLICY IF EXISTS "Members can manage cycles"         ON public.cycles;
DROP POLICY IF EXISTS "Members can manage incomes"        ON public.income_entries;
DROP POLICY IF EXISTS "Members can manage fixed payments" ON public.fixed_payments;
DROP POLICY IF EXISTS "Members can manage installments"   ON public.installment_plans;
DROP POLICY IF EXISTS "Members can manage credit cards"   ON public.credit_cards;
DROP POLICY IF EXISTS "Members can manage subscriptions"  ON public.subscriptions;
DROP POLICY IF EXISTS "Members can manage wishlist"       ON public.wishlist_items;
DROP POLICY IF EXISTS "Members can manage daily spends"   ON public.daily_spends;

CREATE POLICY "Members can manage cycles"
    ON public.cycles FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage incomes"
    ON public.income_entries FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage fixed payments"
    ON public.fixed_payments FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage installments"
    ON public.installment_plans FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage credit cards"
    ON public.credit_cards FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage subscriptions"
    ON public.subscriptions FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage wishlist"
    ON public.wishlist_items FOR ALL USING (public.is_household_member(household_id::uuid));
CREATE POLICY "Members can manage daily spends"
    ON public.daily_spends FOR ALL USING (public.is_household_member(household_id::uuid));


-- ==============================================================================
-- RPC FUNCTIONS
-- ==============================================================================

-- Register a new household (called from auth screen on first sign-up)
CREATE OR REPLACE FUNCTION public.claim_household(
    new_household_name TEXT,
    user_name TEXT,
    user_role TEXT,
    partner_name TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    new_hh_id UUID;
BEGIN
    -- Create household (setup_completed starts FALSE — wizard must finish it)
    INSERT INTO public.households (name, setup_completed)
    VALUES (new_household_name, FALSE)
    RETURNING id INTO new_hh_id;

    -- Registering user becomes admin
    INSERT INTO public.household_members (household_id, user_id, name, role, is_admin)
    VALUES (new_hh_id, auth.uid(), user_name, 'admin', TRUE);

    -- Optional partner (no user_id yet — they sign up separately and link)
    IF partner_name IS NOT NULL AND partner_name != '' THEN
        INSERT INTO public.household_members (household_id, name, role, is_admin, avatar_color)
        VALUES (new_hh_id, partner_name, 'member', FALSE, '#EC4899');
    END IF;

    -- Seed companion config rows
    INSERT INTO public.household_themes (household_id) VALUES (new_hh_id)
        ON CONFLICT (household_id) DO NOTHING;
    INSERT INTO public.forecast_settings (household_id) VALUES (new_hh_id)
        ON CONFLICT (household_id) DO NOTHING;
    INSERT INTO public.ai_settings (household_id) VALUES (new_hh_id)
        ON CONFLICT (household_id) DO NOTHING;

    -- Seed default BNPL platforms
    INSERT INTO public.lookup_bnpl_platforms (household_id, name, sort_order) VALUES
        (new_hh_id, 'Koko',   1),
        (new_hh_id, 'Mintpay',2),
        (new_hh_id, 'PayZy',  3),
        (new_hh_id, 'Frimi',  4),
        (new_hh_id, 'Other',  5);

    -- Seed default expense categories
    INSERT INTO public.lookup_expense_categories (household_id, name, icon_name, sort_order) VALUES
        (new_hh_id, 'Groceries',              'shopping_basket', 1),
        (new_hh_id, 'Food & Dining',          'restaurant',      2),
        (new_hh_id, 'Transport / PickMe',     'directions_car',  3),
        (new_hh_id, 'Health & Gym',           'favorite',        4),
        (new_hh_id, 'Personal Care & Saloon', 'spa',             5),
        (new_hh_id, 'Entertainment',          'movie',           6),
        (new_hh_id, 'Clothing & Fashion',     'checkroom',       7),
        (new_hh_id, 'Home & Household',       'home',            8),
        (new_hh_id, 'Education',              'school',          9),
        (new_hh_id, 'Other / Cash Reserve',   'wallet',         10);

    -- Seed default wishlist categories
    INSERT INTO public.lookup_wishlist_categories (household_id, name, sort_order) VALUES
        (new_hh_id, 'Kitchen',         1),
        (new_hh_id, 'Bathroom',        2),
        (new_hh_id, 'Electronics',     3),
        (new_hh_id, 'Clothing',        4),
        (new_hh_id, 'Home Appliances', 5),
        (new_hh_id, 'Other',           6);

    RETURN new_hh_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mark setup wizard as complete (fixes setup-loop bug)
CREATE OR REPLACE FUNCTION public.complete_setup(p_household_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.households
    SET setup_completed = TRUE
    WHERE id = p_household_id
    AND public.is_household_admin(p_household_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Safe member delete — checks FK-linked records first
-- Returns: 'deleted' | 'blocked:N' (N = linked record count) | 'unauthorized'
CREATE OR REPLACE FUNCTION public.safe_delete_member(p_member_id UUID, p_household_id UUID)
RETURNS TEXT AS $$
DECLARE
    spend_count  INT;
    income_count INT;
BEGIN
    IF NOT public.is_household_admin(p_household_id) THEN
        RETURN 'unauthorized';
    END IF;

    SELECT COUNT(*) INTO spend_count  FROM public.daily_spends   WHERE member_id = p_member_id;
    SELECT COUNT(*) INTO income_count FROM public.income_entries  WHERE member_id = p_member_id;

    IF spend_count > 0 OR income_count > 0 THEN
        RETURN 'blocked:' || (spend_count + income_count)::TEXT;
    END IF;

    DELETE FROM public.household_members
    WHERE id = p_member_id AND household_id = p_household_id;

    RETURN 'deleted';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
