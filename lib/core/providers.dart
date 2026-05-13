import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_client.dart';
import '../core/database/app_database.dart';
import '../core/router/app_router.dart';

final dioProvider = Provider((ref) => DioClient().dio);

final databaseProvider = Provider((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final themeIndex =
      prefs.getInt('theme_mode') ?? 0; // 0: system, 1: light, 2: dark
  return ThemeMode.values[themeIndex];
});

final isFirstTimeProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('is_first_time') ?? true;
});

final routerProvider = Provider((ref) => appRouter);
