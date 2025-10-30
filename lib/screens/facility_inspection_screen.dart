import 'package:flutter/material.dart';

import 'zone_rooms_screen.dart'; // ✅ navigate to the screen showing rooms per zone

class FacilityInspectionScreen extends StatelessWidget {
  final String token;
  final int userId;

  const FacilityInspectionScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  // ✅ Define zone data
  final List<Map<String, dynamic>> zones = const [
    {
      "name": "Low Traffic Areas (Yellow Zone)",
      "color": "yellow",
      "icon": Icons.directions_walk,
    },
    {
      "name": "Heavy Traffic Areas (Orange Zone)",
      "color": "orange",
      "icon": Icons.directions_run,
    },
    {
      "name": "Food Service Areas (Green Zone)",
      "color": "green",
      "icon": Icons.restaurant,
    },
    {
      "name": "High Microbial Areas (Red Zone)",
      "color": "red",
      "icon": Icons.warning_rounded,
    },
    {
      "name": "Outdoors & Exteriors (Black Zone)",
      "color": "black",
      "icon": Icons.landscape,
    },
    {"name": "Inspection Reports", "color": "grey", "icon": Icons.receipt_long},
  ];

  // ✅ Helper to convert string color → Color
  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'black':
        return Colors.black;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Inspection'),
        backgroundColor: Colors.teal,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.all(16),
        children:
            zones.map((zone) {
              final zoneColor = _getColorFromString(zone['color']!);
              return _buildZoneCard(
                context,
                zone['name']!,
                zoneColor,
                zone['icon']!,
              );
            }).toList(),
      ),
    );
  }

  // ✅ Build each zone card
  Widget _buildZoneCard(
    BuildContext context,
    String name,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        // Extract just the zone label (e.g. "Yellow Zone")
        final zoneLabel = name.split('(').last.replaceAll(')', '');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ZoneRoomsScreen(
                  token: token,
                  userId: userId,
                  zoneName: zoneLabel, // ✅ correct parameter name
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Colors.white),
            const SizedBox(height: 8.0),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
