import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.user != null) {
        context.go('/home');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Modern Background Image for Login
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // Logo or Title
                    Column(
                      children: [
                        Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.eco_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scale(
                              duration: 1.seconds,
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.1, 1.1),
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(height: 16),
                        Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Form Fields
                    TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 16),
                    TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 12),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) => setState(
                                  () => _rememberMe = value ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 32),

                    // Login Button
                    ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ).animate().fadeIn(delay: 700.ms).scale(),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 24),

                    // Social Login
                    ElevatedButton(
                          onPressed: () => ref
                              .read(authViewModelProvider.notifier)
                              .signInWithGoogle(),
                          child: const Text('Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 900.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 48),
                    // Register Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Create One',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1000.ms),

                    // Help & Contact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline, size: 16),
                          label: const Text(
                            'Help',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.headset_mic_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Contact Us',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1100.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
