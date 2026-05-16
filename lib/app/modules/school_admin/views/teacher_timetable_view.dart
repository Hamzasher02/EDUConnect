import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../theme/app_colors.dart';

class TeacherTimetableView extends GetView<SchoolAdminController> {
  const TeacherTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.selectedTeacherId.value.isEmpty) {
      Future.microtask(() => Get.back());
      return const SizedBox();
    }

    final teacher = controller.teachers.firstWhere(
      (t) => t.id == controller.selectedTeacherId.value,
    );

    final selectedDay = 'Mon'.obs;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      appBar: AppBar(title: Text('Timetable: ${teacher.name}')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: days
                  .map(
                    (day) => Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(day),
                          selected: selectedDay.value == day,
                          onSelected: (v) {
                            if (v) {
                              selectedDay.value = day;
                              controller.timetableDay.value = day;
                            }
                          },
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              // Use teacherAssignments delegate
              final allAssignments =
                  controller.teacherAssignments[teacher.id] ?? [];
              final dayAssignments = allAssignments
                  .where((a) => a.day == selectedDay.value)
                  .toList();

              dayAssignments.sort((a, b) => a.startTime.compareTo(b.startTime));

              if (dayAssignments.isEmpty) {
                return Center(
                  child: Text('No classes assigned for ${selectedDay.value}'),
                );
              }

              return ListView.builder(
                itemCount: dayAssignments.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return _buildAssignmentCard(
                    context,
                    teacher.id,
                    dayAssignments[index],
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssignClassSheet(
          context,
          selectedDay.value,
          teacher.id,
          teacher.name,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    String teacherId,
    ClassTimetableSlotModel assignment,
  ) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          'Class ${assignment.classNumber} - ${assignment.subjectName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Room: ${assignment.roomNumber}  |  ${assignment.startTime} - ${assignment.endTime}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () =>
              controller.removeAssignedClass(teacherId, assignment.id),
        ),
      ),
    );
  }

  void _showAssignClassSheet(
    BuildContext context,
    String currentDay,
    String teacherId,
    String teacherName,
  ) {
    if (controller.isOffline.value) {
      Get.snackbar('Offline', 'Cannot assign classes offline.');
      return;
    }

    controller.timetableDay.value = currentDay;
    controller.timetableClass.value = '9';
    controller.timetableSubject.value = '';
    controller.timetableRoom.value = '';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Assign Class for $currentDay',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Obx(
                () => InputDecorator(
                  decoration: _buildInputDecoration('Class'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.timetableClass.value,
                      dropdownColor: AppColors.white,
                      style: const TextStyle(color: AppColors.primaryBlack),
                      isDense: true,
                      isExpanded: true,
                      items: ['9', '10', '11', '12']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => controller.timetableClass.value = v!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => controller.timetableSubject.value = v,
                style: const TextStyle(color: AppColors.primaryBlack),
                decoration: _buildInputDecoration('Subject'),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => controller.timetableRoom.value = v,
                style: const TextStyle(color: AppColors.primaryBlack),
                decoration: _buildInputDecoration('Room Number'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final subjects = controller.getSubjectsForClass(
                    controller.timetableClass.value,
                  );
                  final subjectObj = subjects.firstWhereOrNull(
                    (s) => s.name == controller.timetableSubject.value,
                  );

                  controller.addTimetableSlot(
                    subjectId:
                        subjectObj?.id ?? controller.timetableSubject.value,
                    subjectName: controller.timetableSubject.value,
                    teacherId: teacherId,
                    teacherName: teacherName,
                    start: '09:00', // Mock for now
                    end: '10:00',
                    room: controller.timetableRoom.value,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Assign Class',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentLime, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
