import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/auth/data/auth_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedRole = 'consumer';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Join FarmConnect",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "I am a:",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    label: "Consumer",
                    icon: Icons.shopping_bag_outlined,
                    isSelected: _selectedRole == 'consumer',
                    onTap: () => setState(() => _selectedRole = 'consumer'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleCard(
                    label: "Farmer",
                    icon: Icons.agriculture,
                    isSelected: _selectedRole == 'farmer',
                    onTap: () => setState(() => _selectedRole = 'farmer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      final authNotifier = ref.read(authNotifierProvider.notifier);
                      try {
                        await authNotifier.signUp(
                          _emailController.text,
                          _passwordController.text,
                          {
                            'full_name': _fullNameController.text,
                            'role': _selectedRole,
                          },
                        );
                        
                        // User signed up, now let's ensure the profile exists (Manual Backup to Trigger)
                        // This fixes the "Data not stored" issue if the SQL trigger fails.
                        if (mounted) {
                           final user = ref.read(supabaseProvider).auth.currentUser;
                           if (user != null) {
                             final supabase = ref.read(supabaseProvider);
                             
                             // 1. Create Main Profile
                             try {
                               await supabase.from('profiles').insert({
                                 'id': user.id,
                                 'full_name': _fullNameController.text,
                                 'role': _selectedRole,
                               });
                             } catch (e) {
                               debugPrint("Error creating profile: $e");
                             }

                             // 2. Create Sub-Profile
                             try {
                               if (_selectedRole == 'farmer') {
                                  await supabase.from('farmer_profiles').insert({
                                    'profile_id': user.id, 
                                    'farm_name': 'My Farm',
                                    'farm_location': 'Unknown'
                                  });
                               } else {
                                  await supabase.from('consumer_profiles').insert({
                                    'profile_id': user.id
                                  });
                               }
                             } catch (e) {
                               debugPrint("Error creating sub-profile: $e");
                             }
                           }

                           // Navigate or show success
                           // The main.dart stream will handle redirection, but we can show a snackbar
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Account created! Logging you in...')),
                           );
                        }
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Signup Failed: $e')),
                         );
                      }
                    },
              child: authState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8)]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
