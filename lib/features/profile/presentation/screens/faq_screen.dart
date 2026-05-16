import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I track my order?',
      'a': 'You can track your order by going to the "Orders" section in your profile and selecting the specific order.'
    },
    {
      'q': 'What is the return policy?',
      'a': 'We offer a 7-day return policy for most items. The item must be in its original condition and packaging.'
    },
    {
      'q': 'How can I pay for my order?',
      'a': 'We support various payment methods including Credit/Debit cards, Digital Wallets (ESewa, Khalti), and Cash on Delivery.'
    },
    {
      'q': 'Is my data secure?',
      'a': 'Yes, we use industry-standard encryption to protect your data and transactions.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('FAQ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(faq['q']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                Text(faq['a']!, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX();
        },
      ),
    );
  }
}
