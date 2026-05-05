import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_dutching/ui/core/ui/main_screen.dart';
import 'package:go_dutching/ui/home/widgets/home_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
// Internal Imports:
import 'package:firebase_database/firebase_database.dart';
import 'ui/core/view_models/active_table_viewmodel.dart';
import 'ui/core/view_models/create_table_viewmodel.dart';
import 'ui/core/view_models/restaurant_detail_viewmodel.dart';
import 'ui/core/view_models/restaurant_list_viewmodel.dart';
import 'ui/home/view_models/tablesession_viewmodel.dart';
import 'ui/home/view_models/restaurant_viewmodel.dart';
import 'utils/theme_provider.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantViewmodel()),
        // Firebase session for the Table
        ChangeNotifierProvider(create: (_) => TableSessionViewmodel()),
        // Restaurant list
        ChangeNotifierProvider(create: (_) => RestaurantListViewModel()..fetchRestaurants()),
        // Restaurants details:
        ChangeNotifierProvider(create: (_) => RestaurantDetailViewModel()),
        // Creation Logic for the tables
        ChangeNotifierProvider(create: (_) => CreateTableViewModel()),
        // Active table logic
        ChangeNotifierProvider(create: (_) => ActiveTableViewModel()),
      ],
      child: const DutchingApp(),
    ),
  );
}

class DutchingApp extends StatelessWidget {
  const DutchingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí es donde sucede la magia: escuchamos al ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Dutching',
      
      // TEMA CLARO
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 155, 112, 229), // Usando el púrpura que vimos antes
        brightness: Brightness.light,
      ),

      // TEMA OSCURO
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromARGB(255, 98, 46, 188),
      ),

      // EL INTERRUPTOR: 
      // Le dice a Flutter qué tema usar basándose en tu Provider
      themeMode: themeProvider.themeMode, 
      
      home: const MainScreen(),
    );
  }
}