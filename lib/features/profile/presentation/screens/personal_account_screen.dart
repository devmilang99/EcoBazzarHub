import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:eco_bazzar_hub/features/profile/presentation/screens/edit_profile_screen.dart';

class PersonalAccountScreen extends ConsumerWidget {
  const PersonalAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authViewModelProvider).user;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Personal Account',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(context, user, isDark),
          const SizedBox(height: 32),
          _buildSectionHeader('Profile Settings'),
          _buildActionTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile Information',
            subtitle: 'Change name, phone, and profile photo',
            onTap: () {
              if (user?.isGoogleUser == false) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Managed by Google')),
                );
              }
            },
            isDark: isDark,
          ),
          _buildActionTile(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            subtitle: 'Add or remove delivery addresses',
            onTap: () {},
            isDark: isDark,
          ),
          _buildActionTile(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your cards and digital wallets',
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Security'),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your login credentials',
            onTap: () {},
            isDark: isDark,
          ),
          _buildActionTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Login',
            subtitle: 'Manage FaceID/Fingerprint access',
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Account Actions'),
          _buildActionTile(
            icon: Icons.no_accounts_outlined,
            title: 'Deactivate Account',
            subtitle: 'Temporarily disable your profile',
            onTap: () {},
            isDark: isDark,
          ),
          _buildActionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently remove your data',
            color: Colors.red,
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[800]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
              user?.photoUrl ??
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=2080&auto=format&fit=crop',
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
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
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? Colors.green).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? Colors.green[700], size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: color ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
