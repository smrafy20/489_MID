// lib/screens/entity_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bangladesh_map_app/constants/app_constants.dart';
import 'package:bangladesh_map_app/providers/entity_provider.dart';
import 'package:bangladesh_map_app/screens/entity_form_screen.dart';
import 'package:bangladesh_map_app/widgets/app_drawer.dart';

class EntityListScreen extends StatefulWidget {
  const EntityListScreen({super.key});

  @override
  State<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends State<EntityListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EntityProvider>(context, listen: false).fetchEntities();
  }

  void _deleteEntity(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(AppConstants.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppConstants.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppConstants.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<EntityProvider>(context, listen: false).deleteEntity(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.navList),
      ),
      drawer: const AppDrawer(),
      body: Consumer<EntityProvider>(
        builder: (context, provider, child) {
          if (provider.status == EntityStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.entities.length,
            itemBuilder: (context, index) {
              final entity = provider.entities[index];
              return ListTile(
                title: Text(entity.title),
                subtitle: Text('Lat: ${entity.lat}, Lon: ${entity.lon}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntityFormScreen(entity: entity),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEntity(entity.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}