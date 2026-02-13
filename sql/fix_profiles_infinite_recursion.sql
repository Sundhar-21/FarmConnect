-- Fix infinite recursion in profiles table policies
-- This script removes the problematic admin policy that causes infinite recursion
-- Run this SQL in your Supabase SQL Editor

-- Drop all existing policies on profiles table
DROP POLICY IF EXISTS "user_read_own_profile" ON profiles;
DROP POLICY IF EXISTS "user_update_own_profile" ON profiles;
DROP POLICY IF EXISTS "admin_manage_profiles" ON profiles;
DROP POLICY IF EXISTS "farmer_read_customer_profiles" ON profiles;
DROP POLICY IF EXISTS "public_read_profiles" ON profiles;

-- Create simple, safe policy for users to read their own profile
CREATE POLICY "user_read_own_profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Create simple policy for users to update their own profile
CREATE POLICY "user_update_own_profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- NOTE: We are NOT recreating the admin_manage_profiles policy
-- because it causes infinite recursion when checking profiles.role
-- Admins can manage profiles through the Supabase dashboard instead
