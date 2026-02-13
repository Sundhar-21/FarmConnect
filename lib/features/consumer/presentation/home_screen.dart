import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/category_chip.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Container(
      color: DesignColors.background,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(categoriesProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: DesignColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 60)), // Top margin
            
            // Toolbar
            SliverToBoxAdapter(
              child: profileAsync.when(
                data: (profile) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _showAddressUpdateDialog(context, ref, profile?['address'] ?? ''),
                      borderRadius: BorderRadius.circular(DesignRadius.xl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
                        decoration: BoxDecoration(
                          color: DesignColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignRadius.xl),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: DesignColors.primary, size: 18),
                            const SizedBox(width: DesignSpacing.xs),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DELIVER TO',
                                  style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
                                      child: Text(
                                        profile?['address']?.isEmpty ?? true ? 'Select Address' : profile!['address'],
                                        style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: DesignColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: DesignColors.surface,
                        backgroundImage: CachedNetworkImageProvider(
                          profile?['avatar_url'] ?? 'https://i.pravatar.cc/150?u=farmconnect_user',
                          maxWidth: 80,
                          maxHeight: 80,
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 50),
                error: (_, __) => const SizedBox(height: 50),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.xl)),
            
            // Title
            SliverToBoxAdapter(
              child: Text(
                'Fresh from the Farm',
                style: GoogleFonts.outfit(
                  color: DesignColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.xl)),

            // Search Bar
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                      decoration: BoxDecoration(
                        color: DesignColors.surface,
                        borderRadius: BorderRadius.circular(DesignRadius.xl),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search fresh produce...',
                          hintStyle: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 14),
                          border: InputBorder.none,
                          icon: const Icon(Icons.eco_outlined, color: DesignColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSpacing.m),
                  Container(
                    padding: const EdgeInsets.all(DesignSpacing.m),
                    decoration: BoxDecoration(
                      color: DesignColors.primary,
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.xl)),

            // Categories
            categoriesAsync.when(
              data: (categories) {
                final allCategories = ['All', ...categories.map((c) => c['name'] as String)];
                return SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allCategories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: DesignSpacing.s),
                        child: CategoryChip(
                          label: cat,
                          isSelected: _selectedCategory == cat,
                          onTap: () => setState(() => _selectedCategory = cat),
                        ),
                      )).toList(),
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox(height: 40)),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.xl)),

            // Products
            ...productsAsync.when(
              data: (products) {
                final filteredProducts = products.where((p) {
                  if (_selectedCategory == 'All') return true;
                  final categoryData = p['categories'] as Map?;
                  return categoryData?['name'] == _selectedCategory;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return [
                    const SliverToBoxAdapter(
                      child: Center(child: Text('No products found')),
                    )
                  ];
                }

                final featuredProduct = filteredProducts.first;
                final remainingProducts = filteredProducts.skip(1).toList();

                return [
                  // Banner
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: featuredProduct)),
                      ),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2E1D),
                          borderRadius: BorderRadius.circular(DesignRadius.xl),
                          image: const DecorationImage(
                            image: CachedNetworkImageProvider(
                              'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=70&w=600',
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(DesignSpacing.l),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Weekly Farm Box', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('Fresh harvest delivered to you', style: GoogleFonts.outfit(color: DesignColors.primary, fontSize: 14)),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: featuredProduct))),
                                style: ElevatedButton.styleFrom(backgroundColor: DesignColors.primary, foregroundColor: Colors.black),
                                child: const Text('Order Now'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.xl)),
                  SliverToBoxAdapter(
                    child: Text('Recommended for you', style: GoogleFonts.outfit(color: const Color(0xFF111111), fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: DesignSpacing.m,
                      mainAxisSpacing: DesignSpacing.m,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => FarmProductCard(product: remainingProducts[index]),
                      childCount: remainingProducts.length,
                    ),
                  ),
                ];
              },
              loading: () => [const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))],
              error: (e, __) => [SliverToBoxAdapter(child: Text('Error: $e'))],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSpacing.s),
          decoration: BoxDecoration(
            color: DesignColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: DesignColors.secondary),
          ),
          child: Icon(icon, color: DesignColors.textPrimary),
        ),
        if (hasBadge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: DesignColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          )
      ],
    );
  }

  void _showAddressUpdateDialog(BuildContext context, WidgetRef ref, String currentAddress) {
    final controller = TextEditingController(text: currentAddress);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Address', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your delivery address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit(color: DesignColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAddress = controller.text.trim();
              if (newAddress.isNotEmpty) {
                final supabase = ref.read(supabaseProvider);
                final user = supabase.auth.currentUser;
                if (user != null) {
                  await supabase
                      .from('profiles')
                      .update({'address': newAddress})
                      .eq('id', user.id);
                  ref.invalidate(userProfileProvider);
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
