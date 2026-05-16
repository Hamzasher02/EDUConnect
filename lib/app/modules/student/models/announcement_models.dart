enum NotificationType { assignment, exam, fee, attendance, general }

class StudentAnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String postedBy;
  final DateTime postedDate;
  final String? attachmentUrl;

  StudentAnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.postedBy,
    required this.postedDate,
    this.attachmentUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'postedBy': postedBy,
    'postedDate': postedDate.toIso8601String(),
    'attachmentUrl': attachmentUrl,
  };

  factory StudentAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return StudentAnnouncementModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      postedBy: json['postedBy'],
      postedDate: DateTime.parse(json['postedDate']),
      attachmentUrl: json['attachmentUrl'],
    );
  }
}

class StudentNotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;

  StudentNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory StudentNotificationModel.fromJson(Map<String, dynamic> json) {
    return StudentNotificationModel(
      id: json['id'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  StudentNotificationModel copyWith({bool? isRead}) {
    return StudentNotificationModel(
      id: id,
      type: type,
      title: title,
      description: description,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
