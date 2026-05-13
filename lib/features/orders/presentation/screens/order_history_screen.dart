import 'dart:math' as math;
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

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
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

    final recentOrders = orders
        .where((o) =>
            o.status != OrderStatus.cancelled &&
            o.status != OrderStatus.delivered)
        .toList();
    final completedOrders =
        orders.where((o) => o.status == OrderStatus.delivered).toList();
    final cancelledOrders =
        orders.where((o) => o.status == OrderStatus.cancelled).toList();

    // Count how many recent orders are still in cancellation window
    final pendingCount =
        recentOrders.where((o) => o.status == OrderStatus.pending).length;

    // Dynamic colors based on selection and status
    Color activeColor = Colors.green;
    if (_tabController.index == 0 && pendingCount > 0) {
      activeColor = Colors.orange;
    } else if (_tabController.index == 2) {
      activeColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'My Orders',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: activeColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: activeColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Recent'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    _PulsingBadge(count: pendingCount),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Completed'),
                  if (completedOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _CountBadge(
                        count: completedOrders.length,
                        color: Colors.green[700]!),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Cancelled'),
                  if (cancelledOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _CountBadge(
                        count: cancelledOrders.length, color: Colors.red),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(orders: recentOrders, isRecent: true, tabType: 'recent'),
          _OrderList(orders: completedOrders, tabType: 'completed'),
          _OrderList(orders: cancelledOrders, tabType: 'cancelled'),
        ],
      ),
    );
  }
}

// ── Live pulsing badge for pending orders ──────────────────────────────────
class _PulsingBadge extends StatelessWidget {
  final int count;
  const _PulsingBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.outfit(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: Colors.orange.shade200,
        );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.outfit(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Order list ─────────────────────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isRecent;
  final String tabType;

  const _OrderList({
    required this.orders,
    this.isRecent = false,
    this.tabType = 'recent',
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyOrderState(tabType: tabType);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderCard(
          key: ValueKey(orders[index].id),
          order: orders[index],
          isRecent: isRecent,
        );
      },
    );
  }
}

// ── Order card with live countdown ────────────────────────────────────────
class _OrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final bool isRecent;

  const _OrderCard({super.key, required this.order, required this.isRecent});

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  @override
  Widget build(BuildContext context) {
    // Watch live order state so this card rebuilds when provider ticks
    final orders = ref.watch(orderProvider);
    final order =
        orders.firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPending = order.status == OrderStatus.pending;
    final secondsLeft = order.cancelSecondsLeft;
    final progress = secondsLeft / 10.0; // Updated to 10s
    final elapsed = DateTime.now().difference(order.placedAt).inSeconds;
    final cycleProgress = math.min(elapsed / 50.0, 1.0); // 50s mock cycle

    // Dynamic accent color based on status
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPending
            ? Border.all(
                color: Colors.orange.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Cancellation banner (pending only) ──────────────────────
          if (isPending)
            _CancellationBanner(
              secondsLeft: secondsLeft,
              progress: progress,
              onCancel: () =>
                  ref.read(orderProvider.notifier).cancelOrder(order.id),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(order.orderDate),
                          style: GoogleFonts.outfit(
                              color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    _StatusBadge(status: order.status, color: statusColor),
                  ],
                ),
                const Divider(height: 24),

                // Items
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.image,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: GoogleFonts.outfit(fontSize: 14),
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mock 50s Cycle Progress Bar
                if (widget.isRecent) ...[
                  const SizedBox(height: 20),
                  _buildCycleProgressBar(cycleProgress, order.status, isDark),
                  const SizedBox(height: 16),
                  _buildProgressBar(order.status, isDark),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style:
                              GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08, end: 0);
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.packing:
        return Colors.blue;
      case OrderStatus.sentToSeller:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildProgressBar(OrderStatus status, bool isDark) {
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
        _buildStepIcon(
            Icons.check_circle_outline_rounded, step >= 4, 'Done'),
      ],
    );
  }

  Widget _buildCycleProgressBar(double progress, OrderStatus status, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delivery Progress',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[700]!],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIcon(IconData icon, bool isActive, String label) {
    return Column(
      children: [
        Icon(icon,
            color: isActive ? Colors.green : Colors.grey[300], size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
              fontSize: 8,
              color: isActive ? Colors.green : Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: isActive ? Colors.green : Colors.grey[200],
        ),
      ),
    );
  }
}

// ── Cancellation banner with circular countdown ────────────────────────────
class _CancellationBanner extends StatelessWidget {
  final int secondsLeft;
  final double progress;
  final VoidCallback onCancel;

  const _CancellationBanner({
    required this.secondsLeft,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urgentColor =
        secondsLeft <= 5 ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: urgentColor.withValues(alpha: isDark ? 0.15 : 0.07),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Circular countdown ring
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(48, 48),
                  painter: _CountdownRingPainter(
                    progress: progress,
                    color: urgentColor,
                  ),
                ),
                Text(
                  '$secondsLeft',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: urgentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secondsLeft > 5
                      ? 'Cancellation window open'
                      : 'Closing soon!',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: urgentColor,
                  ),
                ),
                Text(
                  'You can cancel within $secondsLeft second${secondsLeft == 1 ? '' : 's'}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: urgentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arc painter for countdown ring ────────────────────────────────────────
class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CountdownRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;

    // Track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Status badge ───────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  String get _label {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.packing:
        return 'PACKING';
      case OrderStatus.sentToSeller:
        return 'SHIPPED';
      case OrderStatus.outForDelivery:
        return 'ON THE WAY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: GoogleFonts.outfit(
            color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────
class _EmptyOrderState extends StatelessWidget {
  final String tabType;
  const _EmptyOrderState({required this.tabType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getConfig(tabType);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  colors: config['colors'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (config['shadowColor'] as Color)
                        .withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Icon(config['icon'] as IconData,
                  size: 58, color: Colors.white),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 28),
            Text(
              config['title'] as String,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 10),
            Text(
              config['subtitle'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.55,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: config['shadowColor'] as Color, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    config['tip'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String type) {
    switch (type) {
      case 'completed':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'colors': [Colors.green[600]!, Colors.green[400]!],
          'shadowColor': Colors.green,
          'title': 'No Completed Orders',
          'subtitle':
              'Orders you\'ve received will appear here.\nKeep shopping to fill this up!',
          'tip': 'Delivered orders show here',
        };
      case 'cancelled':
        return {
          'icon': Icons.cancel_outlined,
          'colors': [Colors.red[500]!, Colors.red[300]!],
          'shadowColor': Colors.red,
          'title': 'No Cancelled Orders',
          'subtitle':
              'Great news — you haven\'t cancelled\nany orders. Keep it up!',
          'tip': 'Cancelled orders appear here',
        };
      default:
        return {
          'icon': Icons.shopping_bag_outlined,
          'colors': [Colors.blue[600]!, Colors.blue[400]!],
          'shadowColor': Colors.blue,
          'title': 'No Active Orders',
          'subtitle':
              'You don\'t have any orders in progress.\nPlace an order to get started!',
          'tip': 'Active orders are tracked here',
        };
    }
  }
}

