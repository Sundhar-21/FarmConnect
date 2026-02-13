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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Orders', style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: DesignColors.textSecondary.withOpacity(0.2)),
                  const SizedBox(height: DesignSpacing.m),
                  Text('No orders yet', style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSpacing.l),
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
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final color = status == 'delivered' ? Colors.green : (status == 'pending' ? Colors.orange : Colors.blue);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.m),
      padding: const EdgeInsets.all(DesignSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.l),
        border: Border.all(color: DesignColors.secondary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order['id'].toString().substring(0, 8)}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignRadius.s),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSpacing.s),
          Text(
            'Total: \$${order['total_amount']}',
            style: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignSpacing.s),
          Text(
            'Date: ${DateTime.parse(order['created_at']).toLocal().toString().substring(0, 16)}',
            style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
