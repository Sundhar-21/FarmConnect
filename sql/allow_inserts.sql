-- 1. Essential: Allow users to INSERT their own profile (Fallback for failed triggers)
CREATE POLICY "user_insert_own_profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- 2. Essential: Allow users to INSERT their own sub-profiles
CREATE POLICY "farmer_insert_own_profile" 
ON public.farmer_profiles FOR INSERT 
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "consumer_insert_own_profile" 
ON public.consumer_profiles FOR INSERT 
WITH CHECK (profile_id = auth.uid());

-- 3. Ensure the ENUM exists (Idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('farmer', 'consumer', 'admin');
  END IF;
END$$;
