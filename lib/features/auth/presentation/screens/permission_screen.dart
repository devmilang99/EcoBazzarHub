import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    // Requesting Location and Storage (Note: Storage permissions handle differently on Android 13+)
    await [
      Permission.location,
      Permission.storage,
      Permission.photos,
    ].request();

    debugPrint('Permissions requested');

    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_outlined,
                size: 100,
                color: Colors.green,
              ).animate().scale(duration: 600.ms),
              const SizedBox(height: 32),
              Text(
                'Help us serve you better',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Text(
                'EcoBazzar Hub needs access to your location and storage to provide nearby deals and save your invoices.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: _isLoading ? null : _requestPermissions,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Allow Permissions'),
              ).animate().slideY(begin: 0.5, end: 0, delay: 600.ms).fadeIn(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Maybe later'),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
