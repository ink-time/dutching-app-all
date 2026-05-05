import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_dutching/data/services/firestore_service.dart';

import '../../../data/model/restaurant.dart';


class TableSessionViewmodel extends ChangeNotifier {
    final FirestoreService _firestore = FirestoreService();

    
    String? _tableId;
    bool _isInTable = false;
    bool _isLoading = false;
    String? _errorMessage;

    // GETTERS for the UI files:
    String? get tableId => _tableId;
    List<String> get participants => []; // This will be implemented later, when we have the user authentication and we can save the userIds in the table document in Firestore.
    bool get isInTable => _isInTable;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;

    //METHODS:
    Future<void> createTable(Restaurant restaurant, String tableName, String userId) async {
      _setLoading(true);
      try {
      
      String newCode = _generateTableCode(6); //Code generation
      await _firestore.createNewTable(newCode, restaurant.id.toString(), restaurant.name, tableName, userId); //save it in the database
      _tableId = newCode;
      _isInTable = true;
      _errorMessage = null;
      } catch (e) {
        _errorMessage = "Error creating the Table: $e";
      } finally {
        _setLoading(false);
      }

    }
    
    Future<bool> joinTable(String code) async {
      _setLoading(true);
      _errorMessage = null;
      try {
      String upperCode = code.toUpperCase().trim();
      bool exists = await _firestore.existsTable(upperCode);
      if(exists) {
        _tableId = upperCode;
        _isInTable = true;
        return true;
      } else {
        _errorMessage = "The specified table code doesn't exist. Check if it is correctly typed!";
        return false;
      }
      } catch (e) {
        _errorMessage = "Error joining the Table: $e";
        return false;
      } finally {
        _setLoading(false);
      }
    }

    void leaveTable() {
      _tableId = null;
      _isInTable = false;
      notifyListeners();
    }

    // Helper to notify loading changes
    void _setLoading(bool loadingState) {
      _isLoading = loadingState;
      notifyListeners();
    }

  // This is outside the generateTableCode method so if a lot of Random seeds are generated, 
  // there will not be 2 equal generated strings. 
  //(This can happen if the method is called multiple times in a row, like in a loop)
  static const _chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'; // No 0 or O to avoid confusions
      final Random _rand = Random();
    // The generation method that will be accessed.
    String _generateTableCode(int length) {
      return String.fromCharCodes
      (Iterable.generate(length, (_) => _chars.codeUnitAt(_rand.nextInt(_chars.length))));
    }

    
      // String generateRandomString(int length) => String.fromCharCodes
      // (Iterable.generate(length, (_) => _chars.codeUnitAt(_rand.nextInt(_chars.length))));
    }