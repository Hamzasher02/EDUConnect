import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';

class ClassTimetableHubView extends GetView<SchoolAdminController> {
  const ClassTimetableHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Timetables')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.classList.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final classInfo = controller.classList[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.schedule)),
            title: Text(
              classInfo.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Tap to view/manage timetable'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              controller.goToClassTimetable(classInfo.name);
            },
          );
        },
      ),
    );
  }
}
