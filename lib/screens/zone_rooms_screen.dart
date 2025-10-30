import 'package:flutter/material.dart';
import 'package:spaklean_frontend/services/api_service.dart';

class ZoneRoomsScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String zoneName;

  const ZoneRoomsScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.zoneName,
  });

  @override
  State<ZoneRoomsScreen> createState() => _ZoneRoomsScreenState();
}

class _ZoneRoomsScreenState extends State<ZoneRoomsScreen> {
  bool loading = true;
  Map<String, dynamic> groupedRooms = {};

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final data = await ApiService.getRoomsByZoneGrouped(
        widget.token,
        widget.userId,
        widget.zoneName,
      );
      setState(() {
        groupedRooms = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching rooms: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zoneName),
        backgroundColor: Colors.teal,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : groupedRooms.isEmpty
              ? const Center(child: Text('No rooms found for this zone.'))
              : ListView(
                children:
                    groupedRooms.entries.map((locationEntry) {
                      final locationName = locationEntry.key;
                      final sectors =
                          locationEntry.value as Map<String, dynamic>;

                      return ExpansionTile(
                        title: Text(
                          locationName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        children:
                            sectors.entries.map((sectorEntry) {
                              final sectorName = sectorEntry.key;
                              final rooms = sectorEntry.value as List<dynamic>;

                              return ExpansionTile(
                                title: Text(
                                  sectorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                children:
                                    rooms.map((room) {
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.meeting_room,
                                          color: Colors.teal,
                                        ),
                                        title: Text(room['room_name']),
                                        subtitle: Text(
                                          '${room['category']} → ${room['zone']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
    );
  }
}
