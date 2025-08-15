import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/entity_provider.dart';
import '../models/entity.dart';

import 'full_screen_image_viewer.dart';

import 'entity_list_screen.dart';
import 'entity_form_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen> {
  // Base URL for images returned by the API (e.g., "images/image2.jpg" -> full URL)
  static const String _imageBase = 'https://labs.anontech.info/cse489/t3/';

  // Currently selected marker's entity (to show the bottom info card)
  Entity? _selected;

  // Safely build a full image URL from a possibly relative API path
  String? _fullImageUrl(String? path) {
    if (path == null) return null;
    final p = path.trim();
    if (p.isEmpty) return null;
    // Avoid double slashes if API returns a path starting with '/'
    final cleaned = p.startsWith('/') ? p.substring(1) : p;
    return '$_imageBase$cleaned';
  }

  void _onMarkerTap(Entity entity) {
    setState(() => _selected = entity);
  }

  void _showImageDialog(Entity entity) {
    final url = _fullImageUrl(entity.image);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image available')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(title: entity.title, imageUrl: url),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch entities when the screen is initialized
    Provider.of<EntityProvider>(context, listen: false).fetchEntities();
  }

  @override
  Widget build(BuildContext context) {
    final entityProvider = Provider.of<EntityProvider>(context);

    Widget map = FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(23.6850, 90.3563),
        initialZoom: 7.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: entityProvider.entities.map((entity) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(entity.lat, entity.lon),
              child: GestureDetector(
                onTap: () => _onMarkerTap(entity),
                child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
              ),
            );
          }).toList(),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Map of Bangladesh')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu'),
            ),
            ListTile(title: const Text('Map'), onTap: () => Navigator.pop(context)),
            ListTile(
              title: const Text('Entity List'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EntityListScreen()),
              ),
            ),
            ListTile(
              title: const Text('Add Entity'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EntityFormScreen()),
              ),
            ),
          ],
        ),
      ),
      body: entityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                map,
                if (_selected != null)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FractionallySizedBox(
                          widthFactor: 0.85,
                          alignment: Alignment.bottomLeft,
                          child: _BottomInfoCard(
                            title: _selected!.title,
                            lat: _selected!.lat,
                            lon: _selected!.lon,
                            imageUrl: _fullImageUrl(_selected!.image),
                            onTapDetails: () => _showImageDialog(_selected!),
                            onDismiss: () => setState(() => _selected = null),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _BottomInfoCard extends StatelessWidget {
  final String title;
  final double lat;
  final double lon;
  final String? imageUrl;
  final VoidCallback onTapDetails;
  final VoidCallback onDismiss;

  const _BottomInfoCard({
    required this.title,
    required this.lat,
    required this.lon,
    required this.imageUrl,
    required this.onTapDetails,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTapDetails,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => const SizedBox(
                          width: 56,
                          height: 56,
                          child: Center(child: Icon(Icons.error)),
                        ),
                      )
                    : const SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(child: Icon(Icons.image_not_supported)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text('Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onTapDetails,
                    child: Text(
                      'See more',
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: onDismiss, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }
}



