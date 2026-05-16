import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';

class ArchivedStudentsView extends GetView<SchoolAdminController> {
  const ArchivedStudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local search state since it's just for filtering this list locally if needed
    // But since report filters are already in controller, let's reuse or make simple local filter
    final search = ''.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Archived Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => search.value = v,
              decoration: const InputDecoration(
                hintText: 'Search Archived Students',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              var list = controller.archivedStudents.toList();
              if (list.isEmpty) {
                return const Center(child: Text('No archived students.'));
              }

              if (search.value.isNotEmpty) {
                final q = search.value.toLowerCase();
                list = list
                    .where(
                      (s) =>
                          s.name.toLowerCase().contains(q) ||
                          s.rollNo.toLowerCase().contains(q),
                    )
                    .toList();
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final s = list[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.archive, color: Colors.orange),
                      title: Text(s.name),
                      subtitle: Text(
                        'Roll: ${s.rollNo} | Class: ${s.classNumber}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        controller.openArchiveReportDetail(
                          isStudent: true,
                          id: s.id,
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
