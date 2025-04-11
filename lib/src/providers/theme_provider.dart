import 'package:flutter/material.dart';
import '../models/user_data.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  UserTheme? _customTheme;

  ThemeMode get themeMode => _themeMode;
  UserTheme? get customTheme => _customTheme;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Return the system theme
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark || (_customTheme != null && _customTheme!.isDark);
  }

  // Mettre à jour le mode de thème (clair/sombre/système)
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Appliquer un thème personnalisé
  void setCustomTheme(UserTheme? theme) {
    _customTheme = theme;
    if (theme != null) {
      _themeMode = theme.isDark ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }

  // Obtenir le thème actuel en fonction des préférences
  ThemeData getTheme(bool isDark) {
    if (_customTheme != null) {
      final primaryColor = Color(_customTheme!.primaryColorValue);
      final secondaryColor = Color(_customTheme!.secondaryColorValue);

      final brightness = _customTheme!.isDark ? Brightness.dark : Brightness.light;

      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          brightness: brightness,
        ),
      );
    }

    // Thème par défaut
    return isDark
        ? ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
    )
        : ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
  }
}