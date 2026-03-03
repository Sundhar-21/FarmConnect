import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';

class CustomBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).length;
    final favCount = ref.watch(favoritesProvider).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: CupertinoColors.systemGrey5.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, CupertinoIcons.house_fill, CupertinoIcons.house, context.tr('home')),
                  _buildNavItem(1, CupertinoIcons.search, CupertinoIcons.search, context.tr('markets')),
                  _buildNavItem(2, CupertinoIcons.heart_fill, CupertinoIcons.heart, context.tr('favorites'), badge: favCount > 0 ? favCount : null),
                  _buildNavItem(3, CupertinoIcons.cart_fill, CupertinoIcons.cart, context.tr('cart'), badge: cartCount > 0 ? cartCount : null),
                  _buildNavItem(4, CupertinoIcons.person_fill, CupertinoIcons.person, context.tr('profile')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {int? badge}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    key: ValueKey(isSelected),
                    color: isSelected ? DesignColors.primary : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.destructiveRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : badge.toString(),
                          style: const TextStyle(color: CupertinoColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                color: isSelected ? DesignColors.primary : CupertinoColors.systemGrey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
