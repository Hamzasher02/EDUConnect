class BackupSnapshotModel {
  final String id;
  final DateTime timestamp;
  final String type; // 'manual', 'weekly', 'monthly'
  final String sizeLabel; // e.g., '120MB'
  final String notes;
  final String? downloadUrl;

  BackupSnapshotModel({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.sizeLabel,
    this.notes = '',
    this.downloadUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'sizeLabel': sizeLabel,
    'notes': notes,
    'downloadUrl': downloadUrl,
  };

  factory BackupSnapshotModel.fromJson(Map<String, dynamic> json, String id) =>
      BackupSnapshotModel(
        id: id,
        timestamp: DateTime.parse(json['timestamp']),
        type: json['type'],
        sizeLabel: json['sizeLabel'],
        notes: json['notes'] ?? '',
        downloadUrl: json['downloadUrl'],
      );
}
