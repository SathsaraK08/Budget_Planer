-- ==============================================================================
-- MIGRATION PHASE 1: HomeBudget Full System Rebuild
-- Run this in Supabase SQL Editor on an existing project.
-- Safe to run multiple times (IF NOT EXISTS / OR REPLACE guards throughout).
-- ==============================================================================

-- 1. Fix setup-loop bug: add setup_completed column to households
ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS setup_completed BOOLEAN NOT NULL DEFAULT FALSE;
 
-- 2. Add app_name to households (for Appearance theme settings)
ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS app_name TEXT NOT NULL DEFAULT 'HomeBudget';

-- 1b. Add is_admin to household_members (if not already in base schema)
ALTER TABLE public.household_members
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;

-- 3. Lookup table: BNPL Platforms (replaces hardcoded list in code)
CREATE TABLE IF NOT EXISTS public.lookup_bnpl_platforms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(household_id, name)
);

-- 4. Lookup table: Expense Categories
CREATE TABLE IF NOT EXISTS public.lookup_expense_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon_name TEXT NOT NULL DEFAULT 'receipt',
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(household_id, name)
);

-- 5. Lookup table: Wishlist Categories
CREATE TABLE IF NOT EXISTS public.lookup_wishlist_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(household_id, name)
);

-- 6. AI Settings table (replaces gemini_api_key on households)
CREATE TABLE IF NOT EXISTS public.ai_settings (
    household_id UUID PRIMARY KEY REFERENCES public.households(id) ON DELETE CASCADE,
    provider TEXT NOT NULL DEFAULT 'none', -- 'gemini' | 'openai' | 'none'
    api_key TEXT,                           -- encrypted at rest by Supabase Vault ideally
    custom_instructions TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Enable RLS on new tables
ALTER TABLE public.lookup_bnpl_platforms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lookup_expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lookup_wishlist_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_settings ENABLE ROW LEVEL SECURITY;

-- 8. RLS Policies for lookup tables
-- PostgreSQL does not support CREATE POLICY IF NOT EXISTS,
-- so we DROP first then CREATE to make this script re-runnable.

DROP POLICY IF EXISTS "Members can view BNPL platforms"     ON public.lookup_bnpl_platforms;
DROP POLICY IF EXISTS "Admins can manage BNPL platforms"    ON public.lookup_bnpl_platforms;
DROP POLICY IF EXISTS "Members can view expense categories" ON public.lookup_expense_categories;
DROP POLICY IF EXISTS "Admins can manage expense categories" ON public.lookup_expense_categories;
DROP POLICY IF EXISTS "Members can view wishlist categories" ON public.lookup_wishlist_categories;
DROP POLICY IF EXISTS "Admins can manage wishlist categories" ON public.lookup_wishlist_categories;
DROP POLICY IF EXISTS "Members can view AI settings"        ON public.ai_settings;
DROP POLICY IF EXISTS "Admins can manage AI settings"       ON public.ai_settings;

CREATE POLICY "Members can view BNPL platforms"
  ON public.lookup_bnpl_platforms FOR SELECT
  USING (public.is_household_member(household_id));

CREATE POLICY "Admins can manage BNPL platforms"
  ON public.lookup_bnpl_platforms FOR ALL
  USING (public.is_household_admin(household_id));

CREATE POLICY "Members can view expense categories"
  ON public.lookup_expense_categories FOR SELECT
  USING (public.is_household_member(household_id));

CREATE POLICY "Admins can manage expense categories"
  ON public.lookup_expense_categories FOR ALL
  USING (public.is_household_admin(household_id));

CREATE POLICY "Members can view wishlist categories"
  ON public.lookup_wishlist_categories FOR SELECT
  USING (public.is_household_member(household_id));

CREATE POLICY "Admins can manage wishlist categories"
  ON public.lookup_wishlist_categories FOR ALL
  USING (public.is_household_admin(household_id));

CREATE POLICY "Members can view AI settings"
  ON public.ai_settings FOR SELECT
  USING (public.is_household_member(household_id));

CREATE POLICY "Admins can manage AI settings"
  ON public.ai_settings FOR ALL
  USING (public.is_household_admin(household_id));

-- 9. Update claim_household RPC to seed lookup tables and ai_settings
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
  -- Insert household (setup_completed starts FALSE — wizard must complete it)
  INSERT INTO public.households (name, setup_completed)
  VALUES (new_household_name, FALSE)
  RETURNING id INTO new_hh_id;

  -- Insert registering user as admin
  INSERT INTO public.household_members (household_id, user_id, name, role, is_admin)
  VALUES (new_hh_id, auth.uid(), user_name, 'admin', TRUE);

  -- If partner name provided, add as member (no user_id yet — they sign up separately)
  IF partner_name IS NOT NULL AND partner_name != '' THEN
    INSERT INTO public.household_members (household_id, name, role, is_admin, avatar_color)
    VALUES (new_hh_id, partner_name, 'member', FALSE, '#EC4899');
  END IF;

  -- Seed default config tables
  INSERT INTO public.household_themes (household_id) VALUES (new_hh_id)
    ON CONFLICT (household_id) DO NOTHING;
  INSERT INTO public.forecast_settings (household_id) VALUES (new_hh_id)
    ON CONFLICT (household_id) DO NOTHING;
  INSERT INTO public.ai_settings (household_id) VALUES (new_hh_id)
    ON CONFLICT (household_id) DO NOTHING;

  -- Seed default BNPL platforms
  INSERT INTO public.lookup_bnpl_platforms (household_id, name, sort_order)
  VALUES
    (new_hh_id, 'Koko', 1),
    (new_hh_id, 'Mintpay', 2),
    (new_hh_id, 'PayZy', 3),
    (new_hh_id, 'Frimi', 4),
    (new_hh_id, 'Other', 5);

  -- Seed default expense categories
  INSERT INTO public.lookup_expense_categories (household_id, name, icon_name, sort_order)
  VALUES
    (new_hh_id, 'Groceries', 'shopping_basket', 1),
    (new_hh_id, 'Food & Dining', 'restaurant', 2),
    (new_hh_id, 'Transport / PickMe', 'directions_car', 3),
    (new_hh_id, 'Health & Gym', 'favorite', 4),
    (new_hh_id, 'Personal Care & Saloon', 'spa', 5),
    (new_hh_id, 'Entertainment', 'movie', 6),
    (new_hh_id, 'Clothing & Fashion', 'checkroom', 7),
    (new_hh_id, 'Home & Household', 'home', 8),
    (new_hh_id, 'Education', 'school', 9),
    (new_hh_id, 'Other / Cash Reserve', 'wallet', 10);

  -- Seed default wishlist categories
  INSERT INTO public.lookup_wishlist_categories (household_id, name, sort_order)
  VALUES
    (new_hh_id, 'Kitchen', 1),
    (new_hh_id, 'Bathroom', 2),
    (new_hh_id, 'Electronics', 3),
    (new_hh_id, 'Clothing', 4),
    (new_hh_id, 'Home Appliances', 5),
    (new_hh_id, 'Other', 6);

  RETURN new_hh_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Function to mark setup as complete (called by wizard on final step)
CREATE OR REPLACE FUNCTION public.complete_setup(p_household_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.households
  SET setup_completed = TRUE
  WHERE id = p_household_id
  AND public.is_household_admin(p_household_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Function: safe member delete with FK guard
--     Returns 'deleted' if successful, 'blocked' if member has existing records
CREATE OR REPLACE FUNCTION public.safe_delete_member(p_member_id UUID, p_household_id UUID)
RETURNS TEXT AS $$
DECLARE
  spend_count INT;
  income_count INT;
BEGIN
  -- Check caller is admin of this household
  IF NOT public.is_household_admin(p_household_id) THEN
    RETURN 'unauthorized';
  END IF;

  -- Check for FK-linked records
  SELECT COUNT(*) INTO spend_count FROM public.daily_spends WHERE member_id = p_member_id;
  SELECT COUNT(*) INTO income_count FROM public.income_entries WHERE member_id = p_member_id;

  IF spend_count > 0 OR income_count > 0 THEN
    RETURN 'blocked:' || (spend_count + income_count)::TEXT;
  END IF;

  DELETE FROM public.household_members WHERE id = p_member_id AND household_id = p_household_id;
  RETURN 'deleted';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
