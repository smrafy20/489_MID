import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entity.dart';

class ApiService {
  static const String _baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  Future<List<Entity>> getEntities() async {
    final response = await http.get(Uri.parse(_baseUrl));
    print('Raw API Response: ${response.body}');
    if (response.statusCode == 200) {
      String responseBody = response.body;
      if (responseBody.trim().isEmpty) {
        return [];
      }
      if (!responseBody.startsWith('[')) {
        responseBody = '[$responseBody]';
      }
      responseBody = responseBody.replaceAll('}{', '},');
      print('Manipulated JSON: $responseBody');
      final List<dynamic> data = json.decode(responseBody);
      return data.map((json) => Entity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load entities');
    }
  }

  Future<void> createEntity(String title, double lat, double lon, String? imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.fields['title'] = title;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to create entity');
    }
  }

  Future<void> updateEntity(int id, String title, double lat, double lon, String? imagePath) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl?id=$id'));
    request.fields['title'] = title;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to update entity');
    }
  }

  Future<void> deleteEntity(int id) async {
    final response = await http.delete(
      Uri.parse(_baseUrl),
      body: json.encode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete entity');
    }
  }
}