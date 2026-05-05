// table_wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/view_models/tablesession_viewmodel.dart';
import '../ui/active_table_page.dart';
import '../ui/table_lobby_page.dart';



class TableWrapperPage extends StatelessWidget {
  const TableWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TableSessionViewmodel>(
      builder: (context, sessionVM, child) {
        // Si ya estamos en una mesa, saltamos a la pantalla de la mesa activa
        if (sessionVM.isInTable) {
          // return const Center(child: Text("Pantalla de Mesa Activa (En construcción)"));
          return const ActiveTablePage(); 
        }
        
        // Si no, mostramos el lobby para unirse o crear
        return const TableLobbyPage();
      },
    );
  }
}