import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_dutching/data/services/api/restaurant_api_service.dart';
import '../../../data/model/menu_item.dart';
import '../../../data/model/restaurant.dart';
import '../../../data/services/firestore_service.dart';

class ActiveTableViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Errores para mostrar en la UI si algo falla
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  Restaurant? _restaurant;

  Restaurant? get restaurant => _restaurant;
  List<MenuItem> _menuItems = [];
  List<MenuItem> get menuItems => _menuItems;
  bool _loadingMenu = false;
  bool get loadingMenu => _loadingMenu;

  Future<void> fetchMenu(String restaurantId) async {
    if (_menuItems.isNotEmpty || _loadingMenu) return;

    _loadingMenu = true;
    notifyListeners();

    try {
      // Usamos una variable local para evitar problemas de = a null
      final fetchedRestaurant = await RestaurantApiService().getRestaurantById(
        restaurantId
      );
      _restaurant = fetchedRestaurant;
      
      _menuItems = fetchedRestaurant.menu?.menuItems?? [];
    } catch (e) {
      _errorMessage = "Error loading the menu: $e";
      print(_errorMessage);
    } finally {
      _loadingMenu = false;
      notifyListeners();
    }
  }

  /// Obtiene el flujo de datos de la mesa en tiempo real
  Stream<DocumentSnapshot<Map<String, dynamic>>> getTableStream(
    String tableId,
  ) {
    return _firestoreService.getTableStream(tableId);
  }

  /// Calcula el total que debe pagar el usuario actual
  /// [items] es la lista de platos en la mesa
  /// [myUserId] es el ID del usuario que está usando la app
  double calculateMyTotal(List<dynamic> items, String myUserId) {
    double myTotal = 0.0;

    for (var item in items) {
      List<dynamic> payers = item['paidBy'] ?? [];
      if (payers.contains(myUserId)) {
        double price = (item['price'] ?? 0).toDouble();
        int participants = payers.length;

        // Si hay participantes, dividimos el precio
        if (participants > 0) {
          myTotal += price / participants;
        }
      }
    }
    return myTotal;
  }

  /// Calcula el total acumulado de toda la mesa
  double calculateGroupTotal(List<dynamic> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + (item['price'] ?? 0).toDouble(),
    );
  }

  // We add a menuItem to the table
  Future<void> addItem(String tableId, Map<String, dynamic> itemData) async {
    try {
      await _firestoreService.addItemToTable(tableId, itemData);
      // No hace falta notifyListeners aquí porque el StreamBuilder
      // de la UI detectará el cambio en Firestore automáticamente.
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
