import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:intl/intl.dart';

final salesStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) return {'total_sales': 0.0, 'total_orders': 0, 'daily_sales': <String, double>{}};

  // Fetch order items for this farmer
  final response = await supabase
      .from('order_items')
      .select('price_at_time_of_order, quantity, orders(created_at)')
      .eq('farmer_id', user.id);

  double totalSales = 0;
  int totalOrders = response.length; // Approximate, counts items
  Map<String, double> dailySales = {};

  final now = DateTime.now();
  // Initialize last 7 days with 0
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dayKey = DateFormat('E').format(date); // Mon, Tue...
    dailySales[dayKey] = 0.0;
  }

  for (final item in response) {
    if (item['orders'] == null) continue;
    
    final orderDate = DateTime.parse(item['orders']['created_at']).toLocal();
    final price = (item['price_at_time_of_order'] as num).toDouble();
    final quantity = (item['quantity'] as num).toInt();
    final revenue = price * quantity;

    totalSales += revenue;

    // Check if within last 7 days
    if (now.difference(orderDate).inDays < 7) {
      final dayKey = DateFormat('E').format(orderDate);
      if (dailySales.containsKey(dayKey)) {
        dailySales[dayKey] = (dailySales[dayKey] ?? 0) + revenue;
      }
    }
  }

  return {
    'total_sales': totalSales,
    'total_orders': totalOrders,
    'daily_sales': dailySales,
  };
});

class SalesStatsScreen extends ConsumerWidget {
  const SalesStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(salesStatsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sales Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: DesignColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: DesignColors.textPrimary),
      ),
      body: statsAsync.when(
        data: (stats) {
          final dailySales = stats['daily_sales'] as Map<String, double>;
          final maxDailyRef = dailySales.values.isEmpty ? 1.0 : dailySales.values.reduce((a, b) => a > b ? a : b);
          final maxDaily = maxDailyRef == 0 ? 1.0 : maxDailyRef;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard('Total Revenue', '\$${(stats['total_sales'] as double).toStringAsFixed(2)}', Icons.attach_money, Colors.green),
                const SizedBox(height: DesignSpacing.m),
                _buildSummaryCard('Total Items Sold', '${stats['total_orders']}', Icons.shopping_bag_outlined, Colors.blue),
                const SizedBox(height: DesignSpacing.xl),
                Text('Weekly Revenue', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: DesignSpacing.m),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(DesignSpacing.l),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignRadius.l),
                    border: Border.all(color: DesignColors.secondary),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: dailySales.entries.map((entry) {
                      final heightFactor = entry.value / maxDaily;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: '\$${entry.value.toStringAsFixed(2)}',
                            child: Container(
                              width: 30, // Fixed width bars
                              height: 150 * heightFactor,
                              decoration: BoxDecoration(
                                color: DesignColors.primary,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(entry.key, style: GoogleFonts.outfit(fontSize: 12, color: DesignColors.textSecondary)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.l),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignRadius.l),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: DesignSpacing.m),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 14)),
              Text(value, style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
