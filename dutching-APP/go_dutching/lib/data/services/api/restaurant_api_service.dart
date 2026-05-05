import 'package:dio/dio.dart';
import '../../model/restaurant.dart';

class RestaurantApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    )); // Change url!!

  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await _dio.get('restaurants');

      if(response.statusCode == 200){
        List<dynamic> data = response.data; // Json comming from Postgre
        return data.map((json) => Restaurant.fromJson(json)).toList(); // Transformation fron json to Restaurant object list
        } else {
          return [];
        }
       
    } on DioException catch (e){
      // If the server is not up, or not working this exception will be catched
      print('Server error ocurred: ${e.type} - ${e.message}');
      return []; // We return an empty array of info
    }  
    }

  Future<Restaurant> getRestaurantById(String id) async {
    try {
      final response = await _dio.get('restaurants/$id');
      if(response.statusCode == 200) {
        return Restaurant.fromJson(response.data);
      } else {
        throw Exception("Error getting the restaurant data");
      }
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }
}