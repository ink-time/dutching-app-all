import 'package:flutter/material.dart';

import '../../../data/model/restaurant.dart';
import '../../home/view_models/tablesession_viewmodel.dart';


class CreateTableViewModel extends ChangeNotifier {
  Restaurant? _selectedRestaurant;
  String _customName = "";

  // Getters
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  String get customName => _customName;

  // El nombre final: si está vacío, usamos el del restaurante
  String get effectiveName {
    if (_customName.trim().isNotEmpty) return _customName.trim();
    if (_selectedRestaurant != null) return "${_selectedRestaurant!.name} Mesa";
    return "";
  }

  void setRestaurant(Restaurant? res) {
    _selectedRestaurant = res;
    notifyListeners();
  }

  void setCustomName(String name) {
    _customName = name;
    notifyListeners();
  }

  // El método que orquestra la creación usando el SessionViewModel global
  Future<bool> create(TableSessionViewmodel sessionVM) async {
    if (_selectedRestaurant == null) return false;

    await sessionVM.createTable(_selectedRestaurant!, effectiveName, "Yo"); // Aquí se debería pasar el userId real del usuario autenticado, pero como no tenemos autenticación aún, usamos un placeholder.
    
    return sessionVM.isInTable;
  }
}