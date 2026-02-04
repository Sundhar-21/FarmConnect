import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseConfig {
  static const String url = 'https://xjnydnkfyzanxcponqpz.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhqbnlkbmtmeXphbnhjcG9ucXB6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwODk5ODYsImV4cCI6MjA4NTY2NTk4Nn0.lv4LLdKVKEnH8ZBEdiyP1LoxFvH8ll71bWldqx6BQLM';
}

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
