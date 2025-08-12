// lib/providers/entity_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bangladesh_map_app/models/entity.dart';
import 'package:bangladesh_map_app/services/api_service.dart';

enum EntityStatus { initial, loading, success, error }

class EntityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Entity> _entities = [];
  List<Entity> get entities => _entities;
  
  EntityStatus _status = EntityStatus.initial;
  EntityStatus get status => _status;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  Future<void> fetchEntities() async {
    _status = EntityStatus.loading;
    notifyListeners();
    try {
      _entities = await _apiService.getEntities();
      _status = EntityStatus.success;
    } catch (e) {
      _status = EntityStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createEntity(Entity entity, File imageFile) async {
    try {
      bool success = await _apiService.createEntity(entity, imageFile);
      if (success) {
        fetchEntities(); // Refresh the list after creating
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updateEntity(Entity entity, File? imageFile) async {
    try {
      bool success = await _apiService.updateEntity(entity, imageFile);
      if (success) {
        fetchEntities(); // Refresh the list after updating
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> deleteEntity(int id) async {
    try {
      bool success = await _apiService.deleteEntity(id);
      if (success) {
        _entities.removeWhere((entity) => entity.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  String getFullImageUrl(String? imagePath) {
    return _apiService.getFullImageUrl(imagePath);
  }
}