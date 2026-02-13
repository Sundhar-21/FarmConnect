import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/features/consumer/presentation/main_screen.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  ref.read(navigationIndexProvider.notifier).state = 0;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ConsumerMainScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: DesignColors.textPrimary,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: DesignColors.primary,
                  size: 100,
                ),
              ),
              const SizedBox(height: DesignSpacing.xl),
              Text(
                'Order Placed!',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.textPrimary,
                ),
              ),
              const SizedBox(height: DesignSpacing.m),
              Text(
                'Your harvest is being prepared by our local farmers. You can track your order in the orders section.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: DesignColors.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(navigationIndexProvider.notifier).state = 0;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const ConsumerMainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                  ),
                  child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: DesignSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}
