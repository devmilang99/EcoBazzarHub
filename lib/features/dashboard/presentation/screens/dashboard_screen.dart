import 'package:eco_bazzar_hub/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:eco_bazzar_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:eco_bazzar_hub/features/cart/presentation/screens/cart_screen.dart';
import 'package:eco_bazzar_hub/features/home/presentation/screens/home_screen.dart';
import 'package:eco_bazzar_hub/features/orders/presentation/screens/order_history_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;

final dashboardIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App went to background
      debugPrint('App went to background');
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      debugPrint('App resumed from background');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(dashboardIndexProvider);
    final cartItemsCount = ref.watch(cartProvider).items.length;
    final authState = ref.watch(authViewModelProvider);
    final userPhotoUrl = authState.user?.photoUrl;

    final List<Widget> screens = [
      const HomeScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap:
                  (index) =>
                      ref.read(dashboardIndexProvider.notifier).state = index,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.green[700],
              unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[500],
              showSelectedLabels: true,
              showUnselectedLabels: true,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: cartItemsCount > 0,
                    badgeContent: Text(
                      cartItemsCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.green,
                    ),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  activeIcon: badges.Badge(
                    showBadge: cartItemsCount > 0,
                    badgeContent: Text(
                      cartItemsCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.green,
                    ),
                    child: const Icon(Icons.shopping_cart_rounded),
                  ),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history_rounded),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon:
                      userPhotoUrl != null
                          ? CircleAvatar(
                            radius: 13,
                            backgroundImage: NetworkImage(userPhotoUrl),
                            backgroundColor: Colors.grey[300],
                          )
                          : const Icon(Icons.person_outline_rounded),
                  activeIcon:
                      userPhotoUrl != null
                          ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green[700]!,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 13,
                              backgroundImage: NetworkImage(userPhotoUrl),
                              backgroundColor: Colors.grey[300],
                            ),
                          )
                          : const Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
