import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entity_provider.dart';
import 'entity_form_screen.dart';
import '../models/entity.dart';

class EntityListScreen extends StatelessWidget {
  const EntityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entityProvider = Provider.of<EntityProvider>(context);
    print('Building EntityListScreen. isLoading: ${entityProvider.isLoading}, entities: ${entityProvider.entities.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entity List'),
      ),
      body: entityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: entityProvider.entities.length,
              itemBuilder: (context, index) {
                final entity = entityProvider.entities[index];
                return ListTile(
                  title: Text(entity.title),
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
                        onPressed: () {
                          entityProvider.deleteEntity(entity.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
