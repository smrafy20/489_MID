import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entity_provider.dart';
import 'entity_form_screen.dart';
import '../models/entity.dart';

class EntityListScreen extends StatefulWidget {
  const EntityListScreen({super.key});

  @override
  State<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends State<EntityListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entities when the screen is initialized.
    // Using a post-frame callback to ensure context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshEntities();
    });
  }

  Future<void> _refreshEntities() async {
    // We use listen:false here because we're in a method and not in the build method.
    await Provider.of<EntityProvider>(context, listen: false).fetchEntities();
  }

  @override
  Widget build(BuildContext context) {
    final entityProvider = Provider.of<EntityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entity List'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEntities,
        child: entityProvider.isLoading && entityProvider.entities.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: entityProvider.entities.length,
                itemBuilder: (context, index) {
                  final entity = entityProvider.entities[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: entity.image != null && entity.image!.isNotEmpty
                          ? Image.network(
                              'https://labs.anontech.info/cse489/t3/${entity.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            )
                          : const Icon(Icons.image_not_supported),
                    ),
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
                                builder: (context) =>
                                    EntityFormScreen(entity: entity),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // No need to await, provider handles optimistic update
                            entityProvider.deleteEntity(entity.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}