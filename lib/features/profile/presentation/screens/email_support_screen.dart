import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmailSupportScreen extends StatelessWidget {
  const EmailSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Email Support', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(isDark),
            const SizedBox(height: 40),
            Text('Compose your message', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildInputField(label: 'Subject', hint: 'What is this about?', isDark: isDark),
            const SizedBox(height: 16),
            _buildInputField(label: 'Message', hint: 'Describe your issue in detail...', maxLines: 5, isDark: isDark),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
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
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.alternate_email_rounded, size: 64, color: Colors.blue),
        ),
        const SizedBox(height: 24),
        Text('Write to us', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Send us an email and we will get back to you within 24 hours.', 
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, required String hint, int maxLines = 1, required bool isDark}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
