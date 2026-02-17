import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/category_chip.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/shared/widgets/shimmer_loading.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Container(
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
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          ref.invalidate(productsProvider);
          ref.invalidate(categoriesProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: DesignColors.primary,
        backgroundColor: Colors.white,
        displacement: 100,
        edgeOffset: 50,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 10)),
            
            SliverToBoxAdapter(
              child: profileAsync.when(
                data: (profile) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _showAddressUpdateDialog(context, ref, profile?['address'] ?? ''),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignRadius.xxl),
                            boxShadow: DesignShadows.small,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DesignColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: DesignColors.primary, size: 16),
                              ),
                              const SizedBox(width: DesignSpacing.s),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DELIVER TO',
                                    style: GoogleFonts.outfit(color: DesignColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.35),
                                        child: Text(
                                          profile?['address']?.isEmpty ?? true ? 'Select Address' : profile!['address'],
                                          style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: DesignColors.textSecondary),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: DesignGradients.primaryGradient,
                          boxShadow: DesignShadows.glow,
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          backgroundImage: profile?['avatar_url'] != null && profile!['avatar_url'].toString().isNotEmpty
                              ? CachedNetworkImageProvider(
                                  profile['avatar_url'],
                                  maxWidth: 80,
                                  maxHeight: 80,
                                )
                              : null,
                          child: profile?['avatar_url'] == null || profile!['avatar_url'].toString().isEmpty
                              ? Text(
                                  (profile?['full_name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: DesignColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(height: 50),
                error: (_, __) => const SizedBox(height: 50),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('freshFromTheFarm'),
                      style: GoogleFonts.outfit(
                        color: DesignColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('discoverOrganicProduce'),
                      style: GoogleFonts.outfit(
                        color: DesignColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignRadius.xxl),
                          boxShadow: DesignShadows.small,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                          decoration: InputDecoration(
                            hintText: 'Search fresh produce...',
                            hintStyle: GoogleFonts.outfit(color: DesignColors.textTertiary, fontSize: 14),
                            border: InputBorder.none,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: DesignColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_rounded, color: DesignColors.primary, size: 18),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: DesignColors.textSecondary, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.m),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: DesignGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(DesignRadius.l),
                        boxShadow: DesignShadows.glow,
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),

            categoriesAsync.when(
              data: (categories) {
                final allCategories = ['All', ...categories.map((c) => c['name'] as String)];
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: allCategories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: DesignSpacing.s),
                          child: CategoryChip(
                            label: cat,
                            isSelected: _selectedCategory == cat,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = cat);
                            },
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                  child: CategoryShimmer(),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),

            ...productsAsync.when(
              data: (products) {
                final filteredProducts = products.where((p) {
                  final matchesCategory = _selectedCategory == 'All' || (p['categories'] as Map?)?['name'] == _selectedCategory;
                  final matchesSearch = _searchQuery.isEmpty || 
                    (p['name'] as String?)?.toLowerCase().contains(_searchQuery) == true ||
                    (p['description'] as String?)?.toLowerCase().contains(_searchQuery) == true;
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return [
                    SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: DesignColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.eco_outlined,
                                size: 64,
                                color: DesignColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isNotEmpty 
                                ? 'No results found for "$_searchQuery"' 
                                : 'No products available',
                              style: GoogleFonts.outfit(
                                color: DesignColors.textSecondary, 
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Check back later for fresh produce',
                              style: GoogleFonts.outfit(
                                color: DesignColors.textTertiary, 
                                fontSize: 14,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.clear, size: 18),
                                label: Text('Clear search', style: GoogleFonts.outfit()),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  ];
                }

                final featuredProduct = filteredProducts.first;
                final remainingProducts = filteredProducts.skip(1).toList();

                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: featuredProduct)),
                        ),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: DesignGradients.darkGradient,
                            borderRadius: BorderRadius.circular(DesignRadius.xxl),
                            boxShadow: DesignShadows.large,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(DesignRadius.xxl),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=70&w=600',
                                    fit: BoxFit.cover,
                                    color: Colors.black.withOpacity(0.4),
                                    colorBlendMode: BlendMode.darken,
                                    placeholder: (context, url) => Container(color: DesignColors.surface),
                                    errorWidget: (context, url, error) => Container(color: DesignColors.surface),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(DesignSpacing.l),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: DesignColors.primary,
                                        borderRadius: BorderRadius.circular(DesignRadius.full),
                                      ),
                                      child: Text(
                                        'Featured',
                                        style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      featuredProduct['name'] ?? 'Fresh Harvest Box',
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Fresh harvest delivered to your door',
                                      style: GoogleFonts.outfit(color: DesignColors.primaryLight, fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${featuredProduct['price']}',
                                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(DesignRadius.full),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Order Now',
                                                style: GoogleFonts.outfit(color: DesignColors.primaryDark, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_forward_rounded, color: DesignColors.primaryDark, size: 18),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recommended for you',
                            style: GoogleFonts.outfit(color: const Color(0xFF111111), fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                    child: child,
                                  );
                                },
                              ),
                            ),
                            child: Text(
                              'See All',
                              style: GoogleFonts.outfit(color: DesignColors.primaryDark, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.s)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: DesignSpacing.m,
                        mainAxisSpacing: DesignSpacing.m,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FarmProductCard(product: remainingProducts[index]),
                        childCount: remainingProducts.length,
                      ),
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        FeaturedProductShimmer(),
                        SizedBox(height: DesignSpacing.l),
                        Text('Recommended for you', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: DesignSpacing.s),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: DesignSpacing.m,
                      mainAxisSpacing: DesignSpacing.m,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ProductCardShimmer(),
                      childCount: 4,
                    ),
                  ),
                ),
              ],
              error: (e, __) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSpacing.l),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: DesignColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline_rounded, size: 48, color: DesignColors.error),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: GoogleFonts.outfit(
                              color: DesignColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unable to load products',
                            style: GoogleFonts.outfit(
                              color: DesignColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(productsProvider),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('Try Again', style: GoogleFonts.outfit()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showAddressUpdateDialog(BuildContext context, WidgetRef ref, String currentAddress) {
    final controller = TextEditingController(text: currentAddress);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignRadius.xxl)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Update Delivery Address',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: DesignColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignRadius.l),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: DesignColors.primary),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                        ),
                        side: BorderSide(color: DesignColors.secondary),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: DesignGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(DesignRadius.l),
                        boxShadow: DesignShadows.glow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
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
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Update',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
