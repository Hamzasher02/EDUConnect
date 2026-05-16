import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/messaging/message_model.dart';
import '../../../data/models/messaging/message_delivery_status.dart';
import '../../../data/enums/app_enums.dart';
import '../../../services/audit_service.dart';
import '../../../services/firestore_helper.dart';
import '../../../services/auth_service.dart';

class MessageController extends GetxController {
  final _authService = Get.find<AuthService>();

  // Current selected school ID
  final _selectedSchoolId = ''.obs;
  String get selectedSchoolId => _selectedSchoolId.value;

  // Real-time messages list
  final messages = <MessageModel>[].obs;

  // Input controller
  final messageInputController = TextEditingController();

  void setSchoolId(String schoolId) {
    if (_selectedSchoolId.value == schoolId) return;
    _selectedSchoolId.value = schoolId;

    // Bind to real Firestore stream
    messages.bindStream(
      FirestoreHelper.messages
          .where('schoolId', isEqualTo: schoolId)
          // To avoid Firebase index errors immediately, we get the stream and sort in Dart
          .snapshots()
          .map((query) {
            final list = query.docs.map((doc) {
              return MessageModel.fromJson(
                doc.data() as Map<String, dynamic>..['id'] = doc.id,
              );
            }).toList();

            // Filter out messages not involving Super Admin chat if needed
            // but typically all messages here are supposed to be the chat
            // To be safe, let's filter those where either sender or receiver is 'super_admin'
            final filtered = list
                .where(
                  (m) =>
                      m.senderId == 'super_admin' ||
                      m.receiverId == 'super_admin',
                )
                .toList();

            // Sort chronologically
            filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            return filtered;
          }),
    );
    
    // Mark as read immediately when entering the chat
    markMessagesAsRead(schoolId);
  }

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Error',
        'Message cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Determine current user
    final currentUser = _authService.session.value;
    if (currentUser == null) return;

    final isSuperAdmin = currentUser.role == UserRole.superAdmin;
    final senderId = isSuperAdmin ? 'super_admin' : currentUser.userId;
    final receiverId = isSuperAdmin ? selectedSchoolId : 'super_admin';
    final senderRole = currentUser.role;
    final receiverRole = isSuperAdmin
        ? UserRole.schoolAdmin
        : UserRole.superAdmin;

    final message = MessageModel(
      id: '', // Firestore auto-id
      schoolId: selectedSchoolId,
      senderId: senderId,
      senderRole: senderRole,
      receiverId: receiverId,
      receiverRole: receiverRole,
      content: text,
      timestamp: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.sent,
      isRead: false,
    );

    messageInputController.clear(); // Clear UI immediately

    try {
      final docRef = await FirestoreHelper.messages.add(message.toJson());
      await docRef.update({'id': docRef.id});

      if (isSuperAdmin) {
        await FirestoreHelper.notifications
            .add({
              'id': '',
              'schoolId': selectedSchoolId,
              'title': 'New Message from Super Admin',
              'message': text,
              'type': 'message',
              'audience': 'school_admin',
              'timestamp': DateTime.now().toIso8601String(),
              'senderId': 'super_admin',
              'isRead': false,
            })
            .then((doc) => doc.update({'id': doc.id}));
      } else {
        String sName = currentUser.name ?? 'User';
        // Fetch actual school name for formal notification
        final schoolDoc = await FirebaseFirestore.instance.collection('schools').doc(selectedSchoolId).get();
        final actualSchoolName = schoolDoc.data()?['name'] ?? 'School';
        
        // We probably want the current school's name here. 
        // For simplicity, let's just make sure we save the schoolId for linking.
        await FirebaseFirestore.instance.collection('super_admin_notifications').add({
          'title': 'New Message from $actualSchoolName',
          'message': text,
          'senderName': sName,
          'schoolName': actualSchoolName,
          'schoolId': selectedSchoolId,
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Audit log
      if (Get.isRegistered<AuditService>()) {
        AuditService.to.logAction(
          actionType: 'MESSAGE_SENT',
          targetType: 'SCHOOL',
          targetId: selectedSchoolId,
          performedBy: isSuperAdmin ? 'Super Admin' : 'School Admin',
          metadata: {'content': message.content},
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  Future<void> markMessagesAsRead(String schoolId) async {
    try {
      final currentUser = _authService.session.value;
      if (currentUser == null) return;

      final isSuperAdmin = currentUser.role == UserRole.superAdmin;
      final targetReceiverId = isSuperAdmin ? 'super_admin' : schoolId;

      final unread = await FirestoreHelper.messages
          .where('schoolId', isEqualTo: schoolId)
          .where('receiverId', isEqualTo: targetReceiverId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unread.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  @override
  void onClose() {
    messageInputController.dispose();
    super.onClose();
  }
}
