import '../../enums/app_enums.dart';
import 'message_model.dart';

class ConversationModel {
  final String participantId;
  final String participantName;
  final UserRole participantRole;
  final MessageModel lastMessage;
  final int unreadCount;

  ConversationModel({
    required this.participantId,
    required this.participantName,
    required this.participantRole,
    required this.lastMessage,
    required this.unreadCount,
  });
}
