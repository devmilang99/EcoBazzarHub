import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Active Sessions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSessionTile(
            device: 'iPhone 13 Pro',
            location: 'Kathmandu, Nepal',
            time: 'Current Session',
            icon: Icons.phone_iphone_rounded,
            isCurrent: true,
            isDark: isDark,
          ),
          _buildSessionTile(
            device: 'Windows PC - Chrome',
            location: 'Lalitpur, Nepal',
            time: 'Active 2 hours ago',
            icon: Icons.laptop_windows_rounded,
            isCurrent: false,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            label: Text('Logout from all other devices', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile({required String device, required String location, required String time, required IconData icon, required bool isCurrent, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: Colors.green[700]!, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: isCurrent ? Colors.green[700] : Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$location • $time', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
              onPressed: () {},
            ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}
