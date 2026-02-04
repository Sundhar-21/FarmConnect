-- =====================================================
-- ENUM: user_role (SAFE CREATION)
-- =====================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'user_role'
  ) THEN
    CREATE TYPE user_role AS ENUM ('farmer', 'consumer', 'admin');
  END IF;
END
$$;

-- =====================================================
-- PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'consumer',
    full_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    address TEXT,
    is_approved BOOLEAN DEFAULT FALSE,
    is_blocked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- FARMER PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS farmer_profiles (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    farm_name TEXT NOT NULL,
    farm_description TEXT,
    farm_location TEXT,
    verification_status BOOLEAN DEFAULT FALSE
);

ALTER TABLE farmer_profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CONSUMER PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS consumer_profiles (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    default_shipping_address TEXT,
    loyalty_points INTEGER DEFAULT 0
);

ALTER TABLE consumer_profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CATEGORIES
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PRODUCTS
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    farmer_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    category_id BIGINT REFERENCES categories(id),
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    unit TEXT,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CARTS
-- =====================================================
CREATE TABLE IF NOT EXISTS carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE carts ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CART ITEMS
-- =====================================================
CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id UUID REFERENCES carts(id) ON DELETE CASCADE NOT NULL,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    quantity INTEGER DEFAULT 1,
    UNIQUE(cart_id, product_id)
);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- ORDERS
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    status TEXT DEFAULT 'pending',
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- ORDER ITEMS
-- =====================================================
CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id BIGINT REFERENCES products(id) NOT NULL,
    farmer_id UUID REFERENCES profiles(id) NOT NULL,
    quantity INTEGER NOT NULL,
    price_at_time_of_order NUMERIC(10,2) NOT NULL
);

ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- ADMIN LOGS
-- =====================================================
CREATE TABLE IF NOT EXISTS admin_logs (
    id BIGSERIAL PRIMARY KEY,
    admin_id UUID REFERENCES profiles(id) NOT NULL,
    action TEXT NOT NULL,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Profiles
CREATE POLICY "user_read_own_profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "admin_manage_profiles"
ON profiles FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = auth.uid() AND p.role = 'admin'
  )
);

-- Products
CREATE POLICY "public_read_products"
ON products FOR SELECT
USING (is_available = true);

CREATE POLICY "farmer_manage_products"
ON products FOR ALL
USING (
  farmer_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'farmer'
  )
);

CREATE POLICY "admin_manage_products"
ON products FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Orders
CREATE POLICY "user_read_own_orders"
ON orders FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "admin_manage_orders"
ON orders FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Order Items
CREATE POLICY "farmer_read_order_items"
ON order_items FOR SELECT
USING (farmer_id = auth.uid());

-- =====================================================
-- TRIGGER: AUTO CREATE PROFILE ON SIGNUP
-- =====================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'consumer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE PROCEDURE public.handle_new_user();
