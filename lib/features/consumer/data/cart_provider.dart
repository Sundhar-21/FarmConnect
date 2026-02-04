import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Map<String, dynamic> product) {
    if (state.any((item) => item.product['id'] == product['id'])) {
      incrementQuantity(product['id']);
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product['id'] != productId).toList();
  }

  void incrementQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product['id'] == productId)
          CartItem(product: item.product, quantity: item.quantity + 1)
        else
          item
    ];
  }

  void decrementQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product['id'] == productId)
          if (item.quantity > 1)
            CartItem(product: item.product, quantity: item.quantity - 1)
          else
            item
        else
          item
    ];
    // Optional: remove if quantity goes to 0? For now keep at 1.
  }

  double get totalPrice {
    return state.fold(0, (total, item) => total + (item.product['price'] * item.quantity));
  }

  Future<void> checkout(SupabaseClient supabase) async {
    if (state.isEmpty) return;
    
    // 1. Get User
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 2. Create Order
    final total = totalPrice;
    final orderResponse = await supabase.from('orders').insert({
      'consumer_id': user.id,
      'total_amount': total,
      'status': 'pending'
    }).select().single();

    final orderId = orderResponse['id'];

    // 3. Create Order Items
    final itemsData = state.map((item) => {
      'order_id': orderId,
      'product_id': item.product['id'], // Assuming product has integer ID
      'farmer_id': item.product['farmer_id'], // Denormalized for farmer ease
      'quantity': item.quantity,
      'price_at_purchase': item.product['price']
    }).toList();

    await supabase.from('order_items').insert(itemsData);

    // 4. Clear Cart
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
