import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isOnline = true; // For the toggle

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final totalPrice = notifier.totalPrice;
    final primaryColor = Theme.of(context).primaryColor;
    const accentColor = Color(0xFFFFC107); // Amber for buttons/highlights

    return Scaffold(
      appBar: AppBar(
        title: Text("Cart (${cartItems.length})", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Toggle Buttons
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOnline = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isOnline ? accentColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "Online",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: _isOnline ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOnline = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isOnline ? accentColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "Store",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: !_isOnline ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: cartItems.isEmpty 
              ? Center(child: Text("Your cart is empty", style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item.product;
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              image: product['image_url'] != null 
                                ? DecorationImage(image: NetworkImage(product['image_url']), fit: BoxFit.cover)
                                : null,
                            ),
                            child: product['image_url'] == null 
                              ? const Icon(Icons.image, color: Colors.grey) 
                              : null,
                          ),
                          const SizedBox(width: 16),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product['name'] ?? 'Unknown',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  ],
                                ),
                                Text(
                                  product['category'] ?? 'Fresh Farm',
                                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$${product['price']}",
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        _QtyBtn(
                                          icon: Icons.remove, 
                                          onTap: () => notifier.decrementQuantity(product['id']),
                                          isAdd: false,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Text("${item.quantity}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                        ),
                                        _QtyBtn(
                                          icon: Icons.add, 
                                          onTap: () => notifier.incrementQuantity(product['id']),
                                          isAdd: true,
                                          color: accentColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
          
          // Bottom Checkout Bar
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: Text("${cartItems.length}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "\$${totalPrice.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.chat_bubble_outline, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final supabase = ref.read(supabaseProvider);
                          await ref.read(cartProvider.notifier).checkout(supabase);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Order placed successfully!"))
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Checkout failed: $e"))
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Buy", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_outward, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;
  final Color? color;

  const _QtyBtn({required this.icon, required this.onTap, required this.isAdd, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isAdd ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: isAdd ? Colors.white : Colors.grey),
      ),
    );
  }
}
