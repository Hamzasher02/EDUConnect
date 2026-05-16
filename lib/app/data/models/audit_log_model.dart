class AuditLogModel {
  final String id;
  final String actionType;
  final String targetType;
  final String targetId;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  AuditLogModel({
    required this.id,
    required this.actionType,
    required this.targetType,
    required this.targetId,
    required this.performedBy,
    required this.timestamp,
    required this.metadata,
  });

  @override
  String toString() {
    return 'AuditLog{action: $actionType, target: $targetType/$targetId, by: $performedBy, at: $timestamp}';
  }
}

