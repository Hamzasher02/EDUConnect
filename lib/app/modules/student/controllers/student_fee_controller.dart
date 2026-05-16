import 'package:get/get.dart';
import '../../../data/models/fee_model.dart';
import '../../../services/student_fee_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/school_data_service.dart';

class StudentFeeController extends GetxController {
  final _service = Get.find<StudentFeeService>();
  final _schoolDataService = Get.find<SchoolDataService>();
  final _authService = Get.find<AuthService>();

  final fees = <FeeRecordModel>[].obs;
  final totalDues = 0.0.obs;
  final isLoading = false.obs;
  final isOffline = false.obs;

  final selectedMonthFee = Rxn<FeeRecordModel>();

  String get _studentId => _authService.session.value?.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    isOffline.value = _schoolDataService.isOffline.value;
    ever(_schoolDataService.isOffline, (val) => isOffline.value = val);
    loadFees();
  }

  Future<void> loadFees() async {
    try {
      isLoading.value = true;
      final data = await _service.getMonthlyFees(_studentId);
      fees.assignAll(data);

      final dues = await _service.calculateTotalDues(_studentId);
      totalDues.value = dues;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void selectMonth(FeeRecordModel fee) {
    selectedMonthFee.value = fee;
  }

  Future<void> refreshFees() async {
    if (isOffline.value) {
      Get.snackbar('Offline', 'Cannot refresh while offline');
      return;
    }
    await loadFees();
  }

  Future<void> submitPayment(double amount, String remarks) async {
    final fee = selectedMonthFee.value;
    if (fee == null) return;

    try {
      isLoading.value = true;
      final session = _authService.session.value;
      if (session == null) return;

      await _schoolDataService.submitFeePaymentRequest(
        schoolId: session.schoolId ?? '',
        studentId: session.userId,
        feeRecordId: fee.id,
        amount: amount,
        proofImageUrl: '', // Optional for now
        remarks: remarks,
      );

      Get.snackbar('Success', 'Payment submitted for review');
      await loadFees();
      // Update selected month if it matches the one we just updated
      selectedMonthFee.value =
          fees.firstWhereOrNull((f) => f.id == fee.id) ?? fee;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
