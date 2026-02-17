import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/shared/widgets/category_chip.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FFF8),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignSpacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('localMarkets'),
                            style: GoogleFonts.outfit(
                              color: DesignColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('findFreshProduce'),
                            style: GoogleFonts.outfit(
                              color: DesignColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                          boxShadow: DesignShadows.small,
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.shopping_basket_outlined, color: DesignColors.textPrimary),
                            if (ref.watch(cartProvider).isNotEmpty)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: DesignGradients.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${ref.watch(cartProvider).length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ref.watch(categoriesProvider).when(
                  data: (categories) {
                    // Define the forced order of categories
                    final forcedOrder = ['All', 'Vegetables', 'Fruits', 'Meat', 'Grains', 'Dairy', 'Others'];
                    
                     // Helper to get localized name
                    String getLocalizedName(String dbName) {
                      switch (dbName) {
                        case 'All': return context.tr('all');
                        case 'Vegetables': return context.tr('vegetables');
                        case 'Fruits': return context.tr('fruits');
                        case 'Meat': return context.tr('meat');
                        case 'Grains': return context.tr('grains');
                        case 'Dairy': return context.tr('dairy');
                        case 'Others': return context.tr('others');
                        default: return dbName;
                      }
                    }

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                      children: forcedOrder.map((catName) => Padding(
                        padding: const EdgeInsets.only(right: DesignSpacing.s),
                        child: CategoryChip(
                          label: getLocalizedName(catName),
                          isSelected: _selectedCategory == catName || (_selectedCategory == 'All Items' && catName == 'All'),
                          onTap: () => setState(() => _selectedCategory = catName),
                        ),
                      )).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, stack) => const SizedBox(),
                ),
              ),
              const SizedBox(height: DesignSpacing.m),
              Expanded(
                child: ref.watch(productsProvider).when(
                  data: (products) {
                    final filteredProducts = products.where((p) {
                      if (_selectedCategory == 'All' || _selectedCategory == 'All Items') return true;
                      return p['categories']?['name'] == _selectedCategory;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: DesignColors.textSecondary.withOpacity(0.3)),
                            const SizedBox(height: DesignSpacing.m),
                            Text(
                              'No products found',
                              style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: DesignSpacing.m,
                        mainAxisSpacing: DesignSpacing.m,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return FarmProductCard(
                          product: product,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(product: product),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: DesignColors.primary)),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
