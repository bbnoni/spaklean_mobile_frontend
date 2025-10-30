import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ManagerLocationScreen extends StatefulWidget {
  final String token;
  final int userId;

  const ManagerLocationScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<ManagerLocationScreen> createState() => _ManagerLocationScreenState();
}

class _ManagerLocationScreenState extends State<ManagerLocationScreen> {
  bool _loading = true;
  List<dynamic> _locations = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedLocations();
  }

  // ✅ This is the updated version (with debugging added)
  Future<void> _fetchAssignedLocations() async {
    try {
      final response = await ApiService.getAssignedLocations(
        widget.token,
        widget.userId,
      );

      print('✅ Response from backend: $response'); // Debug log

      setState(() {
        _locations = response;
        _loading = false;
      });
    } catch (e) {
      print('❌ Error fetching locations: $e'); // Debug log
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load locations: $e')));
    }
  }

  void _openLocationDetail(Map<String, dynamic> location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailScreen(location: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _locations.isEmpty
              ? const Center(child: Text("No locations assigned"))
              : ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final loc = _locations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        loc['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _openLocationDetail(loc),
                    ),
                  );
                },
              ),
    );
  }
}

class LocationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final sectors = location['sectors'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(location['name']),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: sectors.length,
        itemBuilder: (context, index) {
          final sector = sectors[index];
          return ExpansionTile(
            title: Text(sector['name']),
            children:
                (sector['categories'] ?? []).map<Widget>((cat) {
                  return ExpansionTile(
                    title: Text('• ${cat['name']}'),
                    children:
                        (cat['rooms'] ?? []).map<Widget>((room) {
                          return ListTile(
                            title: Text('Room: ${room['name']}'),
                            leading: const Icon(Icons.meeting_room_outlined),
                          );
                        }).toList(),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
