import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/supabase_service.dart';

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider); // Watch auth state changes
  final user = authState.value?.session?.user ?? ref.watch(supabaseProvider).auth.currentUser;
  
  if (user == null) return null;

  final supabase = ref.watch(supabaseProvider);
  final startResponse = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (startResponse != null) {
    return startResponse;
  }

  // Self-Healing: If profile is missing, create it
  try {
    final metadata = user.userMetadata;
    final fullName = metadata?['full_name'] ?? 'New User';
    final role = metadata?['role'] ?? 'consumer';

    final newProfile = {
      'id': user.id,
      'full_name': fullName,
      'role': role,
    };
    
    await supabase.from('profiles').insert(newProfile);
    
    // Also try to create the sub-profile (ignoring errors)
    if (role == 'farmer') {
         try {
           await supabase.from('farmer_profiles').insert({'profile_id': user.id, 'farm_name': 'My Farm'});
         } catch (_) {}
    } else {
         try {
           await supabase.from('consumer_profiles').insert({'profile_id': user.id});
         } catch (_) {}
    }

    return newProfile;
  } catch (e) {
    // If insertion fails (e.g. permission), return null to show error screen? 
    // Or return a temporary local object to unblock UI?
    // Let's return local object to allow UI to render, user can fix later.
    return {
      'id': user.id,
      'full_name': 'Guest',
      'role': 'consumer',
    };
  }
});
