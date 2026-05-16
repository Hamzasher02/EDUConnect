import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/teacher_controller.dart';
import '../../../data/models/messaging/message_model.dart';
import '../../../theme/app_colors.dart';

class TeacherChatView extends GetView<TeacherController> {
  const TeacherChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final String partnerId = Get.arguments ?? 'admin_1';
    final partnerName = partnerId == 'admin_1'
        ? 'School Admin'
        : 'Parent ($partnerId)';
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(partnerName, style: const TextStyle(fontSize: 18)),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, color: Colors.greenAccent),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.isOffline.value) {
              return Container(
                width: double.infinity,
                color: Colors.orange.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Offline Mode: Messages will queue',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.activeConversation.length,
                itemBuilder: (context, index) {
                  final msg = controller.activeConversation[index];
                  // In real app, check msg.senderId == currentUserId
                  final isMe =
                      msg.receiverId != controller.activePartnerId.value;

                  return _ChatBubble(message: msg, isMe: isMe);
                },
              );
            }),
          ),
          _buildMessageInput(messageController, partnerId),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    TextEditingController textController,
    String partnerId,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => CircleAvatar(
                backgroundColor: AppColors.primary,
                child: controller.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (textController.text.isNotEmpty) {
                            controller.sendMessage(
                              partnerId,
                              textController.text,
                            );
                            textController.clear();
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
