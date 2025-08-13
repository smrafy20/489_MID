import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/entity_provider.dart';
import 'entity_list_screen.dart';
import 'entity_form_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entities when the screen is initialized
    Provider.of<EntityProvider>(context, listen: false).fetchEntities();
  }

  @override
  Widget build(BuildContext context) {
    final entityProvider = Provider.of<EntityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Map'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Entity List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EntityListScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Add Entity'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EntityFormScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: entityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
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
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(entity.title),
                              content: entity.image != null
                                  ? CachedNetworkImage(
                                      imageUrl: 'https://labs.anontech.info/cse489/t3/${entity.image}',
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                  : const Text('No image available'),
                            ),
                          );
                        },
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
