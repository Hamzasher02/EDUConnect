import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/school_admin_controller.dart';
import '../../../theme/app_colors.dart';

class CreateClassView extends GetView<SchoolAdminController> {
  const CreateClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text(
          'Create New Class',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Class Selection',
                style: TextStyle(
                  color: AppColors.accentLime,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
      
              // Class Name Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.cardDark,
                value: controller.createClassName.value.isEmpty ? null : controller.createClassName.value,
                onChanged: (val) {
                  if (val != null) controller.onClassSelected(val);
                },
                items: controller.predefinedClasses.keys.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(
                      className,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Select Class Name *',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.school,
                    color: AppColors.accentLime,
                  ),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentLime),
                  ),
                ),
              ),
      
              const SizedBox(height: 20),
      
              // Description (Auto-populated)
              Obx(() => TextField(
                controller: TextEditingController(text: controller.createClassDescription.value)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.createClassDescription.value.length),
                  ),
                onChanged: (val) => controller.createClassDescription.value = val,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: AppColors.accentLime,
                  ),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentLime),
                  ),
                ),
              )),
      
              const SizedBox(height: 25),
      
              // Auto-Added Subjects Section
              const Text(
                'Standard Subjects',
                style: TextStyle(
                  color: AppColors.accentLime,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: controller.draftSubjects.isEmpty
                    ? const Text(
                        'Select a class to see subjects',
                        style: TextStyle(color: Colors.white38),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.draftSubjects.map((sub) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentLime.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.accentLime.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              sub,
                              style: const TextStyle(
                                color: AppColors.accentLime,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              )),
      
              const SizedBox(height: 25),
      
              // Custom Subjects Section
              const Text(
                'Add More Subjects (Optional)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.subjectInputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add subject...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: controller.addDraftSubject,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accentLime,
                      foregroundColor: AppColors.primaryBlack,
                    ),
                  ),
                ],
              ),
      
              const SizedBox(height: 40),
      
              // Create Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.createNewClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Class',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
