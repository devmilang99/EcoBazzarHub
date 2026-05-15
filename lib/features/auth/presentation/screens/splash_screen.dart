import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eco_bazzar_hub/core/providers.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  void _startFlow() async {
    // 1. Initial delay for splash effect
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 2. Check if first time for initial flow
    final isFirstTime = await ref.read(databaseProvider).getSetting('is_first_time') != 'false';

    if (!mounted) return;
    if (isFirstTime) {
      context.go('/permissions');
      return;
    }

    await ref.read(authViewModelProvider.notifier).tryAutoLogin();
    final authState = ref.read(authViewModelProvider);
    if (!mounted) return;
    if (authState.user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Modern Background Image for Splash
          Image.network(
            'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=1974&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  const Color(0xFF2D6A4F).withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: Color(0xFF2D6A4F),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: 1.seconds,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.1, 1.1),
                      curve: Curves.easeInOut,
                    )
                    .shimmer(delay: 1.seconds, duration: 2.seconds),
                const SizedBox(height: 24),
                const Text(
                      'EcoBazzar Hub',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
