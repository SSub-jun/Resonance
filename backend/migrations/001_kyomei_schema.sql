-- Kyomei schema v1
-- Run in Supabase Dashboard -> SQL Editor against the Annex project
-- (pjbrvkzyxnjhhifqkdyz) or a dedicated Kyomei project.
-- Tables are prefixed with kyomei_ so they coexist cleanly with Annex data.

-- =========================================================
-- Tables
-- =========================================================

CREATE TABLE IF NOT EXISTS public.kyomei_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.kyomei_resonance_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.kyomei_users(id) ON DELETE CASCADE,
    occurred_at TIMESTAMPTZ NOT NULL,
    resonance_type TEXT NOT NULL CHECK (resonance_type IN ('same_song', 'same_artist')),
    raw_title TEXT,
    normalized_title TEXT,
    raw_artist TEXT,
    normalized_artist TEXT,
    my_latitude DOUBLE PRECISION,
    my_longitude DOUBLE PRECISION,
    app_version TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================
-- Indexes
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_kyomei_events_user_occurred
    ON public.kyomei_resonance_events (user_id, occurred_at DESC);

CREATE INDEX IF NOT EXISTS idx_kyomei_events_type
    ON public.kyomei_resonance_events (resonance_type);

CREATE INDEX IF NOT EXISTS idx_kyomei_events_normalized_title
    ON public.kyomei_resonance_events (normalized_title);

CREATE INDEX IF NOT EXISTS idx_kyomei_events_normalized_artist
    ON public.kyomei_resonance_events (normalized_artist);

-- =========================================================
-- Row-Level Security
-- =========================================================
-- MVP policy: allow the anon role to upsert/read/delete on both tables.
-- Kyomei has no login yet; device_id is the only identity. Tighten once
-- Supabase Auth is wired in.

ALTER TABLE public.kyomei_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kyomei_resonance_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "kyomei_users_anon_select" ON public.kyomei_users;
DROP POLICY IF EXISTS "kyomei_users_anon_insert" ON public.kyomei_users;

CREATE POLICY "kyomei_users_anon_select" ON public.kyomei_users
    FOR SELECT TO anon USING (true);

CREATE POLICY "kyomei_users_anon_insert" ON public.kyomei_users
    FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS "kyomei_events_anon_select" ON public.kyomei_resonance_events;
DROP POLICY IF EXISTS "kyomei_events_anon_insert" ON public.kyomei_resonance_events;
DROP POLICY IF EXISTS "kyomei_events_anon_delete" ON public.kyomei_resonance_events;

CREATE POLICY "kyomei_events_anon_select" ON public.kyomei_resonance_events
    FOR SELECT TO anon USING (true);

CREATE POLICY "kyomei_events_anon_insert" ON public.kyomei_resonance_events
    FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "kyomei_events_anon_delete" ON public.kyomei_resonance_events
    FOR DELETE TO anon USING (true);
