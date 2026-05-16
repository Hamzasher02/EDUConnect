import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/teacher_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/enums/app_enums.dart';

class TeacherInboxView extends GetView<TeacherController> {
  const TeacherInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadInbox(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.inbox.isEmpty) {
          return const EmptyState(
            icon: Icons.message_outlined,
            title: 'No Messages Yet',
            subtitle: 'Start a conversation with Admin or Parents',
          );
        }

        return ListView.separated(
          itemCount: controller.inbox.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final msg = controller.inbox[index];
            final partnerId =
                msg.senderId ==
                    controller
                        .name
                        .value // Simple mock check
                ? msg.receiverId
                : msg.senderId;

            final partnerName = msg.receiverRole == UserRole.schoolAdmin
                ? 'School Admin'
                : 'Parent ($partnerId)';
            final isUnread =
                !msg.isRead && msg.receiverId != 'admin_1'; // Simple logic

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  msg.receiverRole == UserRole.schoolAdmin
                      ? Icons.admin_panel_settings
                      : Icons.person,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                partnerName,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                msg.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnread ? Colors.black87 : Colors.grey,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(msg.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (isUnread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              onTap: () {
                controller.openConversation(partnerId);
                Get.toNamed(AppRoutes.teacherChat, arguments: partnerId);
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageDialog(context),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context) {
    final parentIdController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('New Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Message School Admin'),
              onTap: () {
                Get.back();
                controller.openConversation('admin_1');
                Get.toNamed(AppRoutes.teacherChat, arguments: 'admin_1');
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Or Message a Parent',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: parentIdController,
              decoration: const InputDecoration(
                labelText: 'Parent ID / Student Roll No',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (parentIdController.text.isNotEmpty) {
                final id = parentIdController.text;
                Get.back();
                controller.openConversation(id);
                Get.toNamed(AppRoutes.teacherChat, arguments: id);
              }
            },
            child: const Text('Chat'),
          ),
        ],
      ),
    );
  }
}
