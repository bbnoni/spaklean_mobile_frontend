import 'package:flutter/material.dart';

import 'facility_inspection_screen.dart';
import 'supervisors_screen.dart'; // ✅ new import

class MainMenuScreen extends StatelessWidget {
  final String token;
  final int userId;
  final String role;

  const MainMenuScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // ✅ Facility Inspection button
            _buildMenuItem(
              context,
              'Facility Inspection',
              Icons.apartment_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FacilityInspectionScreen(
                          token: token,
                          userId: userId,
                        ),
                  ),
                );
              },
            ),

            // 🧩 Supervisors (visible only for Custodial Managers)
            if (role == 'Custodial Manager')
              _buildMenuItem(
                context,
                'Supervisors',
                Icons.supervisor_account,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SupervisorsScreen(
                            token: token,
                            userId: userId,
                            // 👇 Optional fields left null (allowed now)
                            roomId: null,
                            roomName: null,
                            zoneName: null,
                            locationName: null,
                          ),
                    ),
                  );
                },
              ),

            // 🧩 Other menu items
            _buildMenuItem(
              context,
              'Task Compliance',
              Icons.task_rounded,
              null,
            ),
            _buildMenuItem(
              context,
              'Tools & Equipment Audit',
              Icons.build_rounded,
              null,
            ),
            _buildMenuItem(context, 'Safety Records', Icons.book_rounded, null),
            _buildMenuItem(
              context,
              'Custodian Records',
              Icons.assignment_ind_rounded,
              null,
            ),
            _buildMenuItem(
              context,
              'Cleaning Times',
              Icons.cleaning_services_rounded,
              null,
            ),
            _buildMenuItem(
              context,
              'Notifications',
              Icons.notifications_rounded,
              null,
            ),
            _buildMenuItem(context, 'Setup', Icons.settings_rounded, null),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.teal),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
