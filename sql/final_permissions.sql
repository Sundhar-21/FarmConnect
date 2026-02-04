-- ========================================================
-- FINAL PERMISSIONS FIX (Run this to fix 0 rows/Visibility)
-- ========================================================

-- 1. Enable RLS on all tables (Safety first, then open gates)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farmer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consumer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- 2. RESET ALL POLICIES (Clear old conflicting rules)
DROP POLICY IF EXISTS "allow_select_own_profile" ON profiles;
DROP POLICY IF EXISTS "allow_insert_own_profile" ON profiles;
DROP POLICY IF EXISTS "allow_all_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_read_all_profiles" ON profiles;

DROP POLICY IF EXISTS "allow_select_own_farmer" ON farmer_profiles;
DROP POLICY IF EXISTS "allow_insert_own_farmer" ON farmer_profiles;
DROP POLICY IF EXISTS "allow_read_all_farmers" ON farmer_profiles;

DROP POLICY IF EXISTS "allow_all_products" ON products;
DROP POLICY IF EXISTS "allow_read_products" ON products;
DROP POLICY IF EXISTS "allow_insert_products" ON products;

DROP POLICY IF EXISTS "allow_read_categories" ON categories;

-- DROP NEW NAMES (To prevent "Already Exists" error on re-run)
DROP POLICY IF EXISTS "public_read_profiles" ON profiles;
DROP POLICY IF EXISTS "users_insert_own_profile" ON profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;

DROP POLICY IF EXISTS "public_read_farmers" ON farmer_profiles;
DROP POLICY IF EXISTS "farmers_insert_own" ON farmer_profiles;

DROP POLICY IF EXISTS "consumers_insert_own" ON consumer_profiles;
DROP POLICY IF EXISTS "consumers_read_own" ON consumer_profiles;

DROP POLICY IF EXISTS "public_read_products" ON products;
DROP POLICY IF EXISTS "farmers_manage_products" ON products;

DROP POLICY IF EXISTS "public_read_categories" ON categories;

-- ========================================================
-- 3. CREATE NEW "OPEN" POLICIES
-- ========================================================

-- PROFILES: Everyone can READ (so we can see Farmer Names), Users INSERT their own
CREATE POLICY "public_read_profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "users_insert_own_profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "users_update_own_profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- FARMER PROFILES: Everyone can READ (Farm Details), Farmers INSERT their own
CREATE POLICY "public_read_farmers" ON farmer_profiles FOR SELECT USING (true);
CREATE POLICY "farmers_insert_own" ON farmer_profiles FOR INSERT WITH CHECK (profile_id = auth.uid());

-- CONSUMER PROFILES: Users INSERT their own
CREATE POLICY "consumers_insert_own" ON consumer_profiles FOR INSERT WITH CHECK (profile_id = auth.uid());
CREATE POLICY "consumers_read_own" ON consumer_profiles FOR SELECT USING (true); -- Or profile_id=auth.uid()

-- PRODUCTS: Everyone can READ, Farmers INSERT/UPDATE their own
CREATE POLICY "public_read_products" ON products FOR SELECT USING (true);
CREATE POLICY "farmers_manage_products" ON products FOR ALL 
USING (auth.uid() = farmer_id) 
WITH CHECK (auth.uid() = farmer_id);

-- CATEGORIES: Everyone can READ
CREATE POLICY "public_read_categories" ON categories FOR SELECT USING (true);

-- 4. EMERGENCY: Insert Categories if missing
INSERT INTO public.categories (name) VALUES 
('Vegetables'), ('Fruits'), ('Dairy'), ('Grains'), ('Meat')
ON CONFLICT (name) DO NOTHING;
