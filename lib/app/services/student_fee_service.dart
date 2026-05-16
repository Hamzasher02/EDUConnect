import 'package:get/get.dart';
import 'auth_service.dart';
import 'school_data_service.dart';
import '../data/models/fee_model.dart';
import '../data/enums/app_enums.dart';

class StudentFeeService extends GetxService {
  final _authService = Get.find<AuthService>();
  final _schoolDataService = Get.find<SchoolDataService>();

  void _validateSession(String studentId) {
    final session = _authService.session.value;
    if (session == null || session.role != UserRole.student) {
      throw 'Unauthorized access';
    }
    if (session.userId != studentId) {
      throw 'Ownership validation failed';
    }
    // In production, we'd check if student is active via StudentModel but here we trust the session/dashboard check
  }

  Future<List<FeeRecordModel>> getMonthlyFees(String studentId) async {
    _validateSession(studentId);

    final allFees = _schoolDataService.getStudentFees(studentId);
    // Sort by Year then Month Descending
    allFees.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return allFees.cast<FeeRecordModel>();
  }

  Future<double> calculateTotalDues(String studentId) async {
    _validateSession(studentId);

    final List<FeeRecordModel> allFees = await getMonthlyFees(studentId);
    return allFees.fold<double>(
      0.0,
      (double sum, item) => sum + item.remainingAmount,
    );
  }

  Future<List<FeeTransactionModel>> getFeeHistory(
    String studentId,
    int month,
    int year,
  ) async {
    _validateSession(studentId);

    final allFees = await getMonthlyFees(studentId);
    final selectedMonth = allFees.firstWhereOrNull(
      (f) => f.month == month && f.year == year,
    );

    return selectedMonth?.transactions ?? [];
  }
}
