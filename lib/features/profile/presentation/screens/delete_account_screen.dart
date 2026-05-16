import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Delete Account', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDangerCard(isDark),
            const SizedBox(height: 32),
            _buildWarningText('This action is permanent and cannot be undone.'),
            _buildWarningText('All your order history and saved data will be wiped.'),
            _buildWarningText('Any active vouchers or points will be lost.'),
            const Spacer(),
            CheckboxListTile(
              value: _confirmed,
              onChanged: (v) => setState(() => _confirmed = v!),
              title: Text('I understand the consequences and want to delete my account permanently.', 
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.red,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmed ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
                ),
                child: Text('Delete My Account', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildDangerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.delete_forever_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Permanent Deletion', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900])),
          const SizedBox(height: 8),
          Text('We are sorry to see you go. Deleting your account will remove all your information from our servers.', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.red[800], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildWarningText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
