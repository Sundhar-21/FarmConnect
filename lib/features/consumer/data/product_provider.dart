import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/supabase_service.dart';

final productsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('products')
      .select('*, categories(*)')
      .eq('is_available', true)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final categoriesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('categories')
      .select()
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});
