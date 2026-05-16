import 'package:eco_bazzar_hub/features/profile/presentation/screens/email_support_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/faq_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/live_chat_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/phone_support_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/platform_guides_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Support & Help',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSupportHeader(isDark),
          const SizedBox(height: 32),
          _buildSectionHeader('Contact Us'),
          _buildContactCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Wait time: < 2 mins',
            trailing: 'Online',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveChatScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildContactCard(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: 'Mon-Fri, 9am - 6pm',
            trailing: '+977 1...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PhoneSupportScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'Response within 24 hours',
            trailing: 'Send',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmailSupportScreen()),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Helpful Resources'),
          _buildResourceTile(
            icon: Icons.help_outline_rounded,
            title: 'FAQ',
            subtitle: 'Quick answers to common questions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildResourceTile(
            icon: Icons.article_outlined,
            title: 'Platform Guides',
            subtitle: 'Learn how to use EcoBazzar Hub',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlatformGuidesScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildResourceTile(
            icon: Icons.security_outlined,
            title: 'Privacy Policy',
            subtitle: 'Your data and how we use it',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 56),
          const SizedBox(height: 20),
          Text(
            'How can we help?',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our team is online and ready to assist you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(duration: 500.ms);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue[700], size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            trailing,
            style: GoogleFonts.outfit(
              color: Colors.green[700],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.grey[600], size: 24),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
