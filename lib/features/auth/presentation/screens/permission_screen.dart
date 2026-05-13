import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eco_bazzar_hub/core/providers.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool _isLoading = false;
  bool _showThemeSelection = false;

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    await [
      Permission.contacts,
      Permission.location,
      Permission.storage,
      Permission.photos,
    ].request();

    setState(() {
      _isLoading = false;
      _showThemeSelection = true;
    });
  }

  void _selectTheme(ThemeMode mode) {
    ref.read(themeModeProvider.notifier).state = mode;
    // Mark as not first time after setup is done
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(
      'is_first_time',
      true,
    ); // Keep it true until onboarding is done
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=2013&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  const Color(0xFF1B4332).withOpacity(0.9),
                  Colors.black,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: AnimatedSwitcher(
                duration: 500.ms,
                child: _showThemeSelection
                    ? _buildThemeSelection()
                    : _buildPermissionRequest(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Column(
      key: const ValueKey('permission'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.privacy_tip_rounded,
            size: 80,
            color: Color(0xFF52B788),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 48),
        const Text(
          'Permissions',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Text(
          'Allow EcoBazzar Hub to access essential services for a seamless experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 48),
        _PermissionRow(
          icon: Icons.contacts_rounded,
          title: 'Contacts',
          delay: 600.ms,
        ),
        _PermissionRow(
          icon: Icons.location_on_rounded,
          title: 'Location',
          delay: 700.ms,
        ),
        _PermissionRow(
          icon: Icons.folder_rounded,
          title: 'Storage & Photos',
          delay: 800.ms,
        ),
        const SizedBox(height: 64),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _requestPermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Allow Permissions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ).animate().fadeIn(delay: 1.seconds).scale(),
      ],
    );
  }

  Widget _buildThemeSelection() {
    return Column(
      key: const ValueKey('theme'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Personalize Your Theme',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        Text(
          'Choose the mode that best fits your style.',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
        const SizedBox(height: 60),
        Row(
          children: [
            Expanded(
              child: _ThemeCard(
                mode: ThemeMode.light,
                title: 'Light Mode',
                icon: Icons.light_mode_rounded,
                onTap: () => _selectTheme(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _ThemeCard(
                mode: ThemeMode.dark,
                title: 'Dark Mode',
                icon: Icons.dark_mode_rounded,
                onTap: () => _selectTheme(ThemeMode.dark),
              ),
            ),
          ],
        ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms).fadeIn(),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Duration delay;

  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF52B788), size: 28),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white24,
            size: 20,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.1, end: 0);
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeMode mode;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFF52B788)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
