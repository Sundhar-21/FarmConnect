import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/presentation/profile_screen.dart';
import 'package:farmconnect/features/consumer/presentation/favorites_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/shared/widgets/custom_bottom_nav.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/shared/widgets/voice_button.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';
import 'package:farmconnect/core/services/voice_service.dart';

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
    final voiceState = ref.watch(voiceServiceProvider);
    final isListening = voiceState.state == VoiceState.listening;

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
            if (isListening)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: CustomBottomNav(
                    currentIndex: currentIndex,
                    onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: DesignColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: DesignShadows.small,
                  ),
                  child: const VoiceButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
