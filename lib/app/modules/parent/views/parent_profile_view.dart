import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/parent_controller.dart';

/// Parent Profile View - View and edit parent profile information
class ParentProfileView extends GetView<ParentController> {
  const ParentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final parent = controller.currentParent.value;

        if (parent == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 50,
                child: Text(
                  parent.name.isNotEmpty ? parent.name[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoTile('Name', parent.name),
              _buildInfoTile('CNIC', parent.parentCnic),
              _buildInfoTile('Email', parent.email),
              _buildInfoTile('Contact', parent.contactNumber),
              if (parent.address != null)
                _buildInfoTile('Address', parent.address!),
              const SizedBox(height: 24),
              _buildInfoTile(
                'Linked Students',
                '${parent.linkedStudentIds.length}',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
