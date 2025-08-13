import 'package:flutter/material.dart';
import '../models/entity.dart';
import '../services/api_service.dart';

class EntityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Entity> _entities = [];
  bool _isLoading = false;

  List<Entity> get entities => _entities;
  bool get isLoading => _isLoading;

  Future<void> fetchEntities() async {
    print('1. Setting isLoading to true and notifying listeners.');
    _isLoading = true;
    notifyListeners();
    try {
      print('2. Fetching entities from ApiService.');
      _entities = await _apiService.getEntities();
      print('3. Fetched ${_entities.length} entities.');
    } catch (e) {
      print('4. Error fetching entities: $e');
    }
    print('5. Setting isLoading to false and notifying listeners.');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createEntity(String title, double lat, double lon, String? imagePath) async {
    try {
      await _apiService.createEntity(title, lat, lon, imagePath);
      fetchEntities(); // Refresh the list
    } catch (e) {
      print('Error creating entity: $e');
    }
  }

  Future<void> updateEntity(int id, String title, double lat, double lon, String? imagePath) async {
    try {
      await _apiService.updateEntity(id, title, lat, lon, imagePath);
      fetchEntities(); // Refresh the list
    } catch (e) {
      print('Error updating entity: $e');
    }
  }

  Future<void> deleteEntity(int id) async {
    try {
      await _apiService.deleteEntity(id);
      _entities.removeWhere((entity) => entity.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting entity: $e');
    }
  }
}
