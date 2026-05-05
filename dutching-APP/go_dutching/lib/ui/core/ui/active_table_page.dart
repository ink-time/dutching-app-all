import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/model/menu_item.dart';
import '../../home/view_models/tablesession_viewmodel.dart';
import '../view_models/active_table_viewmodel.dart';

class ActiveTablePage extends StatefulWidget {
  const ActiveTablePage({super.key});

  @override
  State<ActiveTablePage> createState() => _ActiveTablePageState();
}

class _ActiveTablePageState extends State<ActiveTablePage> {
  bool _isCartOpen = false; // Controla si el carrito está visible

  static const Map<String, String> _typeTranslations = {
    'starter': 'Starters',
    'main': 'Main Courses',
    'dessert': 'Desserts',
    'drink': 'Drinks',
  };

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<TableSessionViewmodel>();
    final activeVM = context.watch<ActiveTableViewModel>();
    // Colores del tema
    final Color primaryPurple = Colors.deepPurple;
    final String tableId = sessionVM.tableId ?? "";
    final String myUid = "Yo"; //Id od the user using Auth

    if (tableId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Error: Table ID not found")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isCartOpen ? "My Cart" : "Restaurant Menu",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => sessionVM.leaveTable(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: activeVM.getTableStream(tableId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("The table does not exist."));
          }

          final data = snapshot.data!.data()!;
          // final List<dynamic> participantesReales = data['participants'] ?? [];
          final List<dynamic> participantesReales = [
            "Yo",
            "Samantha",
            "Adri",
            "Yoryo",
            "Javi",
            "Evan",
            "Mishel",
            "Barak",
          ]; // Simulación de participantes reales. Reemplaza con data['participants'] cuando lo tengas listo
          final String restaurantId =
              data['restaurantId'] ??
              ""; // El ID que necesitamos para Spring Boot
          final List<dynamic> itemsEnMesa = data['items'] ?? [];
          final String restaurantName = data['restaurantName'] ?? "Restaurant";

