import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _faceIdEnabled = true;
  bool _fingerprintEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Biometrics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeroSection(isDark),
          const SizedBox(height: 32),
          _buildToggleTile(
            title: 'Face ID',
            subtitle: 'Use facial recognition to unlock',
            icon: Icons.face_retouching_natural_rounded,
            value: _faceIdEnabled,
            onChanged: (v) => setState(() => _faceIdEnabled = v),
            isDark: isDark,
          ),
          _buildToggleTile(
            title: 'Fingerprint',
            subtitle: 'Use touch sensor to unlock',
            icon: Icons.fingerprint_rounded,
            value: _fingerprintEnabled,
            onChanged: (v) => setState(() => _fingerprintEnabled = v),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(Icons.security_rounded, size: 64, color: Colors.blue[700]),
          const SizedBox(height: 20),
          Text('Faster & More Secure', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Biometric authentication adds an extra layer of protection to your account.', 
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildToggleTile({required String title, required String subtitle, required IconData icon, required bool value, required ValueChanged<bool> onChanged, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700]),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: Colors.blue[700]),
      ),
    );
  }
}
