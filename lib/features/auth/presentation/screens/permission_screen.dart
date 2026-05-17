import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionInfo {
  final String title;
  final String description;
  final IconData icon;
  final String imageUrl;
  final Permission permission;
  final List<Permission>? android13Permissions;

  PermissionInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.imageUrl,
    required this.permission,
    this.android13Permissions,
  });
}

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<PermissionInfo> _permissions = [
    PermissionInfo(
      title: 'Location Access',
      description:
          'We need your location to find the nearest delivery hubs and provide accurate shipping estimates.',
      icon: Icons.location_on_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2066&auto=format&fit=crop',
      permission: Permission.location,
    ),
    PermissionInfo(
      title: 'Storage & Photos',
      description:
          'Access to storage allows you to upload profile pictures and save invoices directly to your device.',
      icon: Icons.image_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1616077168079-7e09a677fb2c?q=80&w=2070&auto=format&fit=crop',
      permission: Permission.storage,
      android13Permissions: [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ],
    ),
    PermissionInfo(
      title: 'Contact List',
      description:
          'Syncing contacts helps you find friends on EcoBazzar and easily share vouchers with them.',
      icon: Icons.contacts_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?q=80&w=2070&auto=format&fit=crop',
      permission: Permission.contacts,
    ),
    PermissionInfo(
      title: 'Notifications',
      description:
          'Get real-time updates on your order status, exclusive flash deals, and eco-tips.',
      icon: Icons.notifications_active_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1512428559083-a4979b2b51ff?q=80&w=2070&auto=format&fit=crop',
      permission: Permission.notification,
    ),
  ];

  Future<void> _requestPermission(PermissionInfo info) async {
    setState(() => _isLoading = true);

    // Logic for Android 13+ storage
    if (info.permission == Permission.storage && Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // Use granular permissions for Android 13+
        if (info.android13Permissions != null) {
          await info.android13Permissions!.request();
        } else {
          await info.permission.request();
        }
      } else {
        // Use standard storage permission for Android 12 and below
        await info.permission.request();
      }
    } else {
      await info.permission.request();
    }

    setState(() => _isLoading = false);
    _nextPage();
  }

  void _nextPage() {
    if (_currentPage < _permissions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildPermissionSlider(),
    );
  }

  Widget _buildPermissionSlider() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemCount: _permissions.length,
          itemBuilder: (context, index) {
            final info = _permissions[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  info.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 48),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.black);
                  },
                ).animate().scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: 10.seconds,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.9),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF52B788,
                            ).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFF52B788,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            info.icon,
                            color: const Color(0xFF52B788),
                            size: 32,
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 24),
                        Text(
                              info.title,
                              style: GoogleFonts.outfit(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 16),
                        Text(
                              info.description,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 32),
                        Row(
                          children: List.generate(
                            _permissions.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF52B788)
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                        const SizedBox(height: 32),
                        SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => _requestPermission(info),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D6A4F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Allow Access',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: _isLoading ? null : _nextPage,
                child: Text(
                  'Skip',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 1.seconds),
      ],
    );
  }
}
