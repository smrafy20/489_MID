// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:bangladesh_map_app/constants/app_constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text(AppConstants.navMap),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/map');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text(AppConstants.navList),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/list');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_location_alt),
            title: const Text(AppConstants.navForm),
            onTap: () {
              Navigator.pushNamed(context, '/form');
            },
          ),
        ],
      ),
    );
  }
}