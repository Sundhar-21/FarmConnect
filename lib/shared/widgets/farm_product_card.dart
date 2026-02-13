import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FarmProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;
  final bool isLarge;
  final VoidCallback? onTap;

  const FarmProductCard({
    super.key,
    required this.product,
    this.isLarge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLarge) {
      return _buildLargeCard(context, ref);
    }
    return _buildSmallCard(context, ref);
  }

  Widget _buildLargeCard(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider.notifier).isFavorite(product['id']);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: DesignColors.primary,
          borderRadius: BorderRadius.circular(DesignRadius.xl),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product Name',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product['description'] ?? 'Free Delivery',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'PRICE',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${product['price']}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.m),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product['name']} added to cart!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(DesignSpacing.m),
                          decoration: const BoxDecoration(
                            color: DesignColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.s),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(DesignRadius.xl),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: DesignSpacing.xs),
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: -20,
              bottom: 20,
              top: 20,
              child: Hero(
                tag: 'product_${product['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignRadius.xl),
                  child: CachedNetworkImage(
                    imageUrl: product['image_url'] ?? '',
                    fit: BoxFit.contain,
                    width: 200,
                    memCacheWidth: 400,
                    errorWidget: (context, url, error) => const Icon(Icons.image, size: 100),
                    placeholder: (context, url) => Container(color: DesignColors.surface),
                  ),
                ),
              ),
            ),
            Positioned(
              top: DesignSpacing.l,
              right: DesignSpacing.l,
              child: GestureDetector(
                onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
                child: Container(
                  padding: const EdgeInsets.all(DesignSpacing.s),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider.notifier).isFavorite(product['id']);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.l),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(DesignSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: DesignColors.surface,
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                    ),
                    padding: const EdgeInsets.all(DesignSpacing.s),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(DesignRadius.m),
                        child: CachedNetworkImage(
                          imageUrl: product['image_url'] ?? '',
                          fit: BoxFit.contain,
                          memCacheWidth: 300,
                          errorWidget: (context, url, error) => const Icon(Icons.eco, color: DesignColors.primary),
                          placeholder: (context, url) => Container(color: DesignColors.surface),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8E6B).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ORGANIC',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: isFav ? Colors.redAccent : DesignColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignSpacing.s),
            Text(
              product['name'] ?? 'Product',
              style: GoogleFonts.outfit(
                color: DesignColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${product['unit'] ?? '500g'} • \$${product['price'] ?? '0.00'} / ${product['unit'] ?? 'kg'}',
              style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 10),
            ),
            const SizedBox(height: DesignSpacing.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product['price']}',
                  style: GoogleFonts.outfit(
                    color: DesignColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(cartProvider.notifier).addToCart(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${product['name']} added to cart"),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: DesignColors.primary,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: DesignColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
