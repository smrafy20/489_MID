// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io'; //bug fix for dio
import 'package:bangladesh_map_app/constants/app_constants.dart';
import 'package:bangladesh_map_app/models/entity.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Entity>> getEntities() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Entity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load entities');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<bool> createEntity(Entity entity, File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'title': entity.title,
        'lat': entity.lat,
        'lon': entity.lon,
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(ApiConstants.baseUrl, data: formData);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to create entity');
    }
  }

  Future<bool> updateEntity(Entity entity, File? imageFile) async {
    try {
      Map<String, dynamic> dataMap = entity.toUpdateJson();
      if (imageFile != null) {
        dataMap['image'] = await MultipartFile.fromFile(imageFile.path);
      }
      FormData formData = FormData.fromMap(dataMap);

      final response = await _dio.post(
        ApiConstants.baseUrl,
        data: formData,
        options: Options(
          headers: {'X-HTTP-Method-Override': 'PUT'}, 
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update entity');
    }
  }

  Future<bool> deleteEntity(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}?id=$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete entity');
    }
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    return '${ApiConstants.imageBaseUrl}$imagePath';
  }
}