-- ============================================================
-- GOAL ISLE — Re-enable RLS on isles + memberships
-- Run this in the Supabase SQL Editor.
--
-- RLS was disabled on these two tables during debugging.
-- The original policies (from supabase_schema.sql) are still in place
-- and correct — they use is_isle_creator() (SECURITY DEFINER) to solve
-- the chicken-and-egg problem of isle creation.
--
-- The data persistence bug that caused us to disable RLS was actually
-- caused by mock UUIDs leaking into Supabase queries (fixed in
-- mock_providers.dart), NOT by the RLS policies themselves.
-- ============================================================

-- Re-enable RLS on the two tables that had it disabled
ALTER TABLE public.isles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;

-- Verify RLS is enabled on all tables
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Verify the key policies exist (should return 4 rows for isles, 3 for memberships)
SELECT tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('isles', 'memberships')
ORDER BY tablename, policyname;
