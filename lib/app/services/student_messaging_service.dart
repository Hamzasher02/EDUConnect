import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import 'firestore_helper.dart';
import '../data/models/messaging/message_model.dart';
import '../data/models/messaging/conversation_model.dart';
import '../data/models/messaging/message_delivery_status.dart';
import '../data/enums/app_enums.dart';

class StudentMessagingService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession() {
    final session = _authService.session.value;
    if (session == null) {
      throw 'Unauthorized access';
    }
  }

  Future<List<ConversationModel>> getInbox(String studentId) async {
    _validateSession();

    final allMessages = _schoolDataService.getStudentMessages(studentId);

    final Map<String, List<MessageModel>> participantGroups = {};
    for (var msg in allMessages) {
      final participantId = msg.senderId == studentId
          ? msg.receiverId
          : msg.senderId;
      participantGroups.putIfAbsent(participantId, () => []).add(msg);
    }

    final List<ConversationModel> inbox = [];
    for (var entry in participantGroups.entries) {
      final participantId = entry.key;
      final messages = entry.value;
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final lastMessage = messages.first;
      final unreadCount = messages
          .where((m) => m.receiverId == studentId && !m.isRead)
          .length;

      // RESOLVE PARTICIPANT INFO DYNAMICALLY FROM FIRESTORE
      final participantData = await _resolveParticipantInfo(participantId);

      inbox.add(
        ConversationModel(
          participantId: participantId,
          participantName:
              (participantData['name'] as String?) ??
              'User ${participantId.substring(0, 5)}',
          participantRole:
              (participantData['role'] as UserRole?) ?? UserRole.teacher,
          lastMessage: lastMessage,
          unreadCount: unreadCount,
        ),
      );
    }

    inbox.sort(
      (a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp),
    );
    return inbox;
  }

  Future<Map<String, dynamic>> _resolveParticipantInfo(String userId) async {
    try {
      final userDoc = await FirestoreHelper.db
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'name': data['name'],
          'role': UserRole.values[data['role'] as int],
        };
      }

      // Fallback lookups
      final teacherDoc = await FirestoreHelper.teachers.doc(userId).get();
      if (teacherDoc.exists) {
        final data = teacherDoc.data() as Map<String, dynamic>?;
        return {'name': data?['name'], 'role': UserRole.teacher};
      }
    } catch (e) {
      print('Error resolving participant info: $userId - $e');
    }
    return {};
  }

  Future<List<MessageModel>> getConversation(
    String studentId,
    String participantId,
  ) async {
    _validateSession();
    final allMessages = _schoolDataService.getStudentMessages(studentId);

    final conversation = allMessages.where((m) {
      return (m.senderId == studentId && m.receiverId == participantId) ||
          (m.senderId == participantId && m.receiverId == studentId);
    }).toList();

    conversation.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return conversation;
  }

  Future<MessageModel> sendMessage(
    String studentId,
    String receiverId,
    String content, {
    bool isOffline = false,
  }) async {
    _validateSession();
    final session = _authService.session.value;
    final schoolId = session?.schoolId ?? '';

    // Security Check: Resolve receiver role
    final receiverData = await _resolveParticipantInfo(receiverId);
    final receiverRole =
        (receiverData['role'] as UserRole?) ?? UserRole.teacher;

    final newMessage = MessageModel(
      id: '', // Firestore gen
      schoolId: schoolId,
      senderId: studentId,
      receiverId: receiverId,
      senderRole: UserRole.student,
      receiverRole: receiverRole,
      content: content,
      timestamp: DateTime.now(),
      deliveryStatus: isOffline
          ? MessageDeliveryStatus.pendingOffline
          : MessageDeliveryStatus.sent,
    );

    // Write to Firestore
    final docRef = await FirestoreHelper.messages.add(
      newMessage.toJson()..['timestamp'] = FieldValue.serverTimestamp(),
    );

    return newMessage.copyWith(id: docRef.id);
  }

  Future<void> markAsRead(String studentId, String participantId) async {
    final snapshot = await FirestoreHelper.messages
        .where('receiverId', isEqualTo: studentId)
        .where('senderId', isEqualTo: participantId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirestoreHelper.db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
