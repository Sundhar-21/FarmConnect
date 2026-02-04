import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/presentation/profile_screen.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';
import 'package:farmconnect/features/consumer/presentation/favorites_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/features/consumer/presentation/orders_screen.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';

// Placeholders for new screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(title)));
}

class ConsumerMainScreen extends ConsumerStatefulWidget {
  const ConsumerMainScreen({super.key});

  @override
  ConsumerState<ConsumerMainScreen> createState() => _ConsumerMainScreenState();
}

class _ConsumerMainScreenState extends ConsumerState<ConsumerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ConsumerHomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const FavoritesScreen(),
    const ConsumerOrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).length;
    final favoritesCount = ref.watch(favoritesProvider).length;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Needed for >3 items
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.outfit(),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: _buildBadgeIcon(Icons.shopping_cart_outlined, cartCount), 
            activeIcon: _buildBadgeIcon(Icons.shopping_cart, cartCount),
            label: "Cart"
          ),
          BottomNavigationBarItem(
            icon: _buildBadgeIcon(Icons.favorite_outline, favoritesCount), 
            activeIcon: _buildBadgeIcon(Icons.favorite, favoritesCount),
            label: "Favourites"
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Orders"),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
  
  Widget _buildBadgeIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
