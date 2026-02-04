import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmconnect/core/services/supabase_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final SupabaseClient _client;

  AuthNotifier(this._client) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final session = _client.auth.currentSession;
    state = AsyncValue.data(session?.user);
  }

  Future<User?> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
      return response.user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<User?> signUp(String email, String password, Map<String, dynamic> metadata) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      state = AsyncValue.data(response.user);
      return response.user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  // Invalidate profile when auth changes
  ref.listenSelf((previous, next) {
    if (next.value == null) {
      // ref.invalidate(userProfileProvider); // This requires importing the profile provider or handling it in main
    }
  });
  return AuthNotifier(ref.watch(supabaseProvider));
});
