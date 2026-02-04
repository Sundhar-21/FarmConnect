import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(Map<String, dynamic> product) {
    if (state.any((item) => item['id'] == product['id'])) {
      state = state.where((item) => item['id'] != product['id']).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isFavorite(int productId) {
    return state.any((item) => item['id'] == productId);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Map<String, dynamic>>>((ref) {
  return FavoritesNotifier();
});
