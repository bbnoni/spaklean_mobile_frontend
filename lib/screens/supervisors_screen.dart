import 'package:flutter/material.dart';
import 'package:spaklean_frontend/screens/check_point_screen.dart';
import 'package:spaklean_frontend/services/api_service.dart';

class SupervisorsScreen extends StatefulWidget {
  final String token;
  final int userId;
  final String? roomId;
  final String? roomName;
  final String? zoneName;
  final String? locationName;

  const SupervisorsScreen({
    super.key,
    required this.token,
    required this.userId,
    this.roomId,
    this.roomName,
    this.zoneName,
    this.locationName,
  });

  @override
  State<SupervisorsScreen> createState() => _SupervisorsScreenState();
}

class _SupervisorsScreenState extends State<SupervisorsScreen> {
  bool loading = true;
  List<dynamic> supervisors = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchSupervisors();
  }

  Future<void> _fetchSupervisors() async {
    try {
      final data = await ApiService.getSupervisorsForManager(
        widget.token,
        widget.userId,
      );
      setState(() {
        supervisors = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching supervisors: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSupervisors =
        supervisors.where((s) {
          final name = s['name']?.toLowerCase() ?? '';
          final email = s['email']?.toLowerCase() ?? '';
          return name.contains(searchQuery.toLowerCase()) ||
              email.contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Supervisors${widget.locationName != null ? ' - ${widget.locationName}' : ''}',
        ),
        backgroundColor: Colors.teal,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // 🔍 Search bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search supervisor...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (val) => setState(() => searchQuery = val),
                    ),
                  ),

                  // 👥 List of supervisors
                  Expanded(
                    child:
                        filteredSupervisors.isEmpty
                            ? const Center(
                              child: Text(
                                'No supervisors found.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                            : ListView.builder(
                              itemCount: filteredSupervisors.length,
                              itemBuilder: (context, index) {
                                final s = filteredSupervisors[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  elevation: 3,
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.teal,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      s['name'] ?? 'Unnamed',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(s['email'] ?? ''),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (widget.roomId == null ||
                                            widget.roomName == null ||
                                            widget.zoneName == null ||
                                            widget.locationName == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Room details are missing — open this from Zone Rooms screen to inspect.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CheckpointScreen(
                                                  roomId: widget.roomId!,
                                                  roomName: widget.roomName!,
                                                  userId:
                                                      widget.userId.toString(),
                                                  zoneName: widget.zoneName!,
                                                  officeId:
                                                      widget.locationName!,
                                                  currentUserId:
                                                      widget.userId.toString(),
                                                  doneOnBehalfUserId:
                                                      s['id'].toString(),
                                                ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Inspect",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
