import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../services/auth_service.dart';
import '../../message/controllers/message_controller.dart';

class SuperAdminNotificationsView extends StatelessWidget {
  const SuperAdminNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthService.to.session.value;
    if (session == null) {
      return const Scaffold(
        backgroundColor: AppColors.primaryBlack,
        body: Center(
          child: Text('Not logged in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('super_admin_notifications')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentLime),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'School admins can send messages from the School Detail screen',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildNotificationCard(data, doc.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data, String docId) {
    final title = data['title'] as String? ?? 'Notification';
    final message = data['message'] as String? ?? '';
    final senderName = data['senderName'] as String? ?? 'School Admin';
    final schoolName = data['schoolName'] as String? ?? '';
    final schoolId = data['schoolId'] as String?;
    final isRead = data['isRead'] as bool? ?? false;
    final timestamp = data['timestamp'];
    DateTime? dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRead
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.accentLime.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: isRead ? Colors.white38 : AppColors.accentLime,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      if (schoolName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$senderName • $schoolName',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentLime,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
            if (dt != null) ...[
              const SizedBox(height: 10),
              Text(
                DateFormat('MMM d, y • hh:mm a').format(dt),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
            if (!isRead) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('super_admin_notifications')
                        .doc(docId)
                        .update({'isRead': true});

                    // If it was a message notification and has schoolId, mark that school's messages as read too
                    if (schoolId != null) {
                      if (!Get.isRegistered<MessageController>()) {
                        Get.put(MessageController());
                      }
                      Get.find<MessageController>().markMessagesAsRead(schoolId);
                    }
                  },
                  child: const Text(
                    'Mark as Read',
                    style: TextStyle(
                      color: AppColors.accentLime,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
