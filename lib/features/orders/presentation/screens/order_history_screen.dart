import 'dart:math' as math;
import 'package:eco_bazzar_hub/features/orders/domain/models/order_model.dart';
import 'package:eco_bazzar_hub/features/orders/presentation/providers/order_provider.dart';
import 'package:eco_bazzar_hub/features/orders/presentation/screens/order_receipt_screen.dart';
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
        .where(
          (o) =>
              o.status != OrderStatus.cancelled &&
              o.status != OrderStatus.delivered,
        )
        .toList();
    final completedOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();
    final cancelledOrders = orders
        .where((o) => o.status == OrderStatus.cancelled)
        .toList();

    // Count how many recent orders are still in cancellation window
    final pendingCount = recentOrders
        .where((o) => o.status == OrderStatus.pending)
        .length;

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
          _OrderList(orders: recentOrders, isRecent: true, tabType: 'recent'),
          _OrderList(
            orders: completedOrders,
            tabType: 'completed',
            showReceipt: true,
          ),
          _OrderList(orders: cancelledOrders, tabType: 'cancelled'),
        ],
      ),
    );
  }
}

// ── Order list ─────────────────────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isRecent;
  final bool showReceipt;
  final String tabType;

  const _OrderList({
    required this.orders,
    this.isRecent = false,
    this.showReceipt = false,
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
          showReceipt: showReceipt,
        );
      },
    );
  }
}

