import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_bazzar_hub/core/providers.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.user != null) {
        if (mounted) context.go('/home');
      }
      if (next.error != null && next.error != previous?.error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.error!)));
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAutoLogin();
    });
  }

  void _loadSavedEmail() {
    final prefs = ref.read(sharedPreferencesProvider);
    _rememberMe = prefs.getBool('remember_me') ?? false;
    _emailController.text = prefs.getString('remembered_email') ?? '';
  }

  void _saveRememberedEmail() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      prefs.setString('remembered_email', _emailController.text.trim());
    } else {
      prefs.remove('remembered_email');
    }
  }

  Future<void> _attemptAutoLogin() async {
    await ref.read(authViewModelProvider.notifier).tryAutoLogin();
    final authState = ref.read(authViewModelProvider);

    if (!mounted) return;
    if (authState.user != null) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with caching for performance
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
              cacheHeight: 800,
              cacheWidth: 400,
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
                    Colors.black.withValues(alpha: 0.45),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.92),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ).animate().scale(
                    duration: 900.ms,
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.05, 1.05),
                    curve: Curves.easeInOut,
                  ),
                  const SizedBox(height: 18),
                  // Welcome Title
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.6,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Sign in to continue shopping for sustainable essentials.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  // Login Card
                  Card(
                    elevation: 12,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    color: isDark ? Colors.grey[900] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white10
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white10
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        onChanged: (value) => setState(
                                          () => _rememberMe = value ?? false,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/forgot-password'),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Sign In Button
                            ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        _saveRememberedEmail();
                                        ref
                                            .read(
                                              authViewModelProvider.notifier,
                                            )
                                            .login(
                                              _emailController.text.trim(),
                                              _passwordController.text,
                                            );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
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
                            ),
                            const SizedBox(height: 22),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Google Sign In
                            OutlinedButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      _saveRememberedEmail();
                                      ref
                                          .read(authViewModelProvider.notifier)
                                          .signInWithGoogle();
                                    },
                              icon: const Icon(Icons.login),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.grey[50],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 18),
                  // Sign Up Section
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account? '),
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
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Need help? Contact support anytime.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
