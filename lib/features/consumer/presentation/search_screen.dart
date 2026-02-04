import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider); // Using this for trending/popular

    return Scaffold(
      appBar: AppBar(
        title: Text("Farm Market", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search for products...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.camera_alt_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),

            // Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Filter", "Sort by", "Category", "Quantity"].map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(e),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Browse Categories
            Text("Browse Categories", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.orange), // Placeholder icon
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("100+ items", style: GoogleFonts.outfit(color: Colors.green, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_outward, size: 16, color: Colors.grey),
                    ],
                  );
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Error loading categories"),
            ),

            const SizedBox(height: 24),
            
            // Trending Now (Using products for demo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Trending Now", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("See All", style: GoogleFonts.outfit(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: productsAsync.when(
                data: (products) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                color: Colors.grey.shade200,
                                image: p['image_url'] != null ? DecorationImage(image: NetworkImage(p['image_url']), fit: BoxFit.cover) : null,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['name'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold), maxLines: 1),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("\$${p['price']}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green)),
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(favoritesProvider.notifier).toggleFavorite(p);
                                      },
                                      child: Icon(
                                        ref.watch(favoritesProvider.notifier).isFavorite(p['id']) 
                                            ? Icons.favorite 
                                            : Icons.favorite_border, 
                                        size: 16, 
                                        color: ref.watch(favoritesProvider.notifier).isFavorite(p['id']) 
                                            ? Colors.red 
                                            : Colors.grey
                                      ),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text("Error loading trending"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
