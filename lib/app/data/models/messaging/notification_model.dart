import '../../../data/enums/app_enums.dart';

class NotificationModel {
  String id;
  String title;
  String message;
  DateTime timestamp;
  NotificationType type;
  NotificationAudience audience;
  NotificationStatus status;
  String? targetId; // Can be classId, studentId, or teacherId
  bool isRead;
  final String? senderId;

  DateTime get createdAt => timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = NotificationType.announcement,
    this.audience = NotificationAudience.wholeSchool,
    this.status = NotificationStatus.sent,
    this.targetId,
    this.isRead = false,
    this.senderId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => NotificationType.announcement,
        ),
        audience: NotificationAudience.values.firstWhere(
          (e) => e.toString() == json['audience'],
          orElse: () => NotificationAudience.wholeSchool,
        ),
        status: NotificationStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => NotificationStatus.sent,
        ),
        targetId: json['targetId'],
        isRead: json['isRead'] ?? false,
        senderId: json['senderId'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString(),
    'audience': audience.toString(),
    'status': status.toString(),
    'targetId': targetId,
    'isRead': isRead,
    'senderId': senderId,
  };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    NotificationAudience? audience,
    NotificationStatus? status,
    String? targetId,
    bool? isRead,
    String? senderId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      audience: audience ?? this.audience,
      status: status ?? this.status,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
    );
  }

  String get typeLabel {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  String get audienceLabel {
    switch (audience) {
      case NotificationAudience.wholeSchool:
        return 'Whole School';
      case NotificationAudience.teachers:
        return 'Teachers';
      case NotificationAudience.parents:
        return 'Parents';
      case NotificationAudience.specificStudent:
        return 'Individual Student';
      default:
        return 'Target Audience';
    }
  }
}
