import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/model/restaurant.dart';
import '../../../data/services/api/restaurant_api_service.dart';

class RestaurantDetailViewModel extends ChangeNotifier {
  // Instancia de tu servicio que hace las peticiones HTTP (Dio)
  final RestaurantApiService _apiService = RestaurantApiService();

  // --- ESTADO INTERNO ---
  Restaurant? _restaurant;
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS (Para que la UI los lea) ---
  Restaurant? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- MÉTODOS ---

  /// Carga el detalle completo del restaurante (incluyendo el Menú)
  Future<void> loadRestaurant(String id) async {
    print("Cargando restaurante con ID: $id");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Se muestra una animación de carga en la UI.

    try {
      // Llamada a la api con DIO. Esto obtendrá un restaurante completo.
      _restaurant = await _apiService.getRestaurantById(id);
    } catch (e) {
      print("DEBUG ERROR: $e");
      _errorMessage = "Error al conectar con el servidor";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia los datos (Útil si quieres resetear el estado al salir de la pantalla)
  void clear() {
    _restaurant = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
