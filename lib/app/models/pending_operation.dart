enum OperationType { add, update, delete }

enum EntityType {
  timetable,
  student,
  notification,
  teacher,
  message,
  assignment,
}

class PendingOperation {
  final String id;
  final OperationType type;
  final EntityType entityType;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  PendingOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'entityType': entityType.toString(),
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}
