-- =================================================================
-- MASTER FIX SCRIPT (Run this ONCE to fix everything)
-- =================================================================

-- 1. ENUMS
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('farmer', 'consumer', 'admin');
  END IF;
END $$;

-- 2. CREATE TABLES (Safe if they exist)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'consumer',
    full_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.farmer_profiles (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    farm_name TEXT,
    farm_location TEXT
);

CREATE TABLE IF NOT EXISTS public.consumer_profiles (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.categories (
    id BIGSERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.products (
    id BIGSERIAL PRIMARY KEY,
    farmer_id UUID REFERENCES profiles(id) NOT NULL,
    category_id BIGINT REFERENCES categories(id) NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    unit TEXT DEFAULT 'kg',
    is_available BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SEED CATEGORIES (Fixes the Dropdown!)
INSERT INTO public.categories (name) VALUES 
('Vegetables'), ('Fruits'), ('Dairy'), ('Grains'), ('Meat'), ('Other')
ON CONFLICT (name) DO NOTHING;

-- 4. RLS POLICIES (Reset to "Allow All" for logged in users to fix save errors)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE farmer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Clear old policies
DROP POLICY IF EXISTS "allow_all_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_farmer_profiles" ON farmer_profiles;
DROP POLICY IF EXISTS "allow_all_consumer_profiles" ON consumer_profiles;
DROP POLICY IF EXISTS "allow_all_products" ON products;
DROP POLICY IF EXISTS "allow_read_categories" ON categories;

-- Add simple permissive policies
CREATE POLICY "allow_all_profiles" ON profiles FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "allow_all_farmer_profiles" ON farmer_profiles FOR ALL USING (profile_id = auth.uid()) WITH CHECK (profile_id = auth.uid());
CREATE POLICY "allow_all_consumer_profiles" ON consumer_profiles FOR ALL USING (profile_id = auth.uid()) WITH CHECK (profile_id = auth.uid());
CREATE POLICY "allow_all_products" ON products FOR ALL USING (true) WITH CHECK (auth.uid() = farmer_id);
CREATE POLICY "allow_read_categories" ON categories FOR SELECT USING (true); -- Everyone can see categories

-- 5. BULLETPROOF TRIGGER (Fixes Signup)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  final_role user_role;
BEGIN
  -- Safe Role Logic
  BEGIN
    IF (NEW.raw_user_meta_data->>'role') = 'farmer' THEN final_role := 'farmer';
    ELSIF (NEW.raw_user_meta_data->>'role') = 'admin' THEN final_role := 'admin';
    ELSE final_role := 'consumer';
    END IF;
  EXCEPTION WHEN OTHERS THEN final_role := 'consumer';
  END;

  -- Create Main Profile
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Member'), final_role)
  ON CONFLICT (id) DO NOTHING;

  -- Create Sub Profile
  IF final_role = 'farmer' THEN
    INSERT INTO public.farmer_profiles (profile_id, farm_name) VALUES (NEW.id, 'My Farm') ON CONFLICT (profile_id) DO NOTHING;
  ELSIF final_role = 'consumer' THEN
    INSERT INTO public.consumer_profiles (profile_id) VALUES (NEW.id) ON CONFLICT (profile_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

