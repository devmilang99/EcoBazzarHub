import 'package:eco_bazzar_hub/features/profile/presentation/screens/active_sessions_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/biometric_settings_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/change_password_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/recovery_email_screen.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/two_factor_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Security',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSecurityHero(isDark),
          const SizedBox(height: 32),
          _buildSectionHeader('Login & Recovery'),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Last changed 3 months ago',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildActionTile(
            icon: Icons.alternate_email_rounded,
            title: 'Recovery Email',
            subtitle: 'manage your recovery options',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecoveryEmailScreen()),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Advanced Security'),
          _buildActionTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Login',
            subtitle: 'Manage FaceID or Fingerprint',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BiometricSettingsScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildActionTile(
            icon: Icons.security_rounded,
            title: 'Two-Factor Auth',
            subtitle: 'Secure your account via SMS/Email',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TwoFactorAuthScreen()),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Devices'),
          _buildActionTile(
            icon: Icons.devices_rounded,
            title: 'Active Sessions',
            subtitle: 'Manage devices where you are logged in',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActiveSessionsScreen()),
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityHero(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, color: Colors.blue[700], size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'Keep your account safe',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your security settings and active sessions regularly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
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

  Widget _buildActionTile({
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue[700], size: 24),
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

