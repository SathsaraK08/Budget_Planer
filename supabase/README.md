# Supabase Backend Setup Guide (Free Tier)

This application uses Supabase for Postgres storage, Authentication, and Realtime instant synchronization between the two household members (husband and wife).

---

## 1. Create your Free Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and log in / create a free account.
2. Click **New Project** and name it `Household Budget Planner`.
3. Choose your nearest region (e.g. `Singapore` or `Mumbai` for Sri Lanka / South Asia).
4. Set a database password and click **Create New Project**.

---

## 2. Apply the Database Schema & Seed Data

1. In your Supabase Dashboard, click on the **SQL Editor** tab (icon `>_` on the left sidebar).
2. Click **New Query**.
3. Copy the entire contents of [`supabase_schema.sql`](file:///./supabase_schema.sql) and paste it into the editor.
4. Click **Run** (or press `Ctrl+Enter`).
   - This creates all 10 tables, enables Row Level Security (RLS), creates indices, and enables Supabase Realtime for instant multi-device syncing.
5. (Optional for instant demo data) Open another query, copy [`supabase_seed_sample.sql`](file:///./supabase_seed_sample.sql), and click **Run**.

---

## 3. Copy API Keys into Flutter App

1. In Supabase Dashboard, go to **Project Settings** (gear icon) -> **API**.
2. Copy:
   - **Project URL** (e.g., `https://xyzcompany.supabase.co`)
   - **Anon / Public Key** (e.g., `eyJhbGciOi...`)
3. In the Budget Planner App, paste these into the **Settings -> Database Config** screen (or provide them via environment variables / `.env`).
