-- ============================================================
-- GOAL ISLE — Supabase Schema (v2)
-- Run this in the Supabase SQL Editor.
-- Creates all tables, triggers, and Row Level Security policies.
-- ============================================================

-- ============================================================
-- 1. PROFILES (extends auth.users)
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  handle text not null unique,
  avatar text not null default '🧑',
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Auto-create a profile when a user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, handle, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'handle', split_part(new.email, '@', 1)), coalesce(new.raw_user_meta_data->>'handle', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- 2. ISLES (communities)
-- ============================================================
create table if not exists public.isles (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  main_emoji text not null,
  purpose text,
  color text not null default 'blue',
  visibility text not null default 'private' check (visibility in ('public', 'private')),
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 3. MEMBERSHIPS (user ↔ isle)
-- ============================================================
create table if not exists public.memberships (
  isle_id text not null references public.isles(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  user_name text not null default '',
  user_avatar text not null default '🧑',
  role text not null default 'member' check (role in ('creator', 'member')),
  joined_at timestamptz not null default now(),
  primary key (isle_id, user_id)
);

-- ============================================================
-- 4. SPARKS (keys/rituals)
-- ============================================================
create table if not exists public.sparks (
  id text primary key default gen_random_uuid()::text,
  isle_id text not null references public.isles(id) on delete cascade,
  main_emoji text not null,
  title text,
  mode text not null default 'ritual' check (mode in ('ritual', 'metric')),
  scope text not null default 'shared' check (scope in ('shared', 'personal')),
  shape jsonb not null default '{"tl":0.4,"tr":0.12,"br":0.4,"bl":0.12}',
  state text not null default 'dull' check (state in ('dull','lit','streaked','greyed')),
  streak int not null default 0,
  timer_mode text not null default 'daily' check (timer_mode in ('instant','daily','weekly','monthly')),
  streak_breaks_on_miss boolean not null default true,
  metric jsonb,
  is_main boolean not null default false,
  last_completed_at timestamptz,
  cycle_due_at timestamptz,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 5. DEPENDENCIES (ritual spark ingredients)
-- ============================================================
create table if not exists public.dependencies (
  id text primary key default gen_random_uuid()::text,
  spark_id text not null references public.sparks(id) on delete cascade,
  emoji text not null,
  label text,
  satisfied boolean not null default false,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 6. MESSAGES (chat + per-spark thread)
-- ============================================================
create table if not exists public.messages (
  id text primary key default gen_random_uuid()::text,
  chat_id text not null,
  sender_id uuid not null references auth.users(id) on delete cascade,
  sender_name text not null default '',
  sender_avatar text not null default '🧑',
  content text,
  big text,
  content_type text not null default 'text',
  reactions jsonb not null default '[]'::jsonb,
  image_url text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 7. POSTS (broadcasts)
-- ============================================================
create table if not exists public.posts (
  id text primary key default gen_random_uuid()::text,
  author_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null default '',
  author_avatar text not null default '🧑',
  text text,
  emoji text,
  image_url text,
  audience text[] not null default '{}',
  created_at timestamptz not null default now()
);

-- ============================================================
-- 8. FRIENDS (friend requests)
-- ============================================================
create table if not exists public.friends (
  id text primary key default gen_random_uuid()::text,
  user_id uuid not null references auth.users(id) on delete cascade,
  friend_id uuid references auth.users(id) on delete cascade,
  friend_name text not null default '',
  friend_avatar text not null default '🧑',
  status text not null default 'pending_out' check (status in ('accepted','pending_in','pending_out')),
  created_at timestamptz not null default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table public.profiles enable row level security;
alter table public.isles enable row level security;
alter table public.memberships enable row level security;
alter table public.sparks enable row level security;
alter table public.dependencies enable row level security;
alter table public.messages enable row level security;
alter table public.posts enable row level security;
alter table public.friends enable row level security;

-- Helper: is the current user a member of an isle?
create or replace function public.is_member(isle_uuid text)
returns boolean as $$
  select exists(
    select 1 from public.memberships
    where isle_id = isle_uuid and user_id = auth.uid()
  );
$$ language sql security definer stable;

-- PROFILES: read all, update own
create policy "profiles_read" on public.profiles for select using (true);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- ISLES: read if member or public; insert by anyone (creator); update by creator; delete by creator
create policy "isles_read" on public.isles for select using (
  visibility = 'public' or public.is_member(id)
);
create policy "isles_insert" on public.isles for insert with check (created_by = auth.uid());
create policy "isles_update" on public.isles for update using (created_by = auth.uid());
create policy "isles_delete" on public.isles for delete using (created_by = auth.uid());

-- MEMBERSHIPS: read if member of that isle; insert by isle creator or self-join; delete by creator or self-leave
create policy "memberships_read" on public.memberships for select using (public.is_member(isle_id));
create policy "memberships_insert" on public.memberships for insert with check (
  user_id = auth.uid() or exists(
    select 1 from public.isles where id = isle_id and created_by = auth.uid()
  )
);
create policy "memberships_delete" on public.memberships for delete using (
  user_id = auth.uid() or exists(
    select 1 from public.isles where id = isle_id and created_by = auth.uid()
  )
);

-- SPARKS: read if member of parent isle; insert/update/delete by isle creator
create policy "sparks_read" on public.sparks for select using (public.is_member(isle_id));
create policy "sparks_insert" on public.sparks for insert with check (
  exists(select 1 from public.isles where id = isle_id and created_by = auth.uid())
);
create policy "sparks_update" on public.sparks for update using (
  exists(select 1 from public.isles i where i.id = sparks.isle_id and i.created_by = auth.uid())
);

-- DEPENDENCIES: same as sparks (through parent spark → isle)
create policy "deps_read" on public.dependencies for select using (
  exists(select 1 from public.sparks s, public.isles i where s.id = dependencies.spark_id and i.id = s.isle_id and public.is_member(i.id))
);
create policy "deps_insert" on public.dependencies for insert with check (
  exists(select 1 from public.sparks s, public.isles i where s.id = dependencies.spark_id and i.id = s.isle_id and i.created_by = auth.uid())
);
create policy "deps_update" on public.dependencies for update using (
  exists(select 1 from public.sparks s, public.isles i where s.id = dependencies.spark_id and i.id = s.isle_id and i.created_by = auth.uid())
);
create policy "deps_delete" on public.dependencies for delete using (
  exists(select 1 from public.sparks s, public.isles i where s.id = dependencies.spark_id and i.id = s.isle_id and i.created_by = auth.uid())
);

-- MESSAGES: read if any member of any isle (chat_id = isle_id for isle rooms);
-- For simplicity: read if the chat_id matches an isle you're a member of, OR you sent it.
-- Insert: any authenticated user (the RLS on isle membership is the gate in practice).
create policy "messages_read" on public.messages for select using (
  sender_id = auth.uid() or public.is_member(chat_id)
);
create policy "messages_insert" on public.messages for insert with check (sender_id = auth.uid());
create policy "messages_update" on public.messages for update using (sender_id = auth.uid());

-- POSTS: read if any isle in audience includes one you're a member of, or you authored it
create policy "posts_read" on public.posts for select using (
  author_id = auth.uid() or exists(
    select 1 from public.memberships where user_id = auth.uid() and (
      posts.audience[1] = 'all' or isle_id = any(posts.audience)
    )
  )
);
create policy "posts_insert" on public.posts for insert with check (author_id = auth.uid());

-- FRIENDS: read your own; insert your own; update/delete your own
create policy "friends_read" on public.friends for select using (user_id = auth.uid());
create policy "friends_insert" on public.friends for insert with check (user_id = auth.uid());
create policy "friends_update" on public.friends for update using (user_id = auth.uid());
create policy "friends_delete" on public.friends for delete using (user_id = auth.uid());

-- ============================================================
-- DONE. Verify with: select count(*) from public.isles;
-- ============================================================
