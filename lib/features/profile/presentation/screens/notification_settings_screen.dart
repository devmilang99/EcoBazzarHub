import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promoOffers = false;
  bool _newsLetter = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildToggleSection(
            title: 'Push Notifications',
            subtitle: 'Master toggle for all push notifications',
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Text('Activity Notifications', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Order Updates',
            subtitle: 'Get notified about your order status',
            value: _orderUpdates,
            onChanged: (v) => setState(() => _orderUpdates = v),
            isDark: isDark,
          ),
          _buildToggleTile(
            title: 'Promotional Offers',
            subtitle: 'Deals, coupons, and discounts',
            value: _promoOffers,
            onChanged: (v) => setState(() => _promoOffers = v),
            isDark: isDark,
          ),
          _buildToggleTile(
            title: 'EcoBazzar Newsletter',
            subtitle: 'Weekly highlights and stories',
            value: _newsLetter,
            onChanged: (v) => setState(() => _newsLetter = v),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeThumbColor: Colors.white, activeTrackColor: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildToggleTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: Colors.green[700]),
      ),
    ).animate().fadeIn().slideX();
  }
}
