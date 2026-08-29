-- ==============================================================================
-- SUPABASE SCHEMA: Household Budget Planner & Admin CMS (25th-to-25th Cycle)
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Households
CREATE TABLE IF NOT EXISTS public.households (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL DEFAULT 'My Household',
    currency_symbol TEXT NOT NULL DEFAULT 'LKR',
    currency_code TEXT NOT NULL DEFAULT 'Rs.',
    cycle_start_day INT NOT NULL DEFAULT 25,
    gemini_api_key TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Household Members & Roles
CREATE TABLE IF NOT EXISTS public.household_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member', -- 'husband', 'wife', 'admin', 'partner'
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_color TEXT NOT NULL DEFAULT '#10B981',
    regular_monthly_salary NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Household Theme Presets (Dynamic Theming with zero redeploy)
CREATE TABLE IF NOT EXISTS public.household_themes (
    household_id UUID PRIMARY KEY REFERENCES public.households(id) ON DELETE CASCADE,
    theme_preset TEXT NOT NULL DEFAULT 'emerald', -- 'emerald', 'sapphire', 'amethyst', 'amber', 'crimson'
    primary_color TEXT NOT NULL DEFAULT '#10B981',
    accent_color TEXT NOT NULL DEFAULT '#6366F1',
    mode TEXT NOT NULL DEFAULT 'dark', -- 'dark', 'light'
    app_name TEXT NOT NULL DEFAULT 'HomeBudget',
    logo_url TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. UI Labels Dictionary (Dynamic customizable text)
CREATE TABLE IF NOT EXISTS public.ui_labels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    label_key TEXT NOT NULL,
    label_value TEXT NOT NULL,
    UNIQUE(household_id, label_key)
);

-- 5. Forecast Tunable Parameters
CREATE TABLE IF NOT EXISTS public.forecast_settings (
    household_id UUID PRIMARY KEY REFERENCES public.households(id) ON DELETE CASCADE,
    survival_buffer_days INT NOT NULL DEFAULT 30,
    reserve_percentage NUMERIC(5, 2) NOT NULL DEFAULT 5.00,
    committed_categories JSONB NOT NULL DEFAULT '["Housing", "Utilities", "Loan", "Insurance", "Telecom"]',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Budget Cycles
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

-- 7. Incomes
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

-- 8. Fixed Payments & Logs
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

-- 9. Installment Plans (BNPL)
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

-- 10. Credit Cards
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

-- 11. Subscriptions
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

-- 12. Wishlist Items
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

-- 13. Daily Spends
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

-- RLS
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ui_labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forecast_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.income_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fixed_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installment_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_spends ENABLE ROW LEVEL SECURITY;

-- Helper to check admin status
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

-- Helper to check member status
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

-- RPC for first-run admin claiming a new household
CREATE OR REPLACE FUNCTION public.claim_household(new_household_name TEXT, user_name TEXT, user_role TEXT)
RETURNS UUID AS $$
DECLARE
  new_hh_id UUID;
BEGIN
  -- Insert household
  INSERT INTO public.households (name) VALUES (new_household_name) RETURNING id INTO new_hh_id;
  
  -- Insert member as admin
  INSERT INTO public.household_members (household_id, user_id, name, role, is_admin)
  VALUES (new_hh_id, auth.uid(), user_name, user_role, TRUE);
  
  -- Insert default config
  INSERT INTO public.household_themes (household_id) VALUES (new_hh_id);
  INSERT INTO public.forecast_settings (household_id) VALUES (new_hh_id);

  RETURN new_hh_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- RLS POLICIES
-- ==============================================================================

-- households
CREATE POLICY "Members can view their household" ON public.households
    FOR SELECT USING (public.is_household_member(id));
CREATE POLICY "Admins can update their household" ON public.households
    FOR UPDATE USING (public.is_household_admin(id));

-- household_members
CREATE POLICY "Members can view other members" ON public.household_members
    FOR SELECT USING (public.is_household_member(household_id));
CREATE POLICY "Admins can manage members" ON public.household_members
    FOR ALL USING (public.is_household_admin(household_id));

-- Admin CMS Settings (Themes, Labels, Forecast)
CREATE POLICY "Members can view themes" ON public.household_themes FOR SELECT USING (public.is_household_member(household_id));
CREATE POLICY "Admins can manage themes" ON public.household_themes FOR ALL USING (public.is_household_admin(household_id));

CREATE POLICY "Members can view labels" ON public.ui_labels FOR SELECT USING (public.is_household_member(household_id));
CREATE POLICY "Admins can manage labels" ON public.ui_labels FOR ALL USING (public.is_household_admin(household_id));

CREATE POLICY "Members can view forecast settings" ON public.forecast_settings FOR SELECT USING (public.is_household_member(household_id));
CREATE POLICY "Admins can manage forecast settings" ON public.forecast_settings FOR ALL USING (public.is_household_admin(household_id));

-- General Data Tables (Cycles, Incomes, Spends, etc. - Members can manage these)
CREATE POLICY "Members can manage cycles" ON public.cycles FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage incomes" ON public.income_entries FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage fixed payments" ON public.fixed_payments FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage installments" ON public.installment_plans FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage credit cards" ON public.credit_cards FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage subscriptions" ON public.subscriptions FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage wishlist" ON public.wishlist_items FOR ALL USING (public.is_household_member(household_id));
CREATE POLICY "Members can manage daily spends" ON public.daily_spends FOR ALL USING (public.is_household_member(household_id));
