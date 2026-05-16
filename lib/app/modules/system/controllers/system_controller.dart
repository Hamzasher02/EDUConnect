import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../services/firestore_helper.dart';
import '../../../data/models/backup_model.dart';
import '../../../data/models/restore_model.dart';
import '../../../services/audit_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SystemController extends GetxController {
  final RxList<BackupSnapshotModel> backups = <BackupSnapshotModel>[].obs;
  final RxList<RestoreRequestModel> restoreRequests =
      <RestoreRequestModel>[].obs;

  final isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListeners();
  }

  void _initFirestoreListeners() {
    FirestoreHelper.systemBackups
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          backups.assignAll(
            snapshot.docs.map((doc) {
              return BackupSnapshotModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList(),
          );
        });

    FirestoreHelper.systemRestoreRequests.snapshots().listen((snapshot) {
      restoreRequests.assignAll(
        snapshot.docs.map((doc) {
          return RestoreRequestModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList(),
      );
      restoreRequests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> generateBackup() async {
    if (isGenerating.value) return;

    Get.dialog(
      Obx(
        () => SimpleDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Generating Backup',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            const SizedBox(height: 8),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFC6F135)),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                isGenerating.value ? 'Collecting & uploading data...' : 'Done!',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    isGenerating.value = true;

    try {
      // ── Step 1: Collect all data from Firestore ──
      final snapshot = await _collectAllData();

      // ── Step 2: Serialize to JSON bytes ──
      final jsonString = jsonEncode(snapshot);
      final bytes = utf8.encode(jsonString);
      final sizeLabel = _formatBytes(bytes.length);

      // ── Step 3: Upload to Firebase Storage ──
      final timestamp = DateTime.now();
      final fileName =
          'backups/system_backup_${timestamp.millisecondsSinceEpoch}.json';

      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'application/json'),
      );

      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // ── Step 4: Save backup record to Firestore ──
      final newBackup = BackupSnapshotModel(
        id: '',
        timestamp: timestamp,
        type: 'Manual',
        sizeLabel: sizeLabel,
        downloadUrl: downloadUrl,
        notes:
            'Full system snapshot: ${snapshot['schoolCount']} schools, '
            '${snapshot['studentCount']} students, ${snapshot['teacherCount']} teachers',
      );

      final docRef = await FirestoreHelper.systemBackups.add(
        newBackup.toJson(),
      );

      // ── Step 5: Also update the doc with its own Firestore ID ──
      await docRef.update({'id': docRef.id});

      isGenerating.value = false;
      Get.back(); // Close dialog

      // Audit Log
      if (Get.isRegistered<AuditService>()) {
        AuditService.to.logAction(
          actionType: 'BACKUP_GENERATED',
          targetType: 'SYSTEM',
          targetId: docRef.id,
          performedBy: 'Super Admin',
          metadata: {
            'size': sizeLabel,
            'type': 'Manual',
            'downloadUrl': downloadUrl,
          },
        );
      }

      Get.snackbar(
        'Backup Created',
        'System backup generated ($sizeLabel). Download is now available.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      isGenerating.value = false;
      Get.back();
      Get.snackbar(
        'Backup Failed',
        'Error generating backup: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Collects a complete snapshot of all Firestore collections
  Future<Map<String, dynamic>> _collectAllData() async {
    final data = <String, dynamic>{};
    int schoolCount = 0;
    int studentCount = 0;
    int teacherCount = 0;

    // ── Schools ──
    final schoolsSnapshot = await FirestoreHelper.schools.get();
    schoolCount = schoolsSnapshot.docs.length;
    data['schools'] = schoolsSnapshot.docs.map((d) {
      return {'id': d.id, ...d.data() as Map<String, dynamic>};
    }).toList();

    // ── Per-school sub-collections ──
    for (final schoolDoc in schoolsSnapshot.docs) {
      final schoolId = schoolDoc.id;

      // Students
      final studentsSnap = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('students')
          .get();
      studentCount += studentsSnap.docs.length;
      data['students_$schoolId'] = studentsSnap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();

      // Teachers
      final teachersSnap = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('teachers')
          .get();
      teacherCount += teachersSnap.docs.length;
      data['teachers_$schoolId'] = teachersSnap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();

      // Classes
      final classesSnap = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('classes')
          .get();
      data['classes_$schoolId'] = classesSnap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();

      // Subjects
      final subjectsSnap = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('subjects')
          .get();
      data['subjects_$schoolId'] = subjectsSnap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();

      // Teacher Assignments
      final assignmentsSnap = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('teacherAssignments')
          .get();
      data['teacherAssignments_$schoolId'] = assignmentsSnap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();

      // Exam Schedules
      final examSchedulesSnap = await FirestoreHelper.schools
          .doc(schoolId)
          .collection('exam_schedules')
          .get();
      data['examSchedules_$schoolId'] = examSchedulesSnap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();
    }

    // ── Global collections ──
    final timetableSnap = await FirestoreHelper.timetables.get();
    data['timetables'] = timetableSnap.docs.map((d) {
      return {'id': d.id, ...d.data() as Map<String, dynamic>};
    }).toList();

    final examsSnap = await FirestoreHelper.exams.get();
    data['exams'] = examsSnap.docs.map((d) {
      return {'id': d.id, ...d.data() as Map<String, dynamic>};
    }).toList();

    final feesSnap = await FirestoreHelper.fees.get();
    data['fees'] = feesSnap.docs.map((d) {
      return {'id': d.id, ...d.data() as Map<String, dynamic>};
    }).toList();

    final attendanceSnap = await FirestoreHelper.attendance.get();
    data['attendance'] = attendanceSnap.docs.map((d) {
      return {'id': d.id, ...d.data() as Map<String, dynamic>};
    }).toList();

    final notificationsSnap = await FirestoreHelper.notifications.get();
    data['notifications'] = notificationsSnap.docs.map((d) {
      return {'id': d.id, ...d.data() as Map<String, dynamic>};
    }).toList();

    data['schoolCount'] = schoolCount;
    data['studentCount'] = studentCount;
    data['teacherCount'] = teacherCount;
    data['generatedAt'] = DateTime.now().toIso8601String();
    data['version'] = '1.0';

    return data;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> downloadBackup(BackupSnapshotModel backup) async {
    final url = backup.downloadUrl;

    if (url == null || url.isEmpty) {
      Get.snackbar(
        'URL Not Available',
        'Download URL is missing for this backup. Please regenerate a new backup.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (Get.isRegistered<AuditService>()) {
          AuditService.to.logAction(
            actionType: 'BACKUP_DOWNLOADED',
            targetType: 'SYSTEM',
            targetId: backup.id,
            performedBy: 'Super Admin',
            metadata: {'backupId': backup.id, 'size': backup.sizeLabel},
          );
        }
      } else {
        Get.snackbar('Error', 'Could not open download URL.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to download: $e');
    }
  }

  void restoreSystem(String scope) {
    Get.defaultDialog(
      title: 'Create Restore Request',
      content: Column(
        children: [
          Text('Request to restore: $scope', textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text(
            'This will create a new version. Existing data will NOT be overwritten immediately.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      textConfirm: 'Create Request',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();

        final newRequest = RestoreRequestModel(
          id: '',
          scope: scope,
          timestamp: DateTime.now(),
          status: 'pending',
        );

        try {
          final docRef = await FirestoreHelper.systemRestoreRequests.add(
            newRequest.toJson(),
          );

          if (Get.isRegistered<AuditService>()) {
            AuditService.to.logAction(
              actionType: 'RESTORE_REQUEST_CREATED',
              targetType: 'SYSTEM',
              targetId: docRef.id,
              performedBy: 'Super Admin',
              metadata: {'scope': scope},
            );
          }

          Get.snackbar(
            'Success',
            'Restore Request Created',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar('Error', 'Failed to create request: $e');
        }
      },
    );
  }

  Future<void> deleteBackup(BackupSnapshotModel backup) async {
    try {
      // Delete from Firestore
      await FirestoreHelper.systemBackups.doc(backup.id).delete();

      // Try to delete from Storage too (non-critical)
      if (backup.downloadUrl != null && backup.downloadUrl!.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(backup.downloadUrl!);
          await ref.delete();
        } catch (_) {
          // Storage delete is best-effort
        }
      }

      Get.snackbar('Deleted', 'Backup removed successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete backup: $e');
    }
  }
}
