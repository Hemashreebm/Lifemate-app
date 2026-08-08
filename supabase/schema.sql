-- =============================================================================
-- LIFEMATE v2.0 SUPABASE DEVELOPMENT DATABASE SCHEMA & RLS POLICIES
-- =============================================================================
-- Environment: Development / Testing
-- Production Authentication: Remaining on Firebase Auth & Firestore
-- Scoped to Authenticated User UUIDs (auth.uid())
-- =============================================================================

-- 1. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    preferred_language TEXT DEFAULT 'English',
    nickname TEXT,
    age TEXT,
    gender TEXT,
    state TEXT,
    district TEXT,
    occupation TEXT DEFAULT 'Student',
    education_level TEXT,
    employment_status TEXT,
    income_range TEXT,
    is_student BOOLEAN DEFAULT false,
    is_farmer BOOLEAN DEFAULT false,
    is_business BOOLEAN DEFAULT false,
    completeness INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile" ON public.profiles
    FOR DELETE USING (auth.uid() = user_id);

-- 2. TASKS TABLE
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own tasks" ON public.tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own tasks" ON public.tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own tasks" ON public.tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own tasks" ON public.tasks FOR DELETE USING (auth.uid() = user_id);

-- 3. DIARY ENTRIES TABLE
CREATE TABLE IF NOT EXISTS public.diary_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    mood TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own diary" ON public.diary_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own diary" ON public.diary_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own diary" ON public.diary_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own diary" ON public.diary_entries FOR DELETE USING (auth.uid() = user_id);

-- 4. EXPENSES TABLE
CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    amount NUMERIC(12,2) NOT NULL,
    category TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'expense',
    merchant TEXT,
    date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own expenses" ON public.expenses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own expenses" ON public.expenses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own expenses" ON public.expenses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own expenses" ON public.expenses FOR DELETE USING (auth.uid() = user_id);

-- 5. SETTINGS TABLE
CREATE TABLE IF NOT EXISTS public.settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    theme_mode TEXT DEFAULT 'system',
    auto_sms_tracking BOOLEAN DEFAULT false,
    cloud_sync BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own settings" ON public.settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own settings" ON public.settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON public.settings FOR UPDATE USING (auth.uid() = user_id);

-- 6. COMMUNICATION PROGRESS TABLE
CREATE TABLE IF NOT EXISTS public.communication_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    streak_count INT DEFAULT 0,
    words_learned INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.communication_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own comm progress" ON public.communication_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own comm progress" ON public.communication_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comm progress" ON public.communication_progress FOR UPDATE USING (auth.uid() = user_id);

-- 7. HABITS TABLE
CREATE TABLE IF NOT EXISTS public.habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    frequency TEXT DEFAULT 'daily',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can select own habits" ON public.habits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own habits" ON public.habits FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own habits" ON public.habits FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own habits" ON public.habits FOR DELETE USING (auth.uid() = user_id);

-- 8. GOVERNMENT SCHEMES TABLE (Public Verified Data Source)
CREATE TABLE IF NOT EXISTS public.government_schemes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    government_department TEXT,
    category TEXT,
    state TEXT DEFAULT 'Central',
    benefits TEXT,
    eligibility TEXT,
    required_documents JSONB DEFAULT '[]'::jsonb,
    application_steps JSONB DEFAULT '[]'::jsonb,
    official_website_url TEXT,
    target_groups JSONB DEFAULT '[]'::jsonb,
    income_criteria TEXT DEFAULT 'N/A',
    age_criteria TEXT DEFAULT 'All ages',
    education_criteria TEXT DEFAULT 'N/A',
    last_verified_at TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.government_schemes ENABLE ROW LEVEL SECURITY;

-- Anyone (authenticated or anon) can read verified government schemes
CREATE POLICY "Public read verified schemes" ON public.government_schemes FOR SELECT USING (true);

-- =============================================================================
-- SECURITY VERIFICATION TEST QUERIES
-- =============================================================================
-- Test 1: User A cannot select User B's profile
-- SELECT * FROM public.profiles WHERE user_id = 'user_b_uuid'; -- (Returns 0 rows under User A JWT)
-- Test 2: User A cannot insert tasks under User B's UUID
-- INSERT INTO public.tasks (user_id, title) VALUES ('user_b_uuid', 'Hack Task'); -- (Rejected by RLS CHECK constraint)
