import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: const SizedBox(height: DesignSpacing.m)),
              // Toolbar
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildToolIcon(Icons.menu_rounded),
                      Text(
                        'Favorites',
                        style: GoogleFonts.outfit(
                          color: DesignColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen())),
                      child: _buildToolIcon(Icons.shopping_cart_outlined),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.xl)),

              if (favorites.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 80,
                          color: DesignColors.textSecondary.withOpacity(0.2),
                        ),
                        const SizedBox(height: DesignSpacing.m),
                        Text(
                          'No favorites found',
                          style: GoogleFonts.outfit(
                            color: DesignColors.textSecondary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: DesignSpacing.s),
                        Text(
                          'Start exploring to add items here',
                          style: GoogleFonts.outfit(
                            color: DesignColors.textSecondary.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: DesignSpacing.m,
                      crossAxisSpacing: DesignSpacing.m,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = favorites[index];
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
                      childCount: favorites.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.s),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: DesignColors.secondary),
      ),
      child: Icon(icon, color: DesignColors.textPrimary),
    );
  }
}
