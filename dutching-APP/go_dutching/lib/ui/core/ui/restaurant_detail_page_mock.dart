// import 'package:flutter/material.dart';
// import '../../../data/model/menu.dart';
// import '../../../data/model/menu_item.dart';
// import '../../../data/model/restaurant.dart';

// class RestaurantDetailMockPage extends StatelessWidget {
//   final String restaurantId;
//   const RestaurantDetailMockPage({super.key, required this.restaurantId});
  
//   @override
//   Widget build(BuildContext context) {
//     // DATOS MOCK HARDCODEADOS
    
//     final Restaurant mockRestaurant = 
//     Restaurant(
//       id: restaurantId,
//       name: "La Pizzería del Nonno",
//       location: "Calle Falsa 123, Madrid",
//       imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=400",
//       currentMenu: Menu(id: "m1", items: [
//         MenuItem(id: "p1", name: "Margarita", description: "Tomate, mozzarella y albahaca", type: "Pizza", unitPrice: 10.50),
//         MenuItem(id: "p2", name: "Cuatro Quesos", description: "Gorgonzola, parmesano, mozzarella y emmental", type: "Pizza", unitPrice: 13.00),
//       ]),
//     );

//     return Scaffold(
//       appBar: AppBar(title: Text(mockRestaurant.name)),
//       body: Column(
//         children: [
//           Image.network(mockRestaurant.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(mockRestaurant.location!, style: const TextStyle(color: Colors.grey)),
//                 const SizedBox(height: 20),
//                 const Text("MENÚ MOCK", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 const Divider(),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: mockRestaurant.currentMenu!.items.length,
//               itemBuilder: (context, index) {
//                 final item = mockRestaurant.currentMenu!.items[index];
//                 return ListTile(
//                   title: Text(item.name),
//                   trailing: Text("${item.unitPrice}€"),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }