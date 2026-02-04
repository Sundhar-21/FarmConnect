-- ========================================================
-- EMERGENCY FIX: DISABLE TRIGGER & ALLOW CLIENT INSERT
-- ========================================================

-- 1. KILL THE TRIGGER (It causes the 500 Error)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. ALLOW FLUTTER TO INSERT PROFILES
-- We need to let the app write to these tables since the database won't do it anymore
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farmer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consumer_profiles ENABLE ROW LEVEL SECURITY;

-- Reset policies to be very permissive for the authenticated user
DROP POLICY IF EXISTS "allow_all_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_farmer_profiles" ON farmer_profiles;
DROP POLICY IF EXISTS "allow_all_consumer_profiles" ON consumer_profiles;

CREATE POLICY "allow_insert_own_profile" ON profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

CREATE POLICY "allow_insert_own_farmer" ON farmer_profiles FOR INSERT 
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "allow_insert_own_consumer" ON consumer_profiles FOR INSERT 
WITH CHECK (profile_id = auth.uid());

-- 3. ENSURE SELECT WORKS
CREATE POLICY "allow_select_own_profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "allow_select_own_farmer" ON farmer_profiles FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "allow_select_own_consumer" ON consumer_profiles FOR SELECT USING (profile_id = auth.uid());
