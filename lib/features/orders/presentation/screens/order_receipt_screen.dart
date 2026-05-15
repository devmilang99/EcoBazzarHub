import 'dart:io';
import 'dart:math' as math;
import 'package:eco_bazzar_hub/features/cart/domain/models/cart_item.dart';
import 'package:eco_bazzar_hub/features/orders/domain/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderReceiptScreen extends StatelessWidget {
  final OrderModel order;
  const OrderReceiptScreen({super.key, required this.order});

  // ── Plain-text receipt for sharing / saving ──────────────────────────────
  String _buildReceiptText() {
    final buf = StringBuffer();
    buf.writeln('================================');
    buf.writeln('        ECO BAZZAR HUB');
    buf.writeln('         OFFICIAL RECEIPT');
    buf.writeln('================================');
    buf.writeln('Order : ${order.id}');
    buf.writeln(
      'Date  : ${DateFormat('MMM dd, yyyy  hh:mm a').format(order.orderDate)}',
    );
    buf.writeln('--------------------------------');
    buf.writeln('ITEMS:');
    for (final item in order.items) {
      final lineTotal = item.product.price * item.quantity;
      buf.writeln('  ${item.product.name}');
      buf.writeln(
        '    x${item.quantity} @ Rs. ${item.product.price.toStringAsFixed(2)}'
        ' = Rs. ${lineTotal.toStringAsFixed(2)}',
      );
    }
    buf.writeln('--------------------------------');
    buf.writeln('Subtotal : Rs. ${order.subtotal.toStringAsFixed(2)}');
    buf.writeln('Tax (5%) : Rs. ${order.taxAmount.toStringAsFixed(2)}');
    if (order.discountAmount > 0) {
      buf.writeln('Discount : -Rs. ${order.discountAmount.toStringAsFixed(2)}');
    }
    buf.writeln('TOTAL    : Rs. ${order.totalAmount.round()}');
    buf.writeln('================================');
    buf.writeln('Status   : DELIVERED ✓');
    buf.writeln('Thank you for shopping at EcoBazzarHub!');
    buf.writeln('================================');
    return buf.toString();
  }

  Future<void> _share(BuildContext context) async {
    await Share.share(
      _buildReceiptText(),
      subject: 'EcoBazzarHub Receipt — ${order.id}',
    );
  }

  Future<void> _download(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'receipt_${order.id}.txt';
      await File('${dir.path}/$filename').writeAsString(_buildReceiptText());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to Documents/$filename'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not save receipt.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : const Color(0xFFEFF6EF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Receipt',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context),
          ),
        ],
      ),
      // ── Bottom action bar ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _download(context),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Download',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  side: BorderSide(color: Colors.green[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _share(context),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: Text(
                  'Share',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                  shadowColor: Colors.green.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
      // ── Receipt body ────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header gradient ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B4332),
                      Color(0xFF2D6A4F),
                      Color(0xFF52B788),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EcoBazzarHub',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Official Receipt',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeaderInfo(
                          label: 'Order ID',
                          value: order.id,
                          align: CrossAxisAlignment.start,
                        ),
                        _HeaderInfo(
                          label: 'Date',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(order.orderDate),
                          align: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeaderInfo(
                          label: 'Time',
                          value: DateFormat('hh:mm a').format(order.orderDate),
                          align: CrossAxisAlignment.start,
                        ),
                        _HeaderInfo(
                          label: 'Items',
                          value:
                              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                          align: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Tear line ─────────────────────────────────────────────
              _TearLine(bg: bg),

              // 2. Shop Info (New)
              _buildSectionHeader(
                'Seller Information',
                Icons.storefront_rounded,
                isDark,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.green.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.first.sellerName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Verified Sustainable Seller',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Items Summary
              _buildSectionHeader(
                'Order Summary',
                Icons.summarize_outlined,
                isDark,
              ),

              // ── Items ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...order.items.map(
                      (item) => _ReceiptItemRow(item: item, isDark: isDark),
                    ),
                  ],
                ),
              ),

              // ── Dashed divider ────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _DashedDivider(),
              ),

              // ── Calculations ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _CalcRow(
                      label: 'Subtotal',
                      value: 'Rs. ${order.subtotal.toStringAsFixed(2)}',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    _CalcRow(
                      label: 'Tax (5%)',
                      value: 'Rs. ${order.taxAmount.toStringAsFixed(2)}',
                      isDark: isDark,
                    ),
                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      _CalcRow(
                        label: 'Discount',
                        value:
                            '-Rs. ${order.discountAmount.toStringAsFixed(2)}',
                        isDark: isDark,
                        isDiscount: true,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Colors.green[900]!, Colors.green[800]!]
                              : [Colors.green[50]!, Colors.green[100]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Paid',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? Colors.green[300]
                                  : Colors.green[900],
                            ),
                          ),
                          Text(
                            'Rs. ${order.totalAmount.round()}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: isDark
                                  ? Colors.green[300]
                                  : Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ── Footer ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : const Color(0xFFF7FAF7),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    // Decorative barcode
                    SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(40, (i) {
                          final rng = math.Random(order.id.hashCode + i * 7);
                          final h = 14.0 + rng.nextDouble() * 28;
                          final w = 1.5 + rng.nextDouble() * 2.0;
                          return Container(
                            width: w,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.id,
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 10,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for shopping with EcoBazzarHub!',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'eco · sustainable · community',
                      style: GoogleFonts.outfit(
                        color: Colors.green[400],
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _HeaderInfo extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;
  const _HeaderInfo({
    required this.label,
    required this.value,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ReceiptItemRow extends StatelessWidget {
  final CartItem item;
  final bool isDark;
  const _ReceiptItemRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.product.price * item.quantity;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 22,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${item.product.price.toStringAsFixed(2)} × ${item.quantity}',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Rs. ${lineTotal.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isDiscount;
  const _CalcRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDiscount
                ? Colors.red[400]
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _TearLine extends StatelessWidget {
  final Color bg;
  const _TearLine({required this.bg});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, cs) {
              final count = (cs.maxWidth / 9).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  count,
                  (_) => Container(
                    width: 5,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, cs) {
        final count = (cs.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: 5,
              height: 1.5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      },
    );
  }
}
