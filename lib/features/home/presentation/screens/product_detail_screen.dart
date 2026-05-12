import 'package:eco_bazzar_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:eco_bazzar_hub/features/dashboard/presentation/screens/dashboard_screen.dart';
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
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeNotifier = ref.read(homeViewModelProvider.notifier);
    
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
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
                      widget.product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: widget.product.isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                    onPressed: () => homeNotifier.toggleFavorite(widget.product.id),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company & ID Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
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
                    style: GoogleFonts.outfit(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  
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
                              onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
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
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: BorderSide(color: Colors.green[800]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            'Add to Favourite',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
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
                                    '${_quantity}x ${widget.product.name} added to cart'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 1),
                                action: SnackBarAction(
                                  label: 'View',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ref
                                        .read(dashboardIndexProvider.notifier)
                                        .state = 1;
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Add to Cart',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
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
