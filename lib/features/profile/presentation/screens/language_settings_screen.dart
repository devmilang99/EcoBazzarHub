import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English (US)';

  final List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'code': 'en_US', 'flag': '🇺🇸'},
    {'name': 'Nepali', 'code': 'ne_NP', 'flag': '🇳🇵'},
    {'name': 'Hindi', 'code': 'hi_IN', 'flag': '🇮🇳'},
    {'name': 'Spanish', 'code': 'es_ES', 'flag': '🇪🇸'},
    {'name': 'French', 'code': 'fr_FR', 'flag': '🇫🇷'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('Language', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguage == lang['name'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: Colors.green[700]!, width: 2) : null,
            ),
            child: ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(lang['name']!, style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              trailing: isSelected ? Icon(Icons.check_circle_rounded, color: Colors.green[700]) : null,
              onTap: () => setState(() => _selectedLanguage = lang['name']!),
            ),
          ).animate().fadeIn(delay: (index * 50).ms).slideX();
        },
      ),
    );
  }
}
