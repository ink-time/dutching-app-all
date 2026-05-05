import 'package:flutter/material.dart';
import 'package:go_dutching/ui/home/view_models/tablesession_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../home/view_models/tablesession_viewmodel.dart';
import 'table_lobby_page.dart';
import 'active_table_page.dart'; // Esto está pendiente de crear, pero la idea es que sea la pantalla principal de la mesa, donde se muestra el menú, los carritos, los participantes tal vez? Aunque son menos importantes menos cuando se selecciona un plato para compartir, etc.

class TableWrapperPage extends StatelessWidget {
  const TableWrapperPage({super.key});

  @override
  Widget build(BuildContext context){
    return Consumer<TableSessionViewmodel>(
      builder: (context, sessionVM, child) {
        // If the user already is part of a table:
        if (sessionVM.isInTable) {
          return const ActiveTablePage();
          // Actually return ActiveTablePage();
        }
        // If the user is not in a table we show the screen where he can create or join one
        return const TableLobbyPage();
      },
    );
  }
}