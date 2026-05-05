import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/restaurant.dart';
import '../../home/view_models/tablesession_viewmodel.dart';
import '../view_models/create_table_viewmodel.dart';
import '../view_models/restaurant_list_viewmodel.dart';

class CreateTablePage extends StatefulWidget {
  final Restaurant? initialRestaurant;
  const CreateTablePage({super.key, this.initialRestaurant});

  @override
  State<CreateTablePage> createState() => _CreateTablePageState();
}

class _CreateTablePageState extends State<CreateTablePage> {
  // 1. Declaramos el controlador para el nombre de la mesa
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRestaurant != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CreateTableViewModel>().setRestaurant(widget.initialRestaurant);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. DECLARACIÓN DE VARIABLES (Aquí es donde nacen para que el código de abajo funcione)
    final createVM = context.watch<CreateTableViewModel>();
    final restaurantListVM = context.watch<RestaurantListViewModel>();
    final sessionVM = context.watch<TableSessionViewmodel>();

    // Definimos los "atajos" que usamos en el diseño:
    final Color primaryPurple = Colors.deepPurple; // El color del tema
    final res = createVM.selectedRestaurant;      // El restaurante seleccionado actualmente
    final restaurantVM = restaurantListVM;        // Renombramos para que coincida con el código anterior

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurar Mesa"),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Configura tu Mesa",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // SECCIÓN DEL RESTAURANTE (Bloque que corregimos para evitar el overflow y error rojo)
            const Text("Restaurante Seleccionado:", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: res != null ? primaryPurple.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: res != null ? primaryPurple : Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront, color: res != null ? primaryPurple : Colors.grey),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: widget.initialRestaurant != null 
                      ? Text(
                          res?.name ?? "Cargando...",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<Restaurant>(
                            isExpanded: true,
                            value: res,
                            hint: const Text("Selecciona un restaurante"),
                            items: restaurantVM.restaurants.map((r) {
                              return DropdownMenuItem<Restaurant>(
                                value: r,
                                child: Text(r.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (newRes) {
                              createVM.setRestaurant(newRes);
                            },
                          ),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECCIÓN NOMBRE DE LA MESA
            const Text("Nombre de la mesa (Opcional):", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (val) => createVM.setCustomName(val),
              decoration: InputDecoration(
                hintText: res != null ? "Ej: Cena en ${res.name}" : "Nombre de la mesa",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 40),

            // BOTÓN DE CREAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (res == null || sessionVM.isLoading)
                    ? null 
                    : () async {
                        bool success = await createVM.create(sessionVM);
                        if (success && mounted) {
                          // Volvemos atrás. El Wrapper se encargará de mostrar la mesa activa.
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: sessionVM.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CREAR MESA AHORA",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}