import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/core/services/supabase_service.dart';

final ordersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  final response = await supabase
      .from('orders')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DesignSpacing.s),
                    Text(
                      'My Orders',
                      style: GoogleFonts.outfit(
                        color: DesignColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your deliveries',
                      style: GoogleFonts.outfit(
                        color: DesignColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: DesignColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: DesignColors.primary.withOpacity(0.3),
                              ),
                            ),
                            const SizedBox(height: DesignSpacing.l),
                            Text(
                              'No orders yet',
                              style: GoogleFonts.outfit(
                                color: DesignColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: DesignSpacing.s),
                            Text(
                              'Your order history will appear here',
                              style: GoogleFonts.outfit(
                                color: DesignColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(DesignSpacing.m),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(order);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: DesignColors.primary)),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignSpacing.xl),
                      child: Text('Error: $err', style: TextStyle(color: Colors.red.shade300)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'delivered':
        statusColor = DesignColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'pending':
        statusColor = DesignColors.warning;
        statusIcon = Icons.access_time_rounded;
        break;
      default:
        statusColor = DesignColors.primary;
        statusIcon = Icons.local_shipping_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.m),
      padding: const EdgeInsets.all(DesignSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.xl),
        boxShadow: DesignShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: DesignSpacing.s),
                  Text(
                    'Order #${order['id'].toString().substring(0, 8)}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [statusColor, statusColor.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(DesignRadius.full),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '\$${order['total_amount']}',
                    style: GoogleFonts.outfit(color: DesignColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ordered on',
                    style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    DateTime.parse(order['created_at']).toLocal().toString().substring(0, 10),
                    style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
