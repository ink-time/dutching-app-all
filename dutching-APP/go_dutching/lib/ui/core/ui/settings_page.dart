import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/theme_provider.dart';
// Importa tu ThemeProvider

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Modo Oscuro"),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              // Llama al método para cambiar el tema
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          // ... otros ajustes
        ],
      ),
    );
  }
}