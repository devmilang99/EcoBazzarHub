import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            Text('Live Support', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('Online', style: GoogleFonts.outfit(fontSize: 10, color: Colors.green)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMessage(
                  text: 'Hello! How can we help you today?',
                  isMe: false,
                  time: '10:00 AM',
                  isDark: isDark,
                ),
                _buildMessage(
                  text: 'I have an issue with my recent order.',
                  isMe: true,
                  time: '10:01 AM',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          _buildChatInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessage({required String text, required bool isMe, required String time, required bool isDark}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[700] : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: GoogleFonts.outfit(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87))),
            const SizedBox(height: 4),
            Text(time, style: GoogleFonts.outfit(fontSize: 10, color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey)),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildChatInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_rounded, color: Colors.green[700]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
