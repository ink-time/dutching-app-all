import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/restaurant.dart';
import '../../../data/model/menu_item.dart'; 
import '../../home/view_models/tablesession_viewmodel.dart';
import '../view_models/restaurant_detail_viewmodel.dart';
import 'create_table_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  // Paleta de colores Morada
  final Color primaryPurple = Colors.deepPurple;
  final Color accentPurple = Colors.deepPurpleAccent;

  // Diccionario para traducir los tipos de tu base de datos a títulos bonitos
  final Map<String, String> _typeTranslations = {
    'starter': 'Entrantes',
    'main': 'Platos Principales',
    'dessert': 'Postres',
    'drink': 'Bebidas',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantDetailViewModel>().loadRestaurant(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantVM = context.watch<RestaurantDetailViewModel>();
    final res = restaurantVM.restaurant;
    final bool isButtonDisabled = restaurantVM.isLoading || res == null;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btn_crear_mesa",
        onPressed: isButtonDisabled
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTablePage(initialRestaurant: res)),
                ),
        label: Text(
          restaurantVM.isLoading ? "LOADING..." : "CREATE TABLE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isButtonDisabled ? Colors.white70 : Colors.white,
          ),
        ),
        icon: restaurantVM.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
            : const Icon(Icons.group_add, color: Colors.white),
        backgroundColor: isButtonDisabled ? Colors.grey.shade600 : primaryPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildBody(restaurantVM),
    );
  }

  Widget _buildBody(RestaurantDetailViewModel vm) {
    if (vm.isLoading) return Center(child: CircularProgressIndicator(color: primaryPurple));
    if (vm.errorMessage != null) return Center(child: Text(vm.errorMessage!));
    if (vm.restaurant == null) return const Center(child: Text("Cargando datos..."));

    final res = vm.restaurant!;

    // 1. AGRUPACIÓN LÓGICA DE LOS PLATOS
    Map<String, List<MenuItem>> groupedMenu = {};
    if (res.menu != null) {
      for (var item in res.menu!.menuItems) {
        String type = item.mainType?.toLowerCase() ?? 'otros';
        if (!groupedMenu.containsKey(type)) {
          groupedMenu[type] = [];
        }
        groupedMenu[type]!.add(item);
      }
    }

    // 2. CONSTRUCCIÓN DINÁMICA DE LA VISTA
    List<Widget> slivers = [
      // Cabecera con imagen
      SliverAppBar(
        expandedHeight: 220,
        pinned: true,
        backgroundColor: primaryPurple, // Color de la barra al hacer scroll
        automaticallyImplyLeading: false, // Nueva Flecha personalizada
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: primaryPurple.withValues(alpha: 0.7), // Círculo morado
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          title: Text(res.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          background: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(res.imageUrl ?? '', fit: BoxFit.cover),
              // Un pequeño degradado para que el texto blanco siempre se lea bien
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Info del restaurante
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: primaryPurple, size: 18),
                  const SizedBox(width: 5),
                  Expanded(child: Text(res.location ?? '', style: const TextStyle(color: Colors.grey))),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ];

    // Iteramos sobre las categorías agrupadas para crear las secciones
    groupedMenu.forEach((type, items) {
      // Traducimos el tipo (ej: 'starter' -> 'Entrantes')
      String sectionTitle = _typeTranslations[type] ?? type.toUpperCase();

      // Añadimos el Título de la Sección
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Text(
              sectionTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryPurple),
            ),
          ),
        ),
      );

      // Añadimos los platos de esta sección
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2, // Sombra suave
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (item.description != null && item.description!.isNotEmpty)
                          Text(item.description!, style: const TextStyle(fontSize: 13)),
                        
                        // Si hay secondaryType (Ej: "Vegano", "Sin gluten"), lo mostramos como un "chip" visual
                        if (item.secondaryType != null && item.secondaryType!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.secondaryType!,
                              style: TextStyle(fontSize: 11, color: primaryPurple, fontWeight: FontWeight.w600),
                            ),
                          )
                        ]
                      ],
                    ),
                    trailing: Text(
                      "${item.unitPrice.toStringAsFixed(2)}€",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentPurple),
                    ),
                  ),
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      );
    });

    // Si el menú estaba vacío, mostramos un mensaje
    if (groupedMenu.isEmpty) {
      slivers.add(const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text("El menú de este restaurante aún no está disponible.")),
        ),
      ));
    }

    // Un espacio final para que el botón flotante no tape el último plato
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 80)));

    return CustomScrollView(slivers: slivers);
  }
}