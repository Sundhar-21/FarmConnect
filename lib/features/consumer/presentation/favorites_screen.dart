import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    const accentColor = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: Text("Favourites (${favorites.length})", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: favorites.isEmpty
          ? Center(child: Text("No favourites yet", style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = favorites[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          image: product['image_url'] != null 
                              ? DecorationImage(image: NetworkImage(product['image_url']), fit: BoxFit.cover)
                              : null,
                        ),
                        child: product['image_url'] == null ? const Icon(Icons.image, color: Colors.grey) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unknown',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              product['category'] ?? 'Fresh Farm',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${product['price']}",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: accentColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: accentColor),
                        onPressed: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(product);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
