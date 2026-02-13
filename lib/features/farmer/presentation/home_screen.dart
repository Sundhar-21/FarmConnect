import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/auth/data/auth_provider.dart';
import 'package:farmconnect/features/farmer/presentation/add_product_screen.dart';
import 'package:farmconnect/features/farmer/presentation/orders_screen.dart';
import 'package:farmconnect/features/farmer/presentation/my_products_screen.dart';
import 'package:farmconnect/features/farmer/presentation/sales_stats_screen.dart';

class FarmerHomeScreen extends ConsumerWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Maybe show an exit confirmation or just do nothing
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Farmer Dashboard", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF111111))),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Your Farm",
                style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _DashboardCard(
                      icon: Icons.add_box_outlined, 
                      label: "Add Product", 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddProductScreen()),
                        );
                      }
                    ),
                    _DashboardCard(
                      icon: Icons.inventory_2_outlined, 
                      label: "My Products", 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyProductsScreen()),
                        );
                      }
                    ),
                    _DashboardCard(
                      icon: Icons.list_alt_outlined, 
                      label: "Orders", 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FarmerOrdersScreen()),
                        );
                      }
                    ),
                    _DashboardCard(
                      icon: Icons.analytics_outlined, 
                      label: "Sales Stats", 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SalesStatsScreen()),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF111111))),
          ],
        ),
      ),
    );
  }
}
