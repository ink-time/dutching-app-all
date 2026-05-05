
// // Supongamos que este es tu Widget de la pantalla de la Mesa
// @override
// Widget build(BuildContext context) {
//   // El ID del usuario actual (esto vendría de tu Auth o un Provider)
//   final String miUid = "uid_juan"; 

//   return StreamBuilder<DocumentSnapshot>(
//     stream: _firestoreService.streamMesa(widget.mesaId),
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) return CircularProgressIndicator();

//       // 1. Obtenemos todos los items de la mesa
//       var datos = snapshot.data!.data() as Map<String, dynamic>;
//       List<dynamic> todosLosItems = datos['items'] ?? [];

//       // 2. FILTRADO: Mi Carrito Individual
//       // Filtramos items donde mi UID esté en la lista de 'pagadoPor'
//       final misItems = todosLosItems.where((item) {
//         List<dynamic> pagadores = item['pagadoPor'] ?? [];
//         return pagadores.contains(miUid);
//       }).toList();

//       // 3. CÁLCULO DE TOTALES
//       double miTotal = misItems.fold(0, (sum, item) {
//         // Si el plato es compartido, dividimos el precio entre los que pagan
//         int numParticipantes = item['pagadoPor'].length;
//         return sum + (item['precioTotal'] / numParticipantes);
//       });

//       double totalGrupal = todosLosItems.fold(0, (sum, item) => sum + item['precioTotal']);

//       return Column(
//         children: [
//           // SECCIÓN GRUPAL
//           ListTile(
//             title: Text("Total del Grupo"),
//             trailing: Text("${totalGrupal.toStringAsFixed(2)}€", 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           Divider(),