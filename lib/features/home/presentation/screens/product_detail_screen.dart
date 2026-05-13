import 'package:eco_bazzar_hub/features/cart/domain/models/cart_item.dart';
import 'package:eco_bazzar_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:eco_bazzar_hub/features/dashboard/presentation/screens/dashboard_screen.dart'
    as dashboard;
import 'package:eco_bazzar_hub/features/orders/presentation/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eco_bazzar_hub/features/home/domain/models/product_model.dart';
import '../viewmodels/home_viewmodel.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _showAllReviews = false;
  String _selectedPaymentMethod = 'Credit Card';

  static const String sellerName = 'Eco Store';
  static const String sellerLocation = 'Kathmandu, Nepal';
  static const double sellerRating = 4.9;

  static const List<_CustomerReview> _reviews = [
    _CustomerReview(
      name: 'Anita Sharma',
      rating: 5,
      date: 'May 12, 2026',
      review:
          'Loved the premium feel and the eco packaging. The product arrived fresh and thoughtfully packed.',
    ),
    _CustomerReview(
      name: 'Rohit Gurung',
      rating: 4,
      date: 'May 8, 2026',
      review:
          'Great value for sustainable shoppers. The texture is excellent and shipping was fast.',
    ),
    _CustomerReview(
      name: 'Mina Lama',
      rating: 5,
      date: 'Apr 29, 2026',
      review:
          'Fantastic quality, exactly what I needed for my healthy lifestyle routine.',
    ),
    _CustomerReview(
      name: 'Sanju KC',
      rating: 4,
      date: 'Apr 25, 2026',
      review:
          'Good product overall. Seller support was friendly and responsive.',
    ),
  ];

  void _showCheckoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductCheckoutSheet(
        product: widget.product,
        quantity: _quantity,
        sellerName: sellerName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeNotifier = ref.read(homeViewModelProvider.notifier);
    final displayedReviews = _showAllReviews
        ? _reviews
        : _reviews.take(2).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Unique Animated Header with Hero
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: Icon(
                      widget.product.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: widget.product.isFavorite
                          ? Colors.red
                          : Colors.white,
                      size: 20,
                    ),
                    onPressed: () =>
                        homeNotifier.toggleFavorite(widget.product.id),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: 'product_${widget.product.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(widget.product.image, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company & ID Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'EcoBazzar Premium',
                          style: GoogleFonts.outfit(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ).animate().fadeIn().slideX(),
                      Text(
                        'ID: #${widget.product.id.padLeft(6, '0')}',
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Name
                  Text(
                    widget.product.name,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),

                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 (120 Reviews)',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),

                  // Short Description
                  Text(
                    'Description',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: GoogleFonts.outfit(color: Colors.grey, height: 1.6),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeatureBadge(label: 'Eco-certified'),
                      _FeatureBadge(label: 'Fast shipping'),
                      _FeatureBadge(label: 'Organic ingredients'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.green[50],
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sellerName,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sellerLocation,
                                style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$sellerRating seller rating',
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey[600],
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
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Customer Reviews',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: displayedReviews
                        .map((review) => _ReviewCard(review: review))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _showAllReviews = !_showAllReviews),
                      child: Text(
                        _showAllReviews ? 'Show less' : 'See all',
                        style: GoogleFonts.outfit(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(
                                () => _quantity = _quantity > 1
                                    ? _quantity - 1
                                    : 1,
                              ),
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            Text(
                              '$_quantity',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            for (int i = 0; i < _quantity; i++) {
                              ref
                                  .read(cartProvider.notifier)
                                  .addToCart(widget.product);
                            }
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${_quantity}x ${widget.product.name} added to cart',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 1),
                                action: SnackBarAction(
                                  label: 'View',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ref
                                            .read(
                                              dashboard
                                                  .dashboardIndexProvider
                                                  .notifier,
                                            )
                                            .state =
                                        1;
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Add to Cart',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showCheckoutSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Buy Now',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final String label;
  const _FeatureBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: isDark ? Colors.white : Colors.green[800],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ProductCheckoutSheet extends ConsumerStatefulWidget {
  final ProductModel product;
  final int quantity;
  final String sellerName;

  const _ProductCheckoutSheet({
    required this.product,
    required this.quantity,
    required this.sellerName,
  });

  @override
  ConsumerState<_ProductCheckoutSheet> createState() =>
      _ProductCheckoutSheetState();
}

class _ProductCheckoutSheetState extends ConsumerState<_ProductCheckoutSheet> {
  String _selectedPaymentMethod = 'Credit Card';
  String? _selectedVoucher;

  double get subtotal => widget.product.price * widget.quantity;
  double get tax => subtotal * 0.05;
  double get discount =>
      _selectedVoucher == 'ECO20'
          ? subtotal * 0.2
          : (_selectedVoucher == 'WELCOME10' ? subtotal * 0.1 : 0);
  double get total => subtotal + tax - discount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Summary',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Product Info Section
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.product.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${widget.quantity} · Seller: ${widget.sellerName}',
                      style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.product.price}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Voucher Section
          Text(
            'Voucher',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Select voucher',
                  style: GoogleFonts.outfit(fontSize: 14),
                ),
                value: _selectedVoucher,
                items: [
                  DropdownMenuItem(
                    value: 'WELCOME10',
                    child: Text(
                      'WELCOME10 (10% OFF)',
                      style: GoogleFonts.outfit(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'ECO20',
                    child: Text(
                      'ECO20 (20% OFF)',
                      style: GoogleFonts.outfit(fontSize: 14),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedVoucher = val),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment Method
          Text(
            'Payment Method',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PaymentMethodButton(
                label: 'Cash',
                icon: Icons.money,
                isSelected: _selectedPaymentMethod == 'Cash on Delivery',
                onTap:
                    () => setState(
                      () => _selectedPaymentMethod = 'Cash on Delivery',
                    ),
              ),
              const SizedBox(width: 12),
              _PaymentMethodButton(
                label: 'Card',
                icon: Icons.credit_card,
                isSelected: _selectedPaymentMethod == 'Credit Card',
                onTap:
                    () => setState(() => _selectedPaymentMethod = 'Credit Card'),
              ),
              const SizedBox(width: 12),
              _PaymentMethodButton(
                label: 'Pay',
                icon: Icons.payment,
                isSelected: _selectedPaymentMethod == 'Google Pay',
                onTap:
                    () => setState(() => _selectedPaymentMethod = 'Google Pay'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Calculations
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[950] : Colors.green[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _CalculationRow(label: 'Subtotal', value: subtotal),
                const SizedBox(height: 8),
                _CalculationRow(label: 'Tax (5%)', value: tax),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  _CalculationRow(
                    label: 'Discount',
                    value: -discount,
                    isDiscount: true,
                  ),
                ],
                const Divider(height: 24),
                _CalculationRow(
                  label: 'Total Amount',
                  value: total,
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              ref.read(orderProvider.notifier).placeOrder([
                CartItem(
                  product: widget.product,
                  quantity: widget.quantity,
                  sellerName: widget.sellerName,
                ),
              ], total);

              Navigator.pop(context); // Close sheet
              Navigator.pop(context); // Go back to home

              ref.read(dashboard.dashboardIndexProvider.notifier).state =
                  2; // Go to orders tab

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order placed successfully!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green[700],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            child: Text(
              'Confirm Order',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.green
                    : (isDark ? Colors.grey[900] : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.green
                      : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculationRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isDiscount;
  final bool isTotal;

  const _CalculationRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color:
                isTotal
                    ? Colors.green[800]
                    : (isDiscount ? Colors.red : Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _CustomerReview {
  final String name;
  final int rating;
  final String date;
  final String review;

  const _CustomerReview({
    required this.name,
    required this.rating,
    required this.date,
    required this.review,
  });
}

class _ReviewCard extends StatelessWidget {
  final _CustomerReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green[50],
                child: Text(
                  review.name.substring(0, 1),
                  style: GoogleFonts.outfit(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.date,
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.review,
            style: GoogleFonts.outfit(color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}
