-- 1. DROP the old trigger and function to be safe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Create the MASTER FUNCTION that handles everything
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  new_role user_role;
BEGIN
  -- Determine Role safely
  BEGIN
    IF (NEW.raw_user_meta_data->>'role') = 'farmer' THEN
      new_role := 'farmer';
    ELSIF (NEW.raw_user_meta_data->>'role') = 'admin' THEN
      new_role := 'admin';
    ELSE
      new_role := 'consumer';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    new_role := 'consumer';
  END;

  -- A. Insert into PROFILES
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
    new_role
  );

  -- B. Insert into SUB-TABLES based on role
  IF new_role = 'farmer' THEN
    INSERT INTO public.farmer_profiles (profile_id, farm_name, farm_location)
    VALUES (NEW.id, 'My Default Farm', 'Unknown Location');
  ELSIF new_role = 'consumer' THEN
    INSERT INTO public.consumer_profiles (profile_id)
    VALUES (NEW.id);
  END IF;

  RETURN NEW;
END;
$$;

-- 3. Re-attach the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. CLEANUP (Optional: If you want to start 100% fresh)
-- DELETE FROM auth.users; -- Warning: Deletes ALL users!
