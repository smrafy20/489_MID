// lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:bangladesh_map_app/constants/app_constants.dart';
import 'package:bangladesh_map_app/providers/entity_provider.dart';
import 'package:bangladesh_map_app/widgets/app_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entities when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EntityProvider>(context, listen: false).fetchEntities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entityProvider = Provider.of<EntityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.navMap),
      ),
      drawer: const AppDrawer(),
      body: entityProvider.status == EntityStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(
                  MapConstants.bangladeshLatitude,
                  MapConstants.bangladeshLongitude,
                ),
                initialZoom: MapConstants.defaultZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.bangladesh_map_app',
                  tileProvider: NetworkTileProvider(abortObsoleteRequests: true),
                ),
                MarkerLayer(
                  markers: entityProvider.entities.map((entity) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(entity.lat, entity.lon),
                      child: GestureDetector(
                        onTap: () {
                          // Show a dialog with entity details [cite: 121]
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(entity.title),
                              content: entity.imagePath != null
                                  ? CachedNetworkImage(
                                      imageUrl: entityProvider.getFullImageUrl(entity.imagePath),
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                  : const Text('No image available'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                )
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}