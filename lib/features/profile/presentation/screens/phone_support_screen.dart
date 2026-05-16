import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PhoneSupportScreen extends StatelessWidget {
  const PhoneSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Phone Support', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHero(isDark),
            const SizedBox(height: 40),
            _buildContactTile(
              title: 'Customer Service',
              number: '+977 1 4XXXXXX',
              subtitle: 'Available 9am - 6pm',
              isDark: isDark,
            ),
            _buildContactTile(
              title: 'Toll Free (NTC)',
              number: '1660 01 XXXXX',
              subtitle: 'Free for NTC users',
              isDark: isDark,
            ),
            _buildContactTile(
              title: 'Emergency Support',
              number: '+977 98XXXXXXXX',
              subtitle: 'Available 24/7',
              isDark: isDark,
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildHero(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.phone_in_talk_rounded, size: 64, color: Colors.orange),
        ),
        const SizedBox(height: 24),
        Text('Talk to us', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Prefer talking? Call us directly and our agents will assist you.', 
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildContactTile({required String title, required String number, required String subtitle, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(number, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_rounded, color: Colors.green),
            style: IconButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.1), padding: const EdgeInsets.all(12)),
          ),
        ],
      ),
    );
  }
}
