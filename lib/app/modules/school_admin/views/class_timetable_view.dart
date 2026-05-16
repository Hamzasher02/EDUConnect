import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../models/school_admin_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';

class ClassTimetableView extends GetView<SchoolAdminController> {
  const ClassTimetableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(
          () => Text(
            'Timetable - ${controller.selectedTimetableClass}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.sync,
                color: controller.isOffline.value
                    ? Colors.white24
                    : AppColors.accentLime,
              ),
              onPressed: controller.saveTimetableChanges,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlack, Color(0xFF1A1A1A)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            _buildDaySelector(),
            Expanded(
              child: Obx(() {
                final slots = controller.currentDaySlots;
                if (slots.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No classes scheduled',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort slots by time
                final sortedSlots = List<ClassTimetableSlotModel>.from(slots);
                sortedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedSlots.length,
                  itemBuilder: (context, index) {
                    return _buildSlotCard(sortedSlots[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.isOffline.value
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: () => _showAddSlotSheet(context),
                backgroundColor: AppColors.accentLime,
                child: const Icon(Icons.add, color: AppColors.primaryBlack),
              ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          return Obx(() {
            final isSelected = controller.timetableSelectedDay.value == day;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (val) =>
                    controller.timetableSelectedDay.value = day,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedColor: AppColors.accentLime,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryBlack : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSlotCard(ClassTimetableSlotModel slot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.accentLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book_outlined,
                color: AppColors.accentLime,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.subjectName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${slot.startTime} - ${slot.endTime} • Room ${slot.roomNumber}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Teacher: ${slot.teacherName}',
                    style: TextStyle(
                      color: AppColors.accentLime.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => controller.removeTimetableSlot(slot.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSlotSheet(BuildContext context) {
    if (controller.isOffline.value) {
      Get.snackbar('Offline', 'Cannot add slots while offline');
      return;
    }

    final startTime = Rx<TimeOfDay>(TimeOfDay(hour: 9, minute: 0));
    final endTime = Rx<TimeOfDay>(TimeOfDay(hour: 10, minute: 0));
    final selectedSubjectId = ''.obs;
    final selectedSubjectName = ''.obs;
    final selectedTeacherId = ''.obs;
    final selectedTeacherName = ''.obs;
    final roomController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: AppColors.accentLime.withValues(alpha: 0.1),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              const Text(
                'Add New Class Slot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scheduling for ${controller.selectedTimetableClass} on ${controller.timetableSelectedDay}',
                style: TextStyle(
                  color: AppColors.accentLime.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Subject Selection
              const _FieldLabel('Select Subject'),
              Obx(() {
                final subs = controller.getSubjectsForClass(
                  controller.selectedTimetableClass.value,
                );
                return _buildDropdown<String>(
                  value: selectedSubjectId.value.isEmpty
                      ? null
                      : selectedSubjectId.value,
                  hint: 'Choose Subject',
                  items: subs.map((s) {
                    return DropdownMenuItem(value: s.id, child: Text(s.name));
                  }).toList(),
                  onChanged: (v) {
                    selectedSubjectId.value = v!;
                    selectedSubjectName.value = subs
                        .firstWhere((s) => s.id == v)
                        .name;
                  },
                );
              }),

              const SizedBox(height: 20),

              // Teacher Selection
              const _FieldLabel('Assign Teacher'),
              Obx(() {
                final teachers = controller.base.schoolDataService
                    .getTeachersBySchool(controller.base.currentSchoolId);
                return _buildDropdown<String>(
                  value: selectedTeacherId.value.isEmpty
                      ? null
                      : selectedTeacherId.value,
                  hint: 'Choose Teacher',
                  items: teachers.map((t) {
                    return DropdownMenuItem(value: t.id, child: Text(t.name));
                  }).toList(),
                  onChanged: (v) {
                    selectedTeacherId.value = v!;
                    selectedTeacherName.value = teachers
                        .firstWhere((t) => t.id == v)
                        .name;
                  },
                );
              }),

              const SizedBox(height: 20),

              // Time Selection (Start & End)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Start Time'),
                        Obx(
                          () => _buildTimePicker(
                            context,
                            startTime.value,
                            (time) => startTime.value = time,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('End Time'),
                        Obx(
                          () => _buildTimePicker(
                            context,
                            endTime.value,
                            (time) => endTime.value = time,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Room Number
              const _FieldLabel('Room Number'),
              TextField(
                controller: roomController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. G-101',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedSubjectId.value.isEmpty ||
                        selectedTeacherId.value.isEmpty ||
                        roomController.text.isEmpty) {
                      Get.snackbar('Error', 'Please fill all fields');
                      return;
                    }

                    controller.addTimetableSlot(
                      subjectId: selectedSubjectId.value,
                      subjectName: selectedSubjectName.value,
                      teacherId: selectedTeacherId.value,
                      teacherName: selectedTeacherName.value,
                      start: startTime.value.format(context),
                      end: endTime.value.format(context),
                      room: roomController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Slot',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
          isExpanded: true,
          dropdownColor: AppColors.cardDark,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.accentLime,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.accentLime,
                  onPrimary: Colors.black,
                  surface: AppColors.cardDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time.format(context),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const Icon(
              Icons.access_time,
              color: AppColors.accentLime,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
