import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Por defecto empezamos en el tema del sistema o claro
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Esto es lo que avisa al main para que cambie el color
  }
}