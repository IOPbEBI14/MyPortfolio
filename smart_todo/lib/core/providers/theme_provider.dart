import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Провайдер для управления темой
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeBoxName = 'theme_settings';
  static const String _themeModeKey = 'theme_mode';
  
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  // Загружаем сохраненную тему
  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final savedTheme = box.get(_themeModeKey, defaultValue: 'system');
      
      switch (savedTheme) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    } catch (e) {
      print('Error loading theme: $e');
      state = ThemeMode.system;
    }
  }

  // Переключаем тему
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newTheme);
  }

  // Устанавливаем конкретную тему
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    
    try {
      final box = await Hive.openBox(_themeBoxName);
      String themeString;
      
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await box.put(_themeModeKey, themeString);
      print('✅ Theme saved: $themeString');
    } catch (e) {
      print('❌ Error saving theme: $e');
    }
  }

  // Проверяем, темная ли тема
  bool isDark(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}
