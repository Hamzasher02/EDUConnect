import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_timetable_controller.dart';
import '../../../theme/app_colors.dart';

class TeacherTimetableView extends GetView<TeacherTimetableController> {
  const TeacherTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local state for tabs since controller doesn't track UI tab state
    final selectedDay = 'Mon'.obs;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          // Days Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: days
                  .map(
                    (day) => Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(day),
                          selected: selectedDay.value == day,
                          onSelected: (val) {
                            if (val) selectedDay.value = day;
                          },
                          selectedColor: AppColors.accentLime,
                          backgroundColor: AppColors.cardDark,
                          labelStyle: TextStyle(
                            color: selectedDay.value == day
                                ? AppColors.primaryBlack
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          Expanded(
            child: Obx(() {
              final classes = controller.getTimetableForDay(selectedDay.value);
              // Sort by start time
              classes.sort((a, b) => a.startTime.compareTo(b.startTime));

              if (classes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        color: Colors.white24,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes on ${selectedDay.value}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final cls = classes[index];
                  return Card(
                    color: AppColors.cardDark,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cls.startTime,
                            style: const TextStyle(
                              color: AppColors.accentLime,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cls.endTime,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        'Class ${cls.classNumber}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${cls.subjectName} • ${cls.roomNumber}',
                        style: const TextStyle(color: Colors.white70),
                      ),
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
