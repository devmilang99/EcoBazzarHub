import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;
  final Color iconBgColor;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.iconBgColor,
  });
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Order Delivered',
      message: 'Your order #12345 has been delivered successfully. Enjoy your eco-friendly products!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      icon: Icons.local_shipping_rounded,
      iconBgColor: Colors.green,
    ),
    NotificationModel(
      id: '2',
      title: 'Flash Sale Alert!',
      message: 'Exclusive 20% off on all organic vegetables for the next 2 hours. Don\'t miss out!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.flash_on_rounded,
      iconBgColor: Colors.amber,
    ),
    NotificationModel(
      id: '3',
      title: 'Payment Successful',
      message: 'We have received your payment of Rs.45.00 for your latest purchase.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.account_balance_wallet_rounded,
      iconBgColor: Colors.blue,
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Price Drop',
      message: 'An item in your wishlist "Reusable Water Bottle" is now 10% cheaper.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.trending_down_rounded,
      iconBgColor: Colors.purple,
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'New Eco Tip',
      message: 'Did you know? Switching to LED bulbs can save up to 75% more energy.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.tips_and_updates_rounded,
      iconBgColor: Colors.teal,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: GoogleFonts.outfit(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _mockNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.outfit(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _mockNotifications.length,
              itemBuilder: (context, index) {
                final notification = _mockNotifications[index];
                return _NotificationTile(notification: notification)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? Colors.grey[900] : Colors.white)
            : (isDark ? Colors.green.withOpacity(0.1) : Colors.green[50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification.isRead
              ? (isDark ? Colors.grey[800]! : Colors.grey[200]!)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: notification.iconBgColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.icon,
            color: notification.iconBgColor,
            size: 24,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: GoogleFonts.outfit(
                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              _getTimeAgo(notification.timestamp),
              style: GoogleFonts.outfit(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            notification.message,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
