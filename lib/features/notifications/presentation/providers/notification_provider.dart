import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    IconData? icon,
    Color? iconBgColor,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconBgColor: iconBgColor ?? this.iconBgColor,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super(_initialNotifications);

  static final List<NotificationModel> _initialNotifications = [
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

  void markAsRead(String id) {
    state = [
      for (final notification in state)
        if (notification.id == id)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
