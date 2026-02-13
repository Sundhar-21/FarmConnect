import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/presentation/profile_screen.dart';
import 'package:farmconnect/features/consumer/presentation/favorites_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/features/consumer/presentation/orders_screen.dart';
import 'package:farmconnect/shared/widgets/custom_bottom_nav.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';

import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';

class ConsumerMainScreen extends ConsumerStatefulWidget {
  const ConsumerMainScreen({super.key});

  @override
  ConsumerState<ConsumerMainScreen> createState() => _ConsumerMainScreenState();
}

class _ConsumerMainScreenState extends ConsumerState<ConsumerMainScreen> {

  final List<Widget> _screens = [
    const ConsumerHomeScreen(),
    const SearchScreen(), // Markets
    const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(navigationIndexProvider.notifier).state = 0;
      },
      child: Scaffold(
        extendBody: true,
        body: _screens[currentIndex],
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomBottomNav(
                    currentIndex: currentIndex,
                    onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(32.5),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Search or open search sheet
                        ref.read(navigationIndexProvider.notifier).state = 1; // For now switch to Markets/Search tab
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12, left: 4),
                        width: 65,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E).withOpacity(0.8), // Match pill color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(Icons.search_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
