import '../../enums/app_enums.dart';
import 'message_delivery_status.dart';

class MessageModel {
  final String id;
  final String schoolId;
  final String senderId;
  final String? senderName;
  final UserRole senderRole;
  final String receiverId;
  final UserRole receiverRole;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageDeliveryStatus deliveryStatus;
  final String? classId;

  MessageModel({
    required this.id,
    required this.schoolId,
    required this.senderId,
    this.senderName,
    required this.senderRole,
    required this.receiverId,
    required this.receiverRole,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.classId,
  });

  MessageModel copyWith({
    String? id,
    String? schoolId,
    String? senderId,
    String? senderName,
    UserRole? senderRole,
    String? receiverId,
    UserRole? receiverRole,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageDeliveryStatus? deliveryStatus,
    String? classId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      receiverId: receiverId ?? this.receiverId,
      receiverRole: receiverRole ?? this.receiverRole,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      classId: classId ?? this.classId,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'],
      senderRole: _parseRole(json['senderRole']),
      receiverId: json['receiverId'] ?? '',
      receiverRole: _parseRole(json['receiverRole']),
      content: json['content'] ?? json['text'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      deliveryStatus: _parseDeliveryStatus(json['deliveryStatus']),
      classId: json['classId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole.name,
      'receiverId': receiverId,
      'receiverRole': receiverRole.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'deliveryStatus': deliveryStatus.name,
      'classId': classId,
    };
  }

  static UserRole _parseRole(dynamic role) {
    if (role is UserRole) return role;
    final roleStr = role.toString().toLowerCase();
    return UserRole.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == roleStr ||
          e.toString().toLowerCase().contains(roleStr),
      orElse: () => UserRole.student,
    );
  }

  static MessageDeliveryStatus _parseDeliveryStatus(dynamic status) {
    if (status is MessageDeliveryStatus) return status;
    final statusStr = status.toString().toLowerCase();
    return MessageDeliveryStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr,
      orElse: () => MessageDeliveryStatus.sent,
    );
  }
}
