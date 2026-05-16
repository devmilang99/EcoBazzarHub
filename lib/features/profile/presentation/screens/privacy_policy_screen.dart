import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: January 2026', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Information We Collect',
              content: 'We collect information that you provide directly to us when you create an account, make a purchase, or communicate with us.',
            ),
            _buildSection(
              title: '2. How We Use Information',
              content: 'We use the information we collect to provide, maintain, and improve our services, process transactions, and send you related information.',
            ),
            _buildSection(
              title: '3. Data Security',
              content: 'We take reasonable measures to help protect information about you from loss, theft, misuse, and unauthorized access.',
            ),
            _buildSection(
              title: '4. Your Choices',
              content: 'You can update your account information at any time by logging into your account settings.',
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.outfit(color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }
}
