import 'package:go_router/go_router.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/splash_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/permission_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/register_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/theme_selection_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/otp_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/new_password_screen.dart';
import 'package:eco_bazzar_hub/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:eco_bazzar_hub/features/dashboard/presentation/screens/dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => OtpScreen(email: state.extra as String),
    ),
    GoRoute(
      path: '/new-password',
      builder: (context, state) => const NewPasswordScreen(),
    ),
    GoRoute(
      path: '/theme-selection',
      builder: (context, state) => const ThemeSelectionScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
  ],
);
