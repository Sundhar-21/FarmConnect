import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/features/consumer/presentation/order_success_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartProvider.notifier).totalPrice;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: Text('Your Basket', style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
            child: Text('Clear All', style: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: DesignSpacing.m),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l, vertical: DesignSpacing.m),
                    child: Row(
                      children: [
                        Text(
                          '${cartItems.length} items from 2 local farms',
                          style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, ref, item);
                    },
                  ),
                  _buildCarbonFootprint(),
                  _buildCheckoutPanel(context, ref, totalPrice, profileAsync.value?['address'] ?? 'No Address Provided'),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: DesignColors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: DesignSpacing.m),
          Text(
            'Your basket is empty',
            style: GoogleFonts.outfit(
              color: DesignColors.textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.l),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignColors.surface,
              borderRadius: BorderRadius.circular(DesignRadius.m),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignRadius.m),
              child: CachedNetworkImage(
                imageUrl: item.product['image_url'] ?? '',
                fit: BoxFit.cover,
                memCacheWidth: 200,
                errorWidget: (context, url, error) => const Icon(Icons.eco, color: DesignColors.primary),
                placeholder: (context, url) => Container(color: DesignColors.surface),
              ),
            ),
          ),
          const SizedBox(width: DesignSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product['name'] ?? 'Product',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 14, color: DesignColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Sunny Peaks Farm',
                      style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.product['unit'] ?? '500g'} bag',
                  style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(item.product['price'] * item.quantity).toStringAsFixed(2)}',
                style: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: DesignColors.surface,
                  borderRadius: BorderRadius.circular(DesignRadius.s),
                ),
                child: Row(
                  children: [
                    _buildQtyBtn(context, ref, item.product['id'], item.quantity - 1, Icons.remove),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${item.quantity}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ),
                    _buildQtyBtn(context, ref, item.product['id'], item.quantity + 1, Icons.add, isPrimary: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(BuildContext context, WidgetRef ref, int productId, int newQty, IconData icon, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: () => ref.read(cartProvider.notifier).updateQuantity(productId, newQty),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPrimary ? DesignColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: isPrimary ? Colors.white : DesignColors.textPrimary),
      ),
    );
  }

  Widget _buildCarbonFootprint() {
    return Container(
      margin: const EdgeInsets.all(DesignSpacing.l),
      padding: const EdgeInsets.all(DesignSpacing.m),
      decoration: BoxDecoration(
        color: DesignColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignRadius.m),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: DesignColors.primary, size: 24),
          ),
          const SizedBox(width: DesignSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carbon Footprint Saved', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                    children: [
                      const TextSpan(text: 'You saved '),
                      TextSpan(text: '2.4kg of CO2', style: TextStyle(color: DesignColors.primary, fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' by shopping directly from local farms.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, WidgetRef ref, double total, String shippingAddress) {
    const deliveryFee = 2.50;
    
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignRadius.xxl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: DesignSpacing.s),
          _buildSummaryRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
          const Divider(height: DesignSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('\$${(total + deliveryFee).toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DesignSpacing.m),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: DesignColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shipping to: $shippingAddress',
                  style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSpacing.m),
          
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: DesignColors.textSecondary, size: 20),
              const SizedBox(width: DesignSpacing.s),
              Text('Next: Tomorrow, 8am-10am', style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton(onPressed: () {}, child: Text('CHANGE', style: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: DesignSpacing.m),

          ElevatedButton(
            onPressed: () async {
              try {
                final supabase = ref.read(supabaseProvider);
                await ref.read(cartProvider.notifier).checkout(supabase, shippingAddress);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008000), 
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 16)),
        Text(value, style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
