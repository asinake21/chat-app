import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Check if dark mode is currently active
  // TODO: Use SharedPreferences here so we can save the user's theme preference locally
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // For now, default to light mode if it's set to system theme
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Switches the theme between dark and light modes and rebuilds the UI
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
