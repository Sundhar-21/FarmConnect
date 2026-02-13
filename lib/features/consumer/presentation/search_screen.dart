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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _selectedCategory = 'All Items';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: Text('Local Markets', style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: DesignColors.textPrimary),
            onPressed: () {},
          ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_basket_outlined, color: DesignColors.textPrimary),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                  ),
                  if (ref.watch(cartProvider).isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: DesignColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '${ref.watch(cartProvider).length}',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
          const SizedBox(width: DesignSpacing.s),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: DesignColors.primary,
        child: ListView(
          children: [
            // Categories
            const SizedBox(height: DesignSpacing.m),
            SizedBox(
              height: 50,
              child: ref.watch(categoriesProvider).when(
                data: (categories) {
                  final allCategories = ['All Items', ...categories.map((c) => c['name'] as String)];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
                    children: allCategories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: DesignSpacing.s),
                      child: CategoryChip(
                        label: cat,
                        isSelected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, stack) => const SizedBox(),
              ),
            ),
            const SizedBox(height: DesignSpacing.l),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
              child: ref.watch(productsProvider).when(
                data: (products) {
                  final filteredProducts = products.where((p) {
                    if (_selectedCategory == 'All Items') return true;
                    return p['categories']?['name'] == _selectedCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(DesignSpacing.xl),
                      child: Text('No results found'),
                    ));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: DesignSpacing.m,
                      mainAxisSpacing: DesignSpacing.m,
                    ),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

            // Looking for more banner
            Container(
              margin: const EdgeInsets.all(DesignSpacing.l),
              padding: const EdgeInsets.all(DesignSpacing.xl),
              decoration: BoxDecoration(
                color: DesignColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(DesignRadius.xl),
                border: Border.all(color: DesignColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.eco_rounded, color: DesignColors.primary, size: 40),
                  const SizedBox(height: DesignSpacing.m),
                  Text(
                    'Looking for more?',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: DesignSpacing.s),
                  Text(
                    'Discover what\'s in season right now at your local farms.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: DesignColors.textSecondary),
                  ),
                  const SizedBox(height: DesignSpacing.l),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.xl)),
                    ),
                    child: const Text('Browse Market'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
