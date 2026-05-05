import 'package:flutter/material.dart';
import 'package:go_dutching/ui/home/widgets/home_screen.dart';
import 'package:provider/provider.dart';

import '../../home/view_models/tablesession_viewmodel.dart';
import '../../home/widgets/home_screen.dart';
// import 'settings_page.dart'; // La crearemos luego
import 'settings_page.dart';
import 'table_wrapper_page.dart'; // El "cerebro" de la pestaña Mesa

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Las 3 pantallas de nuestro menú
  final List<Widget> _pages = [
    const HomeScreen(),
    const TableWrapperPage(), // Esta decidirá qué mostrar
    const SettingsPage(), // Settings temporal
  ];

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel solo para ver si ponemos un "puntito rojo" de notificación en el icono de la mesa
    final isInTable = context.watch<TableSessionViewmodel>().isInTable;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 91, 21, 176),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Restaurantes"),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.table_restaurant),
                if (isInTable) // Un indicador visual si ya está en una mesa
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    ),
                  ),
              ],
            ),
            label: "Mi Mesa",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
        ],
      ),
    );
  }
}
