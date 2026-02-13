-- Add RLS policy for farmers to read orders data
-- This allows farmers to see order information for their order items
-- Run this SQL in your Supabase SQL Editor

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "farmer_read_orders_for_their_items" ON orders;

-- Create the policy
CREATE POLICY "farmer_read_orders_for_their_items"
ON orders FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM order_items
    WHERE order_items.order_id = orders.id
    AND order_items.farmer_id = auth.uid()
  )
);
