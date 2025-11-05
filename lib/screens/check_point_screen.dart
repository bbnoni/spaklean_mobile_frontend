import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class CheckpointScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String userId;
  final String zoneName;
  final String officeId;
  final String currentUserId;
  final String? doneOnBehalfUserId;

  const CheckpointScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.userId,
    required this.zoneName,
    required this.officeId,
    required this.currentUserId,
    required this.doneOnBehalfUserId,
  });

  @override
  State<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends State<CheckpointScreen> {
  Map<String, Set<String>> selections = {};
  bool _isSubmitting = false;
  double? latitude;
  double? longitude;
  String? locationName;
  DateTime? _submissionTime;

  final Map<String, List<String>> defectOptions = {
    'CEILING': ['Cobweb', 'Dust', 'Mold', 'Stains', 'None', 'N/A'],
    'WALLS': ['Cobweb', 'Dust', 'Marks', 'Mold', 'Stains', 'None', 'N/A'],
    'Common Touch Points (CTP)': ['Dust', 'Marks', 'None', 'N/A'],
    'WINDOWS': [
      'Cobweb',
      'Droppings',
      'Dust',
      'Fingerprints',
      'Water stains',
      'Mud',
      'Stains',
      'None',
      'N/A',
    ],
    'EQUIPMENT': ['Dust', 'Cobweb', 'Stains', 'Fingerprints', 'None', 'N/A'],
    'FURNITURE': [
      'Clutter',
      'Cobweb',
      'Dust',
      'Fingerprints',
      'Gums',
      'Ink marks',
      'Stains',
      'None',
      'N/A',
    ],
    'DECOR': ['Dust', 'Cobweb', 'None', 'N/A'],
    'CARPET': [
      'Clutter',
      'Droppings',
      'Dust',
      'Gums',
      'Microbes',
      'Mud',
      'Odor',
      'Sand',
      'Spills',
      'Stains',
      'Trash',
      'None',
      'N/A',
    ],
    'FLOOR': [
      'Clutter',
      'Corner Stains',
      'Droppings',
      'Dust',
      'Dirty Grout',
      'Gums',
      'Microbes',
      'Mop Marks',
      'Mold',
      'Mud',
      'Odor',
      'Sand',
      'Shoe marks',
      'Spills',
      'Trash',
      'None',
      'N/A',
    ],
    'YARD': [
      'Trash',
      'Weeds',
      'Cobweb',
      'Oil stains',
      'Debris',
      'Clutter',
      'None',
      'N/A',
    ],
    'SANITARY WARE': [
      'Stains',
      'Dust',
      'Microbes',
      'Mold',
      'Odor',
      'Spills',
      'None',
      'N/A',
    ],
  };

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selections = defectOptions.map((key, value) => MapEntry(key, <String>{}));
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      final data = await location.getLocation();
      setState(() {
        latitude = data.latitude;
        longitude = data.longitude;
        locationName = "Captured via GPS";
      });
    }
  }

  Map<String, double> _calculateAreaScores() {
    Map<String, double> areaScores = {};

    selections.forEach((area, selected) {
      int totalOptions = defectOptions[area]!.length - 2;
      if (selected.contains('None')) {
        areaScores[area] = 100.0;
      } else if (selected.contains('N/A')) {
        return;
      } else {
        int defectOptionsSelected = selected.length;
        int nonDefectSelections = totalOptions - defectOptionsSelected;
        areaScores[area] = (nonDefectSelections / totalOptions) * 100;
      }
    });

    return areaScores;
  }

  String? _getIncompleteCategory() {
    for (var category in selections.keys) {
      if (selections[category]!.isEmpty) {
        return category;
      }
    }
    return null;
  }

  Future<void> _submitDataToBackend() async {
    final incompleteCategory = _getIncompleteCategory();

    if (incompleteCategory != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete the $incompleteCategory section.'),
        ),
      );
      _scrollToCategory(incompleteCategory);
      return;
    }

    setState(() => _isSubmitting = true);
    _submissionTime = DateTime.now();

    final areaScores = _calculateAreaScores();

    // ✅ Convert roomId safely (avoid "null" string)
    final parsedRoomId = int.tryParse(widget.roomId);
    final data = {
      "task_type": "Inspection",
      "latitude": latitude,
      "longitude": longitude,
      "user_id": widget.currentUserId,
      "done_by_user_id": widget.currentUserId,
      "done_on_behalf_of_user_id": widget.doneOnBehalfUserId,
      "room_id": parsedRoomId, // <-- send null if not a valid int
      "zone_name": widget.zoneName,
      "area_scores": areaScores,
      "zone_score": null,
      "facility_score": null,
    };

    print("📤 Submitting inspection data: $data");

    try {
      final response = await http.post(
        Uri.parse(
          'https://spaklean-mobile-backend.onrender.com/api/tasks/submit',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("✅ Server response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 201) {
        _showSubmissionSummary(areaScores);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${response.body}')),
        );
      }
    } catch (e) {
      print("❌ Error submitting inspection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting inspection: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSubmissionSummary(Map<String, double> areaScores) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submission Summary'),
          content: Text(
            'Room: ${widget.roomName}\n'
            'Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_submissionTime!)}\n'
            'Location: ${latitude != null ? "Lat: $latitude, Long: $longitude" : "Unavailable"}\n\n'
            'Scores:\n${areaScores.entries.map((e) => "${e.key}: ${e.value.toStringAsFixed(1)}%").join("\n")}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToCategory(String category) {
    final index = defectOptions.keys.toList().indexOf(category);
    final offset = index * 250.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkpoint: ${widget.roomName}"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ...defectOptions.entries.map((entry) {
                return buildCategory(entry.key, entry.value);
              }).toList(),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submitDataToBackend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Submit Inspection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategory(String category, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                options.map((option) {
                  return FilterChip(
                    label: Text(option),
                    selected: selections[category]?.contains(option) ?? false,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selections[category]?.add(option);
                          if (option == 'None' || option == 'N/A') {
                            selections[category]!.clear();
                            selections[category]!.add(option);
                          } else {
                            selections[category]?.remove('None');
                            selections[category]?.remove('N/A');
                          }
                        } else {
                          selections[category]?.remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const Divider(thickness: 1.5, color: Colors.grey),
        ],
      ),
    );
  }
}
