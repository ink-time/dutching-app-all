import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TABLE:
  /// To listen to the changes in real time
  /// This way we update the app when someone adds something to their cart
  /// If I used a FUture, the app would have to ask the database if there have been changes every X amount of time
  /// But using Stream the idea is that as soon as there is a change in the database, firestore pushes the changes to the app.
  /// Making the data update faster and more efficiently.
  Stream<DocumentSnapshot> streamTable(String tableId) {
    return _db.collection('table').doc(tableId).snapshots();
  }

  // With this we add a product to the table, since if a product is added to a user cart
  //it should be added to the table inmediatly. Doing it inside a singular function works better then.
  // We will also be able to filter if a product is shaed or not with the 'isShared' property/column.
  //And then we check the array in 'payedBy'.
  Future<void> addProductToTable({
    required String tableId,
    required String name,
    required double price,
    required List<String> uidsUsers,
  }) async {
    final newProduct = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'unitPrice': price,
      'payedBy': uidsUsers,
      'isShared': uidsUsers.length > 1,
    };
    await _db.collection('table').doc(tableId).update({
      'items': FieldValue.arrayUnion([newProduct]),
      // We use FieldValue.arrayUnion so if two users add a plate exactly at the same time, one doesn't overrite the other
    });
  }
  /// We check if a table exists or not with its code
  Future<bool> existsTable(String code) async {
    try {
      // We normalize the code in case a user decides to type it instead of copying and pasting, and does so in lowercase.
      final table = await _db.collection('tables').doc(code.toUpperCase()).get();
      return table.exists;
    } catch (e) {
      print('Error while verifying if the table exists: $e');
      return false;
    }
  }

  /// We create a table
  // ANd when creating the table, we add the first participant
  Future<void> createNewTable(String code, String restaurantId, String restaurantName, String tableName, String userId) async {
  await _db.collection('tables').doc(code).set({
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'tableName': tableName,
    'participants': [userId], // We initialize the list with the table creator
    'items': [],
    'createdAt': FieldValue.serverTimestamp(),
  });
}
  Stream<DocumentSnapshot<Map<String, dynamic>>> getTableStream(String tableId) {
  return _db.collection('tables').doc(tableId).snapshots();
}

// We add a menuItem to a table, or cart
Future<void> addItemToTable(String tableId, Map<String, dynamic> itemData) async {
  await _db.collection('tables').doc(tableId).update({
    'items': FieldValue.arrayUnion([itemData])
  });
}

// WHen a user joins a table, they become a participant as well
Future<void> joinTable(String code, String userId) async {
  await _db.collection('tables').doc(code).update({
    'participants': FieldValue.arrayUnion([userId])
  });
}
}
