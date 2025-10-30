import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;

  const AdminDashboardScreen({super.key, required this.token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List offices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOffices();
  }

  Future<void> fetchOffices() async {
    final url = Uri.parse('$baseUrl/api/admin/offices');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        offices = jsonDecode(response.body)['offices'];
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load offices')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : offices.isEmpty
              ? const Center(child: Text('No offices found'))
              : ListView.builder(
                itemCount: offices.length,
                itemBuilder: (context, index) {
                  final office = offices[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.apartment, color: Colors.teal),
                      title: Text(office['name']),
                      subtitle: Text('Office ID: ${office['id']}'),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          // TODO: Add "Add Office" form later
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
