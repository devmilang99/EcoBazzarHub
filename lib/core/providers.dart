import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/database/app_database.dart';
import '../core/router/app_router.dart';

final dioProvider = Provider((ref) => DioClient().dio);

/// Provider for the Drift database instance
final databaseProvider = Provider((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Reactive ThemeMode provider synced with Drift database
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _init();
    return ThemeMode.system;
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    final val = await db.getSetting('theme_mode');
    if (val != null) {
      state = ThemeMode.values[int.parse(val)];
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await ref.read(databaseProvider).saveSetting('theme_mode', mode.index.toString());
  }
}

/// Reactive IsFirstTime provider synced with Drift database
final isFirstTimeProvider = NotifierProvider<IsFirstTimeNotifier, bool>(IsFirstTimeNotifier.new);

class IsFirstTimeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _init();
    return true; // Default to true for new users
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    final val = await db.getSetting('is_first_time');
    if (val != null) {
      state = val == 'true';
    }
  }

  Future<void> setFirstTime(bool value) async {
    state = value;
    await ref.read(databaseProvider).saveSetting('is_first_time', value.toString());
  }
}

final routerProvider = Provider((ref) => appRouter);
