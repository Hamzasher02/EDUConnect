class RestoreRequestModel {
  final String id;
  final String scope; // 'fullSystem', 'singleSchool', 'moduleBased'
  final String? targetSchoolId;
  final String? moduleName;
  final DateTime timestamp;
  String status; // 'pending', 'completed', 'failed'

  RestoreRequestModel({
    required this.id,
    required this.scope,
    this.targetSchoolId,
    this.moduleName,
    required this.timestamp,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'scope': scope,
    'targetSchoolId': targetSchoolId,
    'moduleName': moduleName,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
  };

  factory RestoreRequestModel.fromJson(Map<String, dynamic> json, String id) =>
      RestoreRequestModel(
        id: id,
        scope: json['scope'],
        targetSchoolId: json['targetSchoolId'],
        moduleName: json['moduleName'],
        timestamp: DateTime.parse(json['timestamp']),
        status: json['status'],
      );
}
