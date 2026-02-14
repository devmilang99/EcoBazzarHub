import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/splash_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/permission_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/register_screen.dart';
import 'package:eco_bazzar_hub/features/home/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
  ],
);
