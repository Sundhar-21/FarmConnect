-- Add RLS policies for consumers to create their own orders
-- This is required for cart checkout functionality
-- Run this SQL in your Supabase SQL Editor

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "user_create_own_order" ON orders;
DROP POLICY IF EXISTS "user_create_order_items" ON order_items;

-- Allow consumers to insert their own orders
CREATE POLICY "user_create_own_order"
ON orders FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Allow consumers to insert order items for their orders
CREATE POLICY "user_create_order_items"
ON order_items FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = order_items.order_id
    AND orders.user_id = auth.uid()
  )
);
