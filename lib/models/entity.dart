class Entity {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String? image;

  Entity({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    this.image,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'],
      title: json['title'],
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
      image: json['image'],
    );
  }
}