          // Usamos microtask para que se ejecute JUSTO después de que termine este 'build'
          if (activeVM.menuItems.isEmpty && !activeVM.loadingMenu) {
            Future.microtask(() => activeVM.fetchMenu(restaurantId));
          }
          // Usamos un Stack para poner el carrito por encima del menú
          return Stack(
            children: [
              // CAPA FONDO: El Menú para añadir platos
              _buildRestaurantMenu(
                activeVM,
                primaryPurple,
                participantesReales,
                tableId,
              ),

              // CAPA OSCURA: Se ve solo si el carrito está abierto
              if (_isCartOpen)
                GestureDetector(
                  onTap: () => setState(() => _isCartOpen = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),

              // CAPA SUPERIOR: El Carrito Deslizante
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
                // Si está cerrado, lo escondemos debajo de la pantalla (MediaQuery...height)
                top: _isCartOpen ? 0 : MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  // Aquí metemos tu vista de platos de la mesa que ya tenías
                  child: _buildCartView(
                    itemsEnMesa,
                    restaurantName,
                    data['tableName'] ?? "Table",
                    myUid,
                    primaryPurple,
                    activeVM,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // EL BOTÓN FLOTANTE: Abre y cierra el carrito
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isCartOpen = !_isCartOpen),
        backgroundColor: const Color.fromARGB(255, 140, 98, 255),
        child: Icon(
          _isCartOpen ? Icons.close : Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }

  // --- MÉTODOS DE LA UI ---

  // 1. LA CARTA DEL RESTAURANTE (Fondo)
  Widget _buildRestaurantMenu(
    ActiveTableViewModel activeVM,
    Color color,
    List<dynamic> participantesReales,
    String tableId,
  ) {
    if (activeVM.loadingMenu) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeVM.menuItems.isEmpty) {
      return const Center(
        child: Text("No products available for the selected restaurant."),
      );
    }

    // 1. AGRUPACIÓN (Igual que en RestaurantDetailPage)
    Map<String, List<MenuItem>> groupedMenu = {};
    for (var item in activeVM.menuItems) {
      String type = item.mainType?.toLowerCase() ?? 'otros';
      if (!groupedMenu.containsKey(type)) {
        groupedMenu[type] = [];
      }
      groupedMenu[type]!.add(item);
    }

    // 2. CONSTRUCCIÓN DE LA LISTA DE WIDGETS
    List<Widget> menuWidgets = [];

    groupedMenu.forEach((type, items) {
      // Añadimos el Título de la Categoría
      String sectionTitle = _typeTranslations[type] ?? type.toUpperCase();

      menuWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ),
      );

      // Añadimos los platos de esa categoría
      for (var producto in items) {
        menuWidgets.add(
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.fastfood,
                color: Color.fromARGB(255, 216, 84, 178),
              ),
              title: Text(
                producto.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${producto.unitPrice.toStringAsFixed(2)}€"),
              trailing: IconButton(
                icon: Icon(Icons.add_circle, color: color, size: 32),
                onPressed: () {
                  _showAddDishBottomSheet(
                    context,
                    producto,
                    color,
                    participantesReales,
                    activeVM,
                    tableId,
                  );
                },
              ),
            ),
          ),
        );
      }
    });

    // Espacio final para que el FAB no tape el último item
    menuWidgets.add(const SizedBox(height: 100));

    return ListView(
      padding: const EdgeInsets.only(top: 10),
      children: menuWidgets,
    );
  }

  // 2. EL CARRITO (Tu vista original)
  Widget _buildCartView(
    List<dynamic> items,
    String resName,
    String tableName,
    String myUid,
    Color color,
    ActiveTableViewModel activeVM,
  ) {
    final double miTotal = activeVM.calculateMyTotal(items, myUid);
    final double totalMesa = activeVM.calculateGroupTotal(items);

    return Column(
      children: [
        _buildHeader(resName, tableName, color),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _buildDishCard(items[index], myUid, color),
                ),
        ),
        _buildPaymentSummary(miTotal, totalMesa, color),
      ],
    );
  }

  // User selector to share dish
  void _showAddDishBottomSheet(
    BuildContext context,
    MenuItem producto,
    Color color,
    List<dynamic> participantesReales,
    ActiveTableViewModel activeVM,
    String tableId,
  ) {
    // Por ahora simulamos los participantes. Más adelante vendrán del Stream.
    // final List<String> participantesSimulados = ["Yo", "Ana", "Carlos", "Luis"];
    final List<String> compartiendoCon = ["Yo"]; // Por defecto, lo pido yo solo

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder permite redibujar SOLO este panel cuando tocas un contacto
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add ${producto.name}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${producto.unitPrice.toStringAsFixed(2)}€",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Who is it for?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // EL SELECTOR HORIZONTAL (Estilo contactos)
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: participantesReales.length,
                      itemBuilder: (context, index) {
                        final nombre = participantesReales[index];
                        final bool isSelected = compartiendoCon.contains(
                          nombre,
                        );

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              // 1. Definimos quién es el principal (por ahora "Yo")
                              const String principal = "Yo";

                              if (isSelected) {
                                // 2. SOLO permitimos deseleccionar si NO es el principal
                                if (nombre != principal) {
                                  compartiendoCon.remove(nombre);
                                }
                              } else {
                                // 3. Si no estaba seleccionado, lo añadimos
                                compartiendoCon.add(nombre);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    AnimatedContainer(
                                      // Usamos AnimatedContainer para un efecto visual suave
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: isSelected
                                            ? color
                                            : Colors.grey.shade300,
                                        child: Icon(
                                          Icons.person,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nombre,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected ? color : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // 1. Preparamos los datos del plato tal y como los espera Firestore
                      final Map<String, dynamic> itemData = {
                        'name': producto.name,
                        'price': producto.unitPrice,
                        'paidBy': compartiendoCon
                            .toList(), // La lista de la gente que lo comparte
                        'addedAt':
                            Timestamp.now(), // Buena práctica: guardar cuándo se pidió
                      };
                      Navigator.pop(
                        context,
                      ); // Cierra el panel muy rápido para mejor experiencia de usuario
                      await activeVM.addItem(tableId, itemData);
                      //Sólo se muestra el el contexto sigue montado para evitar errores si el usuario se va de la página antes de que termine la operación
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${producto.name} added to the cart!",
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(String restaurant, String tableName, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text(
            restaurant,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tableName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(dynamic item, String myUid, Color color) {
    bool yoParticipo = (item['paidBy'] as List).contains(myUid);
    int totalParticipantes = (item['paidBy'] as List).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.restaurant_menu, color: color),
        ),
        title: Text(
          item['name'] ?? "Dish",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Shared by $totalParticipantes people"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${item['price'].toStringAsFixed(2)}€",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (yoParticipo)
              Text(
                "Your share: ${(item['price'] / totalParticipantes).toStringAsFixed(2)}€",
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(double miTotal, double totalMesa, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Table Total",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                "${totalMesa.toStringAsFixed(2)}€",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MY TOTAL",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "${miTotal.toStringAsFixed(2)}€",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              /* Navegar a la carta para añadir más */
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "ADD DISH TO CART",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "There are no dishes on the cart yet.\nGo to the menu and add something delicious!",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
