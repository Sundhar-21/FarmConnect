-- ========================================================
-- STORAGE SETUP: Product Images
-- ========================================================

-- 1. Create the bucket (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. ENABLE RLS on objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. POLICIES

-- A. Public Access: Everyone can view images
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'product-images' );

-- B. Authenticated Upload: Any logged-in user (Farmers) can upload
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'product-images' 
  AND auth.role() = 'authenticated'
);

-- C. Owners can update/delete their own files
DROP POLICY IF EXISTS "Owner Update" ON storage.objects;
CREATE POLICY "Owner Update"
ON storage.objects FOR UPDATE
USING ( auth.uid() = owner )
WITH CHECK ( bucket_id = 'product-images' );

DROP POLICY IF EXISTS "Owner Delete" ON storage.objects;
CREATE POLICY "Owner Delete"
ON storage.objects FOR DELETE
USING ( auth.uid() = owner AND bucket_id = 'product-images' );
