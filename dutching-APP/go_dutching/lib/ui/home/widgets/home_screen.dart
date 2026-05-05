import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_dutching/ui/home/view_models/restaurant_viewmodel.dart';

import '../../core/ui/restaurant_card.dart';

// const String buttonKey = 'button';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override 
  void initState() {
    super.initState();
    // We load the data when starting the app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantViewmodel>(context, listen:false).fetchRestaurants();
    });
  }
  @override
Widget build(BuildContext context) {
  final viewModel = Provider.of<RestaurantViewmodel>(context);

  return Scaffold(
      appBar: AppBar(
        title: Text("¿Dónde comemos hoy?"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => viewModel.restaurantFilter(value),
              decoration: InputDecoration(
                hintText: "Buscar restaurante...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: viewModel.isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: viewModel.restaurants.length,
            itemBuilder: (context, index) {
              final res = viewModel.restaurants[index];
              return RestaurantCard(restaurant: res); // Tu componente visual
            },
          ),
    );
  
}

}