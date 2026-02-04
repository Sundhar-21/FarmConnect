import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/auth/data/auth_provider.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text("No profile found"));
          
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 24),
                _ProfileItem(label: "Full Name", value: profile['full_name'] ?? "N/A"),
                _ProfileItem(label: "Role", value: (profile['role'] as String).toUpperCase()),
                _ProfileItem(label: "Phone", value: profile['phone'] ?? "Not set"),
                _ProfileItem(label: "Address", value: profile['address'] ?? "Not set"),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                  ),
                  child: const Text("Logout"),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          const Divider(),
        ],
      ),
    );
  }
}
