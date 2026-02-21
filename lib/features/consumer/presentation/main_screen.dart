import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/presentation/profile_screen.dart';
import 'package:farmconnect/features/consumer/presentation/favorites_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/shared/widgets/custom_bottom_nav.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/shared/widgets/voice_button.dart';

import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';

class ConsumerMainScreen extends ConsumerStatefulWidget {
  const ConsumerMainScreen({super.key});

  @override
  ConsumerState<ConsumerMainScreen> createState() => _ConsumerMainScreenState();
}

class _ConsumerMainScreenState extends ConsumerState<ConsumerMainScreen> {

  final List<Widget> _screens = const [
    ConsumerHomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
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
        body: Stack(
          children: [
            IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
            Positioned(
              right: 16,
              bottom: 80,
              child: const VoiceButton(),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomBottomNav(
              currentIndex: currentIndex,
              onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
            ),
          ),
        ),
      ),
    );
  }
}
