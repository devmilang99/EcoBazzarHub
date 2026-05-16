import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlatformGuidesScreen extends StatelessWidget {
  const PlatformGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Platform Guides', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGuideCard(title: 'Getting Started', icon: Icons.rocket_launch_rounded, color: Colors.orange, isDark: isDark),
          _buildGuideCard(title: 'Buying Guide', icon: Icons.shopping_cart_rounded, color: Colors.blue, isDark: isDark),
          _buildGuideCard(title: 'Selling Guide', icon: Icons.store_rounded, color: Colors.green, isDark: isDark),
          _buildGuideCard(title: 'Security Tips', icon: Icons.gpp_good_rounded, color: Colors.red, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildGuideCard({required String title, required IconData icon, required Color color, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(title, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
