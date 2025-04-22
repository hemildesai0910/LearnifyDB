import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoaded = false;
  
  ThemeMode get themeMode {
    // Return light theme if not loaded yet to avoid null errors
    if (!_isLoaded) {
      return ThemeMode.light;
    }
    return _themeMode;
  }
  
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      // Fallback to light theme in case of error
      _themeMode = ThemeMode.light;
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    } catch (e) {
      // Silent error handling
      print('Error saving theme: $e');
    }
  }
} 