// table_lobby_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/view_models/tablesession_viewmodel.dart';
import 'create_table_page.dart';

class TableLobbyPage extends StatefulWidget {
  const TableLobbyPage({super.key});

  @override
  State<TableLobbyPage> createState() => _TableLobbyPageState();
}

class _TableLobbyPageState extends State<TableLobbyPage> {
  final TextEditingController _codeController = TextEditingController();
  final Color primaryPurple = Colors.deepPurple.shade900; // Morado oscuro

  void _joinTable() async {
    final code = _codeController.text.toUpperCase().trim();
    if (code.isEmpty) return;

    final sessionVM = context.read<TableSessionViewmodel>();
    bool success = await sessionVM.joinTable(code);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sessionVM.errorMessage ?? 'Código no válido'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TableSessionViewmodel>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mesa Virtual", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          children: [
            // Icono central con estilo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_add_rounded, size: 80, color: primaryPurple),
            ),
            const SizedBox(height: 30),
            Text(
              "¿Tus amigos ya tienen mesa?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryPurple),
            ),
            const SizedBox(height: 12),
            const Text(
              "Introduce el código de 6 caracteres para unirte a la sesión y empezar a compartir.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Campo de Código
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: TextStyle(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.bold, color: primaryPurple),
              decoration: InputDecoration(
                hintText: "CÓDIGO",
                hintStyle: TextStyle(letterSpacing: 0, color: Colors.grey.shade400, fontSize: 18),
                filled: true,
                fillColor: Colors.grey.shade100,
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            // Botón UNIRSE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _joinTable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UNIRME A LA MESA", 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Divisor con "O"
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("O CREA UNA NUEVA", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Botón CREAR
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CreateTablePage())
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("CREAR MESA DESDE CERO"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                foregroundColor: primaryPurple,
                side: BorderSide(color: primaryPurple, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}