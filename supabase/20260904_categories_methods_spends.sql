-- ==============================================================================
-- HomeBudget Supabase Migration: Categories, Payment Methods & Daily Spends
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/_/sql
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Expense Categories Table
CREATE TABLE IF NOT EXISTS public.expense_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id TEXT NOT NULL DEFAULT 'default',
    name TEXT NOT NULL,
    monthly_budget NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    color TEXT NOT NULL DEFAULT '#10B981',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Payment Methods Table
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id TEXT NOT NULL DEFAULT 'default',
    name TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'other', -- 'cash', 'card', 'bank', 'wallet', 'other'
    icon TEXT NOT NULL DEFAULT '💳',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Daily Spends Table (Variable Day-to-Day Expenses)
CREATE TABLE IF NOT EXISTS public.daily_spends (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id TEXT NOT NULL DEFAULT 'default',
    member_id TEXT,
    paid_by_name TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    category TEXT NOT NULL DEFAULT 'Groceries',
    payment_method TEXT NOT NULL DEFAULT 'Cash',
    payment_bank TEXT,
    title TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_spends ENABLE ROW LEVEL SECURITY;

-- 5. Drop existing policies if any
DROP POLICY IF EXISTS "allow_all_categories" ON public.expense_categories;
DROP POLICY IF EXISTS "allow_all_payment_methods" ON public.payment_methods;
DROP POLICY IF EXISTS "allow_all_daily_spends" ON public.daily_spends;

-- 6. Add RLS Policies (User-isolated or Household-scoped)
CREATE POLICY "allow_all_categories" ON public.expense_categories
    FOR ALL USING (household_id = auth.uid()::text OR household_id = 'default')
    WITH CHECK (household_id = auth.uid()::text OR household_id = 'default');

CREATE POLICY "allow_all_payment_methods" ON public.payment_methods
    FOR ALL USING (household_id = auth.uid()::text OR household_id = 'default')
    WITH CHECK (household_id = auth.uid()::text OR household_id = 'default');

CREATE POLICY "allow_all_daily_spends" ON public.daily_spends
    FOR ALL USING (household_id = auth.uid()::text OR household_id = 'default')
    WITH CHECK (household_id = auth.uid()::text OR household_id = 'default');

-- Seed Default Payment Methods if empty
INSERT INTO public.payment_methods (household_id, name, type, icon)
VALUES 
    ('default', 'Cash', 'cash', '💵'),
    ('default', 'Credit Card', 'card', '💳'),
    ('default', 'Debit Card', 'card', '💳'),
    ('default', 'Bank Transfer', 'bank', '🏦')
ON CONFLICT DO NOTHING;

-- Seed Default Expense Categories if empty
INSERT INTO public.expense_categories (household_id, name, monthly_budget, color)
VALUES
    ('default', 'Groceries', 50000.00, '#10B981'),
    ('default', 'Transport', 25000.00, '#3B82F6'),
    ('default', 'Food & Dining', 30000.00, '#F59E0B'),
    ('default', 'Personal Care', 15000.00, '#EC4899'),
    ('default', 'Health & Gym', 12000.00, '#8B5CF6'),
    ('default', 'Other', 20000.00, '#6B7280')
ON CONFLICT DO NOTHING;
