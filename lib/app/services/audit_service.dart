import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/models/audit_log_model.dart';

class AuditService extends GetxService {
  static AuditService get to => Get.find<AuditService>();

  final RxList<AuditLogModel> _auditLogs = <AuditLogModel>[].obs;
  List<AuditLogModel> get auditLogs => _auditLogs;

  void logAction({
    required String actionType,
    required String targetType,
    required String targetId,
    required String performedBy,
    Map<String, dynamic>? metadata,
  }) {
    final log = AuditLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: actionType,
      targetType: targetType,
      targetId: targetId,
      performedBy: performedBy,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _auditLogs.insert(0, log); // Insert at beginning (newest first)
    debugPrint('AUDIT: $log'); // Console log for debugging
  }

  List<AuditLogModel> getLogsBySchool(String schoolId) {
    return _auditLogs.where((log) => log.targetId == schoolId).toList();
  }

  List<AuditLogModel> getLogsByAction(String actionType) {
    return _auditLogs.where((log) => log.actionType == actionType).toList();
  }
}
