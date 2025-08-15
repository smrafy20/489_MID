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
      // Filter out entities where all attributes (except id) are null/empty
      final List<dynamic> filtered = data.where((item) {
        final m = item as Map<String, dynamic>;
        bool isBlank(dynamic v) {
          if (v == null) return true;
          if (v is String) {
            final s = v.trim().toLowerCase();
            return s.isEmpty || s == 'null' || s == 'nil';
          }
          return false;
        }
        final title = m['title'];
        // Exclude entries considered deleted (blank title), regardless of other fields
        return !isBlank(title);
      }).toList();
      return filtered.map((json) => Entity.fromJson(json)).toList();
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
    if (imagePath != null) {
      var request = http.MultipartRequest('PUT', Uri.parse(_baseUrl));
      request.fields['id'] = id.toString();
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      var response = await request.send();
      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to update entity with image. Status: ${response.statusCode}, Body: $responseBody');
      }
    } else {
      final response = await http.put(
        Uri.parse(_baseUrl),
        body: {
          'id': id.toString(),
          'title': title,
          'lat': lat.toString(),
          'lon': lon.toString(),
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update entity. Status: ${response.statusCode}, Body: ${response.body}');
      }
    }
  }

  Future<void> deleteEntity(int id) async {
    // Soft-delete by POSTing blank fields for the existing id
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: {
        'id': id.toString(),
        'title': '',
        'lat': '',
        'lon': '',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to soft-delete entity. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}