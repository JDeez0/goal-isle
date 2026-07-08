-- ============================================================
-- GOAL ISLE — RLS Policy Fix
-- Run this in the Supabase SQL Editor AFTER the main schema.
-- This re-enables RLS on all tables with corrected policies.
-- ============================================================

-- Drop ALL existing policies (clean slate)
DROP POLICY IF EXISTS "profiles_read" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "isles_read" ON public.isles;
DROP POLICY IF EXISTS "isles_insert" ON public.isles;
DROP POLICY IF EXISTS "isles_update" ON public.isles;
DROP POLICY IF EXISTS "isles_delete" ON public.isles;
DROP POLICY IF EXISTS "memberships_read" ON public.memberships;
DROP POLICY IF EXISTS "memberships_insert" ON public.memberships;
DROP POLICY IF EXISTS "memberships_delete" ON public.memberships;
DROP POLICY IF EXISTS "sparks_read" ON public.sparks;
DROP POLICY IF EXISTS "sparks_insert" ON public.sparks;
DROP POLICY IF EXISTS "sparks_update" ON public.sparks;
DROP POLICY IF EXISTS "deps_read" ON public.dependencies;
DROP POLICY IF EXISTS "deps_insert" ON public.dependencies;
DROP POLICY IF EXISTS "deps_update" ON public.dependencies;
DROP POLICY IF EXISTS "deps_delete" ON public.dependencies;
DROP POLICY IF EXISTS "messages_read" ON public.messages;
DROP POLICY IF EXISTS "messages_insert" ON public.messages;
DROP POLICY IF EXISTS "messages_update" ON public.messages;
DROP POLICY IF EXISTS "posts_read" ON public.posts;
DROP POLICY IF EXISTS "posts_insert" ON public.posts;
DROP POLICY IF EXISTS "friends_read" ON public.friends;
DROP POLICY IF EXISTS "friends_insert" ON public.friends;
DROP POLICY IF EXISTS "friends_update" ON public.friends;
DROP POLICY IF EXISTS "friends_delete" ON public.friends;

-- Recreate the is_member helper (ensure it exists and is correct)
CREATE OR REPLACE FUNCTION public.is_member(isle_uuid text)
RETURNS boolean AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.memberships
    WHERE isle_id = isle_uuid AND user_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- PROFILES
CREATE POLICY "profiles_read" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id);
-- Allow users to insert their own profile (the trigger does it, but just in case)
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ISLES — re-enable RLS with correct policies
ALTER TABLE public.isles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "isles_read" ON public.isles FOR SELECT USING (
  visibility = 'public' OR public.is_member(id)
);
CREATE POLICY "isles_insert" ON public.isles FOR INSERT WITH CHECK (created_by = auth.uid());
CREATE POLICY "isles_update" ON public.isles FOR UPDATE USING (created_by = auth.uid());
CREATE POLICY "isles_delete" ON public.isles FOR DELETE USING (created_by = auth.uid());

-- MEMBERSHIPS — re-enable RLS
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
CREATE POLICY "memberships_read" ON public.memberships FOR SELECT USING (public.is_member(isle_id));
CREATE POLICY "memberships_insert" ON public.memberships FOR INSERT WITH CHECK (
  user_id = auth.uid()
  OR EXISTS (SELECT 1 FROM public.isles WHERE id = isle_id AND created_by = auth.uid())
);
CREATE POLICY "memberships_delete" ON public.memberships FOR DELETE USING (
  user_id = auth.uid()
  OR EXISTS (SELECT 1 FROM public.isles WHERE id = isle_id AND created_by = auth.uid())
);

-- SPARKS
ALTER TABLE public.sparks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sparks_read" ON public.sparks FOR SELECT USING (public.is_member(isle_id));
CREATE POLICY "sparks_insert" ON public.sparks FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.isles WHERE id = isle_id AND created_by = auth.uid())
);
CREATE POLICY "sparks_update" ON public.sparks FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.isles i WHERE i.id = sparks.isle_id AND i.created_by = auth.uid())
);
CREATE POLICY "sparks_delete" ON public.sparks FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.isles i WHERE i.id = sparks.isle_id AND i.created_by = auth.uid())
);

-- DEPENDENCIES
ALTER TABLE public.dependencies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "deps_read" ON public.dependencies FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.sparks s, public.isles i WHERE s.id = dependencies.spark_id AND i.id = s.isle_id AND public.is_member(i.id))
);
CREATE POLICY "deps_insert" ON public.dependencies FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.sparks s, public.isles i WHERE s.id = dependencies.spark_id AND i.id = s.isle_id AND i.created_by = auth.uid())
);
CREATE POLICY "deps_update" ON public.dependencies FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.sparks s, public.isles i WHERE s.id = dependencies.spark_id AND i.id = s.isle_id AND i.created_by = auth.uid())
);

-- MESSAGES
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "messages_read" ON public.messages FOR SELECT USING (
  sender_id = auth.uid() OR public.is_member(chat_id)
);
CREATE POLICY "messages_insert" ON public.messages FOR INSERT WITH CHECK (sender_id = auth.uid());
CREATE POLICY "messages_update" ON public.messages FOR UPDATE USING (sender_id = auth.uid());

-- POSTS
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "posts_read" ON public.posts FOR SELECT USING (
  author_id = auth.uid() OR EXISTS (
    SELECT 1 FROM public.memberships WHERE user_id = auth.uid() AND (
      posts.audience[1] = 'all' OR isle_id = ANY(posts.audience)
    )
  )
);
CREATE POLICY "posts_insert" ON public.posts FOR INSERT WITH CHECK (author_id = auth.uid());

-- FRIENDS — FIXED: allow reading rows where you're either user_id OR friend_id
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
CREATE POLICY "friends_read" ON public.friends FOR SELECT USING (
  user_id = auth.uid() OR friend_id = auth.uid()
);
CREATE POLICY "friends_insert" ON public.friends FOR INSERT WITH CHECK (
  user_id = auth.uid()
);
CREATE POLICY "friends_update" ON public.friends FOR UPDATE USING (
  user_id = auth.uid()
);
CREATE POLICY "friends_delete" ON public.friends FOR DELETE USING (
  user_id = auth.uid()
);

-- ============================================================
-- DONE. All tables now have RLS enabled with correct policies.
-- ============================================================