// ── Order card with live countdown ────────────────────────────────────────
class _OrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final bool isRecent;
  final bool showReceipt;

  const _OrderCard({
    super.key,
    required this.order,
    required this.isRecent,
    this.showReceipt = false,
  });

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  @override
  Widget build(BuildContext context) {
    // Watch live order state so this card rebuilds when provider ticks
    final orders = ref.watch(orderProvider);
    final order = orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPending = order.status == OrderStatus.pending;
    final secondsLeft = order.cancelSecondsLeft;
    final progress = secondsLeft / 10.0;
    final elapsed = DateTime.now().difference(order.placedAt).inSeconds;
    // Delivery progress only counts AFTER the 10s cancellation window closes.
    // deliveryElapsed runs 0→40 mapping to 0%→100% of the 40s delivery phase.
    final deliveryElapsed = math.max(0, elapsed - 10);
    final cycleProgress = math.max(0.0, math.min(deliveryElapsed / 40.0, 1.0));

    // Dynamic accent color based on status
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPending
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1.5)
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
              onCancel: () => _showCancelDialog(context, order),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(order.orderDate),
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(status: order.status, color: statusColor),
                  ],
                ),
                const Divider(height: 24),

                // Items — name, unit price, qty, line total
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 20,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '×${item.quantity}',
                          style: GoogleFonts.outfit(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Delivery progress — only shown in the Recent tab and AFTER
                // the 10-second cancellation window has fully expired.
                if (widget.isRecent && !isPending) ...[
                  const SizedBox(height: 20),
                  _buildCycleProgressBar(cycleProgress, order.status, isDark),
                  const SizedBox(height: 16),
                  _buildProgressBar(order.status, isDark),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Rs. ${order.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: statusColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                ],
                ),

                if (order.status == OrderStatus.cancelled && order.cancellationReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reason: ${order.cancellationReason}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Feedback & Rating (Delivered orders only) ────────────
                if (order.status == OrderStatus.delivered) ...[
                  const SizedBox(height: 12),
                  if (order.rating == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showRatingDialog(context, order),
                        icon: const Icon(Icons.star_outline_rounded, size: 16),
                        label: Text(
                          'Rate & Review',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < order.rating!
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: Colors.amber[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Feedback',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                          if (order.comment != null && order.comment!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              order.comment!,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],

                // ── View Receipt button (completed orders only) ──────────
                if (widget.showReceipt) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderReceiptScreen(order: order),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded, size: 16),
                      label: Text(
                        'View Receipt',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
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

  // Fixed: Uses LayoutBuilder instead of FittedBox so Expanded connectors
  // get bounded constraints — this was the root cause of the card not rendering.
  Widget _buildProgressBar(OrderStatus status, bool isDark) {
    int step = 0;
    if (status == OrderStatus.packing) step = 1;
    if (status == OrderStatus.sentToSeller) step = 2;
    if (status == OrderStatus.outForDelivery) step = 3;
    if (status == OrderStatus.delivered) step = 4;

    // 4 icons + 3 lines. Icon width = 34 (icon 18 + padding 8*2).
    // Line width = (available - 4 * 34) / 3.
    return LayoutBuilder(
      builder: (context, constraints) {
        const iconWidth = 34.0;
        const iconCount = 4;
        final lineWidth = math.max(
          8.0,
          (constraints.maxWidth - 16.0 - iconCount * iconWidth) / 3,
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepIcon(Icons.inventory_2_outlined, step >= 1, 'Packing'),
                  _buildStepLine(step >= 2, lineWidth),
                  _buildStepIcon(
                    Icons.local_shipping_outlined,
                    step >= 2,
                    'Shipped',
                  ),
                  _buildStepLine(step >= 3, lineWidth),
                  _buildStepIcon(
                    Icons.delivery_dining_outlined,
                    step >= 3,
                    'On Way',
                  ),
                  _buildStepLine(step >= 4, lineWidth),
                  _buildStepIcon(
                    Icons.check_circle_outline_rounded,
                    step >= 4,
                    'Done',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCycleProgressBar(
    double progress,
    OrderStatus status,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delivery Progress',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 12,
            width: double.infinity,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child:
                  AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[400]!, Colors.green[700]!],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIcon(IconData icon, bool isActive, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.green : Colors.grey[400],
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  // Fixed: No longer uses Expanded — uses explicit SizedBox width
  // computed by LayoutBuilder in _buildProgressBar.
  Widget _buildStepLine(bool isActive, double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: SizedBox(
        width: width,
        height: 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isActive ? Colors.green : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    final reasons = [
      'Changed my mind',
      'Found a better price elsewhere',
      'Delivery time is too long',
      'Order placed by mistake',
      'Shipping cost is too high',
      'Other',
    ];

    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Cancel Order',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please select a reason for cancellation:',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...reasons.map((reason) => RadioListTile<String>(
                    title: Text(reason, style: GoogleFonts.outfit(fontSize: 14)),
                    value: reason,
                    groupValue: selectedReason,
                    activeColor: Colors.red,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setDialogState(() => selectedReason = val),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Order', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      ref.read(orderProvider.notifier).cancelOrder(order.id, selectedReason!);
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Confirm Cancellation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderModel order) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Rate your experience',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber[700],
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us more (optional)',
                  hintStyle: GoogleFonts.outfit(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.outfit(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Later', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(orderProvider.notifier).updateOrderFeedback(
                      order.id,
                      rating,
                      commentController.text,
                    );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Submit Review', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

// ── Cancellation window card with premium design ────────────────────────────
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
    final urgentColor = secondsLeft <= 5
        ? const Color(0xFFE63946)
        : const Color(0xFFF4A261);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
          urgentColor.withValues(alpha: 0.15),
          urgentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: urgentColor.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          // Circular countdown ring with pulse effect
          SizedBox(
            width: 56,
            height: 56,
            child:
                Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(56, 56),
                          painter: _CountdownRingPainter(
                            progress: progress,
                            color: urgentColor,
                          ),
                        ),
                        Text(
                          '$secondsLeft',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: urgentColor,
                          ),
                        ),
                      ],
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 500.ms,
                      curve: Curves.easeInOut,
                    ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: urgentColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'CANCELLATION WINDOW',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1,
                          color: urgentColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  secondsLeft > 5
                      ? 'You can still change your mind'
                      : 'Hurry! Window closing soon...',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AnimatedCancelButton(onPressed: onCancel, color: urgentColor),
        ],
      ),
    );
  }
}

class _AnimatedCancelButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;

  const _AnimatedCancelButton({required this.onPressed, required this.color});

  @override
  State<_AnimatedCancelButton> createState() => _AnimatedCancelButtonState();
}

class _AnimatedCancelButtonState extends State<_AnimatedCancelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered ? widget.color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color, width: 2),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          'CANCEL',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
            color: _isHovered ? Colors.white : widget.color,
          ),
        ),
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
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
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
                    color: (config['shadowColor'] as Color).withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Icon(
                config['icon'] as IconData,
                size: 58,
                color: Colors.white,
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: config['shadowColor'] as Color,
                    size: 18,
                  ),
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
