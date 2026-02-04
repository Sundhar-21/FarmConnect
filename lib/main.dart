import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmconnect/core/theme/app_theme.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/features/auth/presentation/login_screen.dart';
import 'package:farmconnect/features/consumer/presentation/home_screen.dart';
import 'package:farmconnect/features/consumer/presentation/main_screen.dart';
import 'package:farmconnect/features/auth/data/auth_provider.dart';

import 'package:farmconnect/features/farmer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: FarmConnectApp()));
}

class FarmConnectApp extends ConsumerWidget {
  const FarmConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'FarmConnect',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (state) {
          final user = state.session?.user;
          if (user != null) {
            // User is logged in, now check their role
            final profileAsync = ref.watch(userProfileProvider);
            
            return profileAsync.when(
              data: (profile) {
                if (profile == null) return const LoginScreen();
                
                if (profile['role'] == 'farmer') {
                  return const FarmerHomeScreen();
                } else {
                  return const ConsumerMainScreen();
                }
              },
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => Scaffold(
                body: Center(child: Text("Profile Error: $e")),
              ),
            );
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Scaffold(
          body: Center(child: Text("Auth Error: $e")),
        ),
      ),
    );
  }
}
