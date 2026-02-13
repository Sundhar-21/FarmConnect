import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/features/consumer/presentation/orders_screen.dart';
import 'package:farmconnect/features/auth/presentation/edit_profile_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profile', style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: ref.watch(userProfileProvider).when(
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: DesignSpacing.xl),
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: DesignColors.primary, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profile?['avatar_url'] != null
                            ? NetworkImage(profile!['avatar_url'])
                            : const NetworkImage('https://i.pravatar.cc/150?u=farmconnect_user'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (profile != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: DesignColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignSpacing.l),
              Text(
                profile?['full_name'] ?? user?.email ?? 'No name',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
              ),
              Text(
                user?.email ?? 'No email',
                style: GoogleFonts.outfit(fontSize: 14, color: DesignColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.s),
                ),
                child: Text(
                  'Premium Member',
                  style: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Divider(color: Colors.grey.shade200, thickness: 1, height: 48),
              _buildMenuItem(Icons.person_outline, 'Edit Profile', () {
                if (profile != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
                }
              }),
              _buildMenuItem(Icons.receipt_long_outlined, 'My Orders', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
              }),
              _buildMenuItem(Icons.location_on_outlined, 'Saved Addresses', () {
                if (profile != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
                }
              }),
              _buildMenuItem(Icons.payment_outlined, 'Payment Methods', () {}),
              _buildMenuItem(Icons.notifications_outlined, 'Notifications', () {}),
              _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
              _buildMenuItem(Icons.info_outline, 'About', () {}),

              const SizedBox(height: DesignSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => supabase.auth.signOut(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                    ),
                    child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: DesignSpacing.xxl),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: DesignColors.primary, size: 24),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111111),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF666666)),
      onTap: onTap,
    );
  }
}
