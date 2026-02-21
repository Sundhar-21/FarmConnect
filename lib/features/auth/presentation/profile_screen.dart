import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';
import 'package:farmconnect/features/consumer/presentation/orders_screen.dart';
import 'package:farmconnect/features/auth/presentation/edit_profile_screen.dart';
import 'package:farmconnect/features/auth/presentation/login_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:farmconnect/features/auth/data/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final user = supabase.auth.currentUser;

    return Scaffold(
      body: Container(
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
        child: ref.watch(userProfileProvider).when(
          data: (profile) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSpacing.m),
                    child: Column(
                      children: [
                        const SizedBox(height: DesignSpacing.l),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: DesignGradients.primaryGradient,
                                  boxShadow: DesignShadows.glow,
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.white,
                                  backgroundImage: profile?['avatar_url'] != null && profile!['avatar_url'].toString().isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          profile['avatar_url'],
                                          maxWidth: 120,
                                          maxHeight: 120,
                                        )
                                      : null,
                                  child: profile?['avatar_url'] == null || profile!['avatar_url'].toString().isEmpty
                                      ? Text(
                                          (profile?['full_name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: DesignColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (profile != null) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: DesignGradients.primaryGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: DesignShadows.small,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DesignSpacing.m),
                        Text(
                          profile?['full_name'] ?? user?.email ?? 'No name',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No email',
                          style: GoogleFonts.outfit(fontSize: 14, color: DesignColors.textSecondary),
                        ),
                        const SizedBox(height: DesignSpacing.m),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: DesignGradients.primaryGradient,
                            borderRadius: BorderRadius.circular(DesignRadius.full),
                          ),
                          child: Text(
                            profile?['role'] == 'farmer' ? context.tr('farmerAccount') : context.tr('premiumMember'),
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(DesignSpacing.m),
                  child: Column(
                    children: [
                      const SizedBox(height: DesignSpacing.m),
                      _buildMenuSection([
                        _MenuItem(Icons.person_outline, context.tr('editProfile'), () {
                          if (profile != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
                          }
                        }),
                        _MenuItem(Icons.receipt_long_outlined, context.tr('myOrders'), () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
                        }),
                        _MenuItem(Icons.location_on_outlined, context.tr('savedAddresses'), () {
                          if (profile != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
                          }
                        }),
                        _MenuItem(Icons.payment_outlined, context.tr('paymentMethods'), () {}),
                        _MenuItem(Icons.language_outlined, context.tr('language'), () {
                          _showLanguageBottomSheet(context, ref);
                        }),
                        _MenuItem(Icons.notifications_outlined, context.tr('notifications'), () {}),
                        _MenuItem(Icons.help_outline, context.tr('helpSupport'), () {}),
                        _MenuItem(Icons.info_outline, context.tr('about'), () {}),
                      ]),
                      const SizedBox(height: DesignSpacing.l),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.s),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: DesignColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignRadius.l),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                await supabase.auth.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(DesignRadius.l),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout_rounded, color: DesignColors.error, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.tr('logout'),
                                      style: GoogleFonts.outfit(
                                        color: DesignColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: DesignColors.primary)),
          error: (e, __) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.xl),
        boxShadow: DesignShadows.small,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                  ),
                  child: Icon(item.icon, color: DesignColors.primary, size: 22),
                ),
                title: Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF666666)),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                Divider(height: 1, indent: 70, color: DesignColors.secondary),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.onTap);
}

void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
  final currentLocale = ref.read(localeProvider);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignRadius.xxl)),
      ),
      child: SingleChildScrollView(
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
              context.tr('selectLanguage'),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred language',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: DesignColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ...supportedLanguages.map((lang) => _buildLanguageOption(
              context: context,
              ref: ref,
              language: lang,
              isSelected: currentLocale.languageCode == lang.code,
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLanguageOption({
  required BuildContext context,
  required WidgetRef ref,
  required LanguageOption language,
  required bool isSelected,
}) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      ref.read(localeProvider.notifier).state = Locale(language.code);
      Navigator.pop(context);
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? DesignColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.l),
        border: Border.all(
          color: isSelected ? DesignColors.primary : DesignColors.secondary,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? DesignColors.primary : DesignColors.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignRadius.m),
            ),
            child: Center(
              child: Text(
                _getFlagEmoji(language.code),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.nativeName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? DesignColors.primary : DesignColors.textPrimary,
                  ),
                ),
                Text(
                  language.name,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: DesignColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: DesignColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    ),
  );
}

String _getFlagEmoji(String code) {
  switch (code) {
    case 'en':
      return '🇬🇧';
    case 'ta':
      return '🇮🇳';
    case 'hi':
      return '🇮🇳';
    case 'kn':
      return '🇮🇳';
    case 'te':
      return '🇮🇳';
    case 'ml':
      return '🇮🇳';
    default:
      return '🇬🇧';
  }
}
