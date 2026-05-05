import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/restaurant.dart';
import '../../../data/services/api/restaurant_api_service.dart';


class RestaurantListViewModel extends ChangeNotifier {
  final RestaurantApiService _apiService = RestaurantApiService();

  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carga inicial de la lista
  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurants = await _apiService.getRestaurants();
    } catch (e) {
      _errorMessage = "No se pudieron cargar los restaurantes.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}