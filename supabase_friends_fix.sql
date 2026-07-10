-- ============================================================
-- GOAL ISLE — Friends Table Fix (Bugs #8, #9, #10)
-- Run this in the Supabase SQL Editor.
--
-- Fixes:
-- #8: No unique constraint → duplicate friend rows
-- #9: acceptFriend inserts a second row instead of updating
-- #10: declineFriend/unfriend can't delete incoming-request rows
--
-- The fix uses a SYMMETRIC model: each friendship has exactly ONE row.
-- The row is owned by the REQUESTOR (user_id = person who sent the request).
-- Status: 'pending_out' (sent, not yet accepted) or 'accepted'.
-- Incoming requests (where you are friend_id) are read but not owned.
-- ============================================================

-- Clean up any existing duplicate rows before adding the constraint.
-- Keep only the most recent row per (user_id, friend_id) pair.
DELETE FROM public.friends
WHERE id NOT IN (
  SELECT DISTINCT ON (user_id, friend_id) id
  FROM public.friends
  ORDER BY user_id, friend_id, created_at DESC
);

-- Make friend_id NOT NULL (it should always be set for a real friendship)
ALTER TABLE public.friends ALTER COLUMN friend_id SET NOT NULL;

-- Add unique constraint to prevent duplicates (Bug #8)
ALTER TABLE public.friends
  DROP CONSTRAINT IF EXISTS friends_user_friend_unique;
ALTER TABLE public.friends
  ADD CONSTRAINT friends_user_friend_unique UNIQUE (user_id, friend_id);

-- Update RLS policies to fix Bug #10:
-- Allow deleting a friend row if you're EITHER the user_id (you sent it)
-- OR the friend_id (someone sent it to you).
DROP POLICY IF EXISTS "friends_delete" ON public.friends;
CREATE POLICY "friends_delete" ON public.friends FOR DELETE USING (
  user_id = auth.uid() OR friend_id = auth.uid()
);

-- Allow updating a friend row if you're the friend_id (the person ACCEPTING)
-- This fixes Bug #9: acceptFriend can now UPDATE the original row's status
-- instead of inserting a second row.
DROP POLICY IF EXISTS "friends_update" ON public.friends;
CREATE POLICY "friends_update" ON public.friends FOR UPDATE USING (
  user_id = auth.uid() OR friend_id = auth.uid()
);

-- Verify
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'friends'
ORDER BY cmd, policyname;
