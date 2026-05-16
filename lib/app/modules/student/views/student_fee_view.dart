import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_fee_controller.dart';
import '../../../data/models/fee_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../widgets/glass_container.dart';
import 'student_fee_detail_view.dart';

class StudentFeeView extends GetView<StudentFeeController> {
  const StudentFeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fee Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlack, Color(0xFF1A1A1A)],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value && controller.fees.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentLime),
            );
          }

          if (controller.fees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No fee records found',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshFees(),
                  color: AppColors.accentLime,
                  backgroundColor: AppColors.cardDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
                    itemCount: controller.fees.length,
                    itemBuilder: (context, index) {
                      final fee = controller.fees[index];
                      return _buildFeeCard(fee);
                    },
                  ),
                ),
              ),
              _buildTotalDuesCard(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFeeCard(FeeRecordModel fee) {
    Color statusColor;
    switch (fee.status) {
      case FeeStatus.paid:
        statusColor = AppColors.accentLime;
        break;
      case FeeStatus.pending:
        statusColor = Colors.orangeAccent;
        break;
      case FeeStatus.overdue:
        statusColor = Colors.redAccent;
        break;
      case FeeStatus.processing:
        statusColor = Colors.cyanAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            controller.selectMonth(fee);
            Get.to(() => const StudentFeeDetailView());
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  fee.monthName.substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.monthName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PKR ${fee.totalAmount.toInt()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fee.status.name.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (fee.remainingAmount > 0 &&
                        fee.status != FeeStatus.processing)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _showPaymentSheet(fee),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentLime,
                              foregroundColor: AppColors.primaryBlack,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'PAY NOW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (fee.remainingAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'PKR ${fee.remainingAmount.toInt()} Dues',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(FeeRecordModel fee) {
    controller.selectMonth(fee);
    final amountCtrl = TextEditingController(
      text: fee.remainingAmount.toInt().toString(),
    );
    final remarksCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.primaryBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Monthly Fee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment for ${fee.monthName} ${fee.year}',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount Paid',
                labelStyle: const TextStyle(color: Colors.white38),
                prefixText: 'PKR ',
                prefixStyle: const TextStyle(color: AppColors.accentLime),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.accentLime),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Remarks (e.g., Bank Transfer ID)',
                labelStyle: const TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.accentLime),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountCtrl.text) ?? 0;
                  if (amt <= 0) {
                    Get.snackbar('Error', 'Invalid Amount');
                    return;
                  }
                  controller.submitPayment(amt, remarksCtrl.text);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: AppColors.primaryBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Submit for Review',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTotalDuesCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL OUTSTANDING',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PKR ${controller.totalDues.value.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (controller.totalDues.value > 0)
                ElevatedButton(
                  onPressed: () {
                    final firstPending = controller.fees.firstWhereOrNull(
                      (f) =>
                          f.remainingAmount > 0 &&
                          f.status != FeeStatus.processing,
                    );
                    if (firstPending != null) {
                      _showPaymentSheet(firstPending);
                    } else {
                      Get.snackbar(
                        'Processing',
                        'Your recent payment is still under review.',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLime,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'PAY NOW',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
