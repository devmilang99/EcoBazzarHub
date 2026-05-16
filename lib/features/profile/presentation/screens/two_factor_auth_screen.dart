import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Two-Factor Auth', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
            _buildOptionTile(
              title: 'SMS Verification',
              subtitle: 'Receive a code via SMS',
              icon: Icons.sms_rounded,
              isDark: isDark,
            ),
            _buildOptionTile(
              title: 'Email Verification',
              subtitle: 'Receive a code via Email',
              icon: Icons.email_rounded,
              isDark: isDark,
            ),
            _buildOptionTile(
              title: 'Authenticator App',
              subtitle: 'Use apps like Google Authenticator',
              icon: Icons.apps_rounded,
              isDark: isDark,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _is2FAEnabled = !_is2FAEnabled),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _is2FAEnabled ? Colors.redAccent.withValues(alpha: 0.1) : Colors.green[700],
                  foregroundColor: _is2FAEnabled ? Colors.redAccent : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(_is2FAEnabled ? 'Disable 2FA' : 'Enable 2FA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
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
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.verified_user_rounded, size: 64, color: Colors.green[700]),
        ),
        const SizedBox(height: 24),
        Text('Protect your account', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Two-factor authentication adds an extra layer of security to your account by requiring more than just a password to log in.', 
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildOptionTile({required String title, required String subtitle, required IconData icon, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () {},
      ),
    );
  }
}
