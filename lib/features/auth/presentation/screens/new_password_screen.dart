import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Set New Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 12),
                const Text(
                  'Create a strong password to protect your account.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Please enter a password';
                    if (val.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (val) {
                    if (val != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showSuccessDialog();
                    }
                  },
                  child: const Text('Reset Password'),
                ).animate().fadeIn(delay: 700.ms).scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 80,
            ).animate().scale(duration: 500.ms, curve: Curves.bounceOut),
            const SizedBox(height: 24),
            const Text(
              'Password Changed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your password has been successfully reset. You can now login with your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
