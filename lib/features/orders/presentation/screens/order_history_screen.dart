import 'package:eco_bazzar_hub/features/orders/domain/models/order_model.dart';
import 'package:eco_bazzar_hub/features/orders/presentation/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recentOrders = orders.where((o) => o.status != OrderStatus.cancelled && o.status != OrderStatus.delivered).toList();
    final completedOrders = orders.where((o) => o.status == OrderStatus.delivered).toList();
    final cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Orders',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(orders: recentOrders, isRecent: true),
          _OrderList(orders: completedOrders),
          _OrderList(orders: cancelledOrders),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isRecent;

  const _OrderList({required this.orders, this.isRecent = false});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index], isRecent: isRecent);
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final bool isRecent;

  const _OrderCard({required this.order, required this.isRecent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCancel = order.canCancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                order.id,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(order.orderDate),
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 24),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.product.image, width: 40, height: 40, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.product.name,
                    style: GoogleFonts.outfit(fontSize: 14),
                  ),
                ),
                Text('x${item.quantity}', style: GoogleFonts.outfit(color: Colors.grey)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          if (isRecent) _buildProgressBar(order.status),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[700]),
                  ),
                ],
              ),
              if (isRecent && canCancel)
                ElevatedButton(
                  onPressed: () => ref.read(orderProvider.notifier).cancelOrder(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel (20s)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else
                _buildStatusBadge(order.status),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildProgressBar(OrderStatus status) {
    int step = 0;
    if (status == OrderStatus.packing) step = 1;
    if (status == OrderStatus.sentToSeller) step = 2;
    if (status == OrderStatus.outForDelivery) step = 3;
    if (status == OrderStatus.delivered) step = 4;

    return Row(
      children: [
        _buildStepIcon(Icons.inventory_2_outlined, step >= 1, 'Packing'),
        _buildStepLine(step >= 2),
        _buildStepIcon(Icons.local_shipping_outlined, step >= 2, 'Shipped'),
        _buildStepLine(step >= 3),
        _buildStepIcon(Icons.delivery_dining_outlined, step >= 3, 'On Way'),
        _buildStepLine(step >= 4),
        _buildStepIcon(Icons.check_circle_outline_rounded, step >= 4, 'Done'),
      ],
    );
  }

  Widget _buildStepIcon(IconData icon, bool isActive, String label) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.green : Colors.grey[300], size: 20),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 8, color: isActive ? Colors.green : Colors.grey)),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: isActive ? Colors.green : Colors.grey[200],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = Colors.green;
    String text = status.toString().split('.').last.toUpperCase();
    
    if (status == OrderStatus.cancelled) {
      color = Colors.red;
    } else if (status == OrderStatus.packing) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
