import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';

class ArchivedTeachersView extends GetView<SchoolAdminController> {
  const ArchivedTeachersView({super.key});

  @override
  Widget build(BuildContext context) {
    final search = ''.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Archived Teachers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => search.value = v,
              decoration: const InputDecoration(
                hintText: 'Search Archived Teachers (Name/Subject)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              var list = controller.archivedTeachers.toList();
              if (list.isEmpty) {
                return const Center(child: Text('No archived teachers.'));
              }

              if (search.value.isNotEmpty) {
                final q = search.value.toLowerCase();
                list = list
                    .where(
                      (t) =>
                          t.name.toLowerCase().contains(q) ||
                          t.subjectSpecialization.toLowerCase().contains(q),
                    )
                    .toList();
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final t = list[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.history_edu,
                        color: Colors.blueGrey,
                      ),
                      title: Text(t.name),
                      subtitle: Text(
                        '${t.subjectSpecialization} | Contact: ${t.contactNumber}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        controller.openArchiveReportDetail(
                          isStudent: false,
                          id: t.id,
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
