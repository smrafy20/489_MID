// lib/models/entity.dart

class Entity {
  final int? id;
  final String title;
  final double lat;
  final double lon;
  final String? imagePath;

  Entity({
    this.id,
    required this.title,
    required this.lat,
    required this.lon,
    this.imagePath,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'],
      title: json['title'],
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      imagePath: json['image'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
    };
  }
}