// services/theme_service.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// Service for managing app theme
class ThemeService {
  // Singleton pattern
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() => _instance;

  ThemeService._internal();

  // Theme mode state - starts with system default
  ThemeMode _currentThemeMode = ThemeMode.system;

  // Stream controller for broadcasting theme changes
  final _themeStreamController = StreamController<ThemeMode>.broadcast();

  // Stream of theme mode for listening to changes
  Stream<ThemeMode> get themeStream => _themeStreamController.stream;

  // Get current theme mode
  ThemeMode get currentThemeMode => _currentThemeMode;

  // Method to toggle between light and dark modes
  void toggleTheme() {
    switch (_currentThemeMode) {
      case ThemeMode.system:
      case ThemeMode.light:
        _currentThemeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _currentThemeMode = ThemeMode.light;
        break;
    }
    _notifyListeners();
  }

  // Set specific theme mode
  void setThemeMode(ThemeMode themeMode) {
    if (_currentThemeMode != themeMode) {
      _currentThemeMode = themeMode;
      _notifyListeners();
    }
  }

  // Notify listeners of changes
  void _notifyListeners() {
    if (!_themeStreamController.isClosed) {
      _themeStreamController.add(_currentThemeMode);
    }
  }

  // Dispose resources
  void dispose() {
    _themeStreamController.close();
  }
}
