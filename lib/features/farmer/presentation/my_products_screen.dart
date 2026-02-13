import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

final farmerProductsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    return Stream.value([]);
  }

  return supabase
      .from('products')
      .stream(primaryKey: ['id'])
      .eq('farmer_id', user.id)
      .order('created_at', ascending: false)
      .map((data) => List<Map<String, dynamic>>.from(data));
});

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(farmerProductsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Products', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF111111))),
        iconTheme: const IconThemeData(color: DesignColors.textPrimary),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: DesignColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text('No products yet', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF666666))),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first product to get started',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(farmerProductsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: DesignColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(DesignSpacing.l),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: DesignSpacing.m),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(product: product);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error loading products',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.l),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(DesignRadius.l),
              bottomLeft: Radius.circular(DesignRadius.l),
            ),
            child: Container(
              width: 100,
              height: 100,
              color: DesignColors.surface,
              child: product['image_url'] != null
                  ? CachedNetworkImage(
                      imageUrl: product['image_url'],
                      fit: BoxFit.cover,
                      memCacheWidth: 200,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.eco,
                        color: DesignColors.primary,
                        size: 40,
                      ),
                      placeholder: (context, url) => Container(color: DesignColors.surface),
                    )
                  : const Icon(
                      Icons.eco,
                      color: DesignColors.primary,
                      size: 40,
                    ),
            ),
          ),
          
          // Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DesignColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'] ?? 'Uncategorized',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product['is_available'] == true
                              ? DesignColors.primary.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignRadius.s),
                        ),
                        child: Text(
                          product['is_available'] == true ? 'Available' : 'Unavailable',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product['is_available'] == true
                                ? DesignColors.primary
                                : Colors.red,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DesignColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
