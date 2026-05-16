import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../controllers/message_controller.dart';
import '../../../data/models/messaging/message_model.dart';
import '../../../data/enums/app_enums.dart';

class MessageView extends GetView<MessageController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get schoolId from arguments
    final schoolId = Get.arguments as String?;
    final schoolName = Get.parameters['schoolName'] ?? 'School';

    if (schoolId == null || schoolId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text(
            'No school selected',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    controller.setSchoolId(schoolId);

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chat with $schoolName',
          style: const TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background blob
          Positioned(
            top: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.accentLime.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Column(
            children: [
              // Messages list
              Expanded(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                }),
              ),

              // Input area
              GlassContainer(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageInputController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.sendMessage,
                      icon: const Icon(Icons.send, color: AppColors.accentLime),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isFromSuper = message.senderRole == UserRole.superAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromSuper
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isFromSuper) const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromSuper
                    ? AppColors.accentLime.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFromSuper
                      ? AppColors.accentLime.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${TimeOfDay.fromDateTime(message.timestamp).hour.toString().padLeft(2, '0')}:${TimeOfDay.fromDateTime(message.timestamp).minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isFromSuper) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
