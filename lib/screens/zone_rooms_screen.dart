import 'package:flutter/material.dart';
import 'package:spaklean_frontend/services/api_service.dart';

import 'check_point_screen.dart';
import 'supervisors_screen.dart';

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

  /// 🧩 NEW FUNCTION: Select supervisor before proceeding to CheckpointScreen
  void _selectSupervisorAndProceed(
    String roomId,
    String roomName,
    String officeName,
  ) async {
    try {
      final supervisors = await ApiService.getSupervisorsForManager(
        widget.token,
        widget.userId,
      );

      if (supervisors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No supervisors assigned to you yet.')),
        );
        return;
      }

      String? selectedSupervisorId;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Supervisor'),
            content: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Supervisor'),
              items:
                  supervisors.map<DropdownMenuItem<String>>((s) {
                    return DropdownMenuItem<String>(
                      value: s['id'].toString(),
                      child: Text(s['name']),
                    );
                  }).toList(),
              onChanged: (value) => selectedSupervisorId = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (selectedSupervisorId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CheckpointScreen(
                              roomId: roomId,
                              roomName: roomName,
                              userId: widget.userId.toString(),
                              zoneName: widget.zoneName,
                              officeId: officeName,
                              currentUserId: widget.userId.toString(),
                              doneOnBehalfUserId: selectedSupervisorId!,
                            ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a supervisor'),
                      ),
                    );
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading supervisors: $e')));
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
                                    rooms.map((r) {
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.meeting_room,
                                          color: Colors.teal,
                                        ),
                                        title: Text(r['room_name']),
                                        subtitle: Text(
                                          '${r['category']} → ${r['zone']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // 🧭 Tap to select supervisor and start inspection
                                        // 🚀 When room is tapped → open Supervisors screen
                                        // 🚀 When room is tapped → open Supervisors screen
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => SupervisorsScreen(
                                                    token: widget.token,
                                                    userId: widget.userId,
                                                    roomId:
                                                        r['room_id'].toString(),
                                                    roomName: r['room_name'],
                                                    zoneName: widget.zoneName,
                                                    locationName: locationName,
                                                  ),
                                            ),
                                          );
                                        },
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
