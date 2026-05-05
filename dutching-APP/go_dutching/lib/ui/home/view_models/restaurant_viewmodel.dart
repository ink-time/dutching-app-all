import 'package:flutter/material.dart';
import '../../../data/model/menu.dart';
import '../../../data/model/menu_item.dart';
import '../../../data/services/api/restaurant_api_service.dart';
import '../../../data/model/restaurant.dart';

class RestaurantViewmodel extends ChangeNotifier{
  final RestaurantApiService _api = RestaurantApiService();

  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;

  List<Restaurant> get restaurants => _filteredRestaurants;
  bool get isLoading => _isLoading;

  // Carga de datos real desde la API
  Future<void> fetchRestaurants() async {
    _setLoading(true);

    try {
      // Llamada real al backend de Spring Boot
      _allRestaurants = await _api.getRestaurants();
      _filteredRestaurants = _allRestaurants; 
      
      print("¡Éxito! Cargados ${_allRestaurants.length} restaurantes.");
    } catch (e) {
      print("Error al cargar restaurantes desde el Viewmodel: $e");
    } finally {
      _setLoading(false);
    }
  }

  // El buscador sigue funcionando igual, pero con datos reales
  void restaurantFilter(String query) {
    if (query.isEmpty) {
      _filteredRestaurants = _allRestaurants;
    } else {
      _filteredRestaurants = _allRestaurants
          .where((res) => res.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Helper para notificar cambios de carga
  void _setLoading(bool loadingState) {
    _isLoading = loadingState;
    notifyListeners();
  }
}