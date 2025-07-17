import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme extends ChangeNotifier {
  bool _isColorfulMode = false;

  AppTheme() {
    _loadTheme();
  }

  bool get isColorfulMode => _isColorfulMode;

  Future<void> toggleColorfulMode() async {
    _isColorfulMode = !_isColorfulMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isColorfulMode', _isColorfulMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isColorfulMode = prefs.getBool('isColorfulMode') ?? false;
    notifyListeners();
  }

  // Colorful color scheme for each feature
  static const Map<String, Color> featureColors = {
    'Random Number': Color(0xFFE91E63), // Pink
    'Team Creator': Color(0xFF2196F3), // Blue
    'Wheel Spinner': Color(0xFF9C27B0), // Purple
    'Timer & Stopwatch': Color(0xFF4CAF50), // Green
    'List Picker': Color(0xFFFF9800), // Orange
    'Dice Roller': Color(0xFF795548), // Brown
    'Coin Toss': Color(0xFFFFC107), // Amber
    'Password Generator': Color(0xFF607D8B), // Blue Grey
    'QR Generator': Color(0xFF00BCD4), // Cyan
    'Rock Paper Scissors': Color(0xFFF44336), // Red
    'Magic 8 Ball': Color(0xFF3F51B5), // Indigo
    'About': Color(0xFF009688), // Teal
  };

  Color getFeatureColor(String featureName) {
    if (!_isColorfulMode) {
      return Colors.grey;
    }
    return featureColors[featureName] ?? Colors.grey;
  }

  ThemeData getLightTheme() {
    if (!_isColorfulMode) {
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      );
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9C27B0),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      brightness: Brightness.light,
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    if (!_isColorfulMode) {
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      );
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9C27B0),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
} 