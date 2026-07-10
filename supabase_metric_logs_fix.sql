-- ============================================================
-- GOAL ISLE — Metric Log Thread Persistence (Bug #5)
-- Run this in the Supabase SQL Editor.
--
-- Metric logs are stored as messages with chat_id = 'thread-<spark_id>'
-- and content_type = 'metric_log'. This updates the messages_read RLS
-- policy to allow isle members to read thread messages for sparks in
-- their isles.
-- ============================================================

-- Update messages_read to allow reading metric-log thread messages.
-- Thread messages have chat_id = 'thread-<spark_id>'. An isle member
-- should be able to read them if they're a member of the isle that
-- owns the spark.
DROP POLICY IF EXISTS "messages_read" ON public.messages;
CREATE POLICY "messages_read" ON public.messages FOR SELECT USING (
  sender_id = auth.uid()
  OR public.is_member(chat_id)
  OR (
    chat_id LIKE 'thread-%'
    AND EXISTS (
      SELECT 1 FROM public.sparks s
      WHERE s.id = substring(chat_id from 8)
      AND public.is_member(s.isle_id)
    )
  )
);

-- Verify
SELECT tablename, policyname
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'messages'
ORDER BY policyname;
