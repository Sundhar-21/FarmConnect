-- ========================================================
-- SAFE STORAGE SETUP (Avoids 42501 Ownership Error)
-- ========================================================

-- 1. Create the bucket (Safe if exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. SKIP "ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY"
-- It is usually already enabled. If it fails, we ignore it.

-- 3. POLICIES
-- NOTE: If you still get 42501, it means you don't have permission to drop/create policies on storage.objects.
-- In that case, use the Supabase Dashboard -> Storage -> Policies to add these manually.

-- A. Public Access
BEGIN;
  DROP POLICY IF EXISTS "Public Access" ON storage.objects;
  CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'product-images' );
COMMIT;

-- B. Authenticated Upload
BEGIN;
  DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
  CREATE POLICY "Authenticated Upload" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'product-images' AND auth.role() = 'authenticated' );
COMMIT;

-- C. Owner Permissions
BEGIN;
  DROP POLICY IF EXISTS "Owner Update" ON storage.objects;
  CREATE POLICY "Owner Update" ON storage.objects FOR UPDATE USING ( auth.uid() = owner ) WITH CHECK ( bucket_id = 'product-images' );
  
  DROP POLICY IF EXISTS "Owner Delete" ON storage.objects;
  CREATE POLICY "Owner Delete" ON storage.objects FOR DELETE USING ( auth.uid() = owner AND bucket_id = 'product-images' );
COMMIT;
