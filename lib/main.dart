// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bangladesh_map_app/providers/entity_provider.dart';
import 'package:bangladesh_map_app/screens/map_screen.dart';
import 'package:bangladesh_map_app/screens/entity_list_screen.dart';
import 'package:bangladesh_map_app/screens/entity_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EntityProvider(),
      child: MaterialApp(
        title: 'Bangladesh Map App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/map', // Start with the map screen
        routes: {
          '/map': (context) => const MapScreen(),
          '/list': (context) => const EntityListScreen(),
          '/form': (context) => const EntityFormScreen(),
        },
      ),
    );
  }
}