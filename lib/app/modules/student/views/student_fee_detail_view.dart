import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../controllers/student_fee_controller.dart';
import '../../../data/models/fee_model.dart';
import '../../../data/enums/app_enums.dart';
import '../../../widgets/glass_container.dart';

class StudentFeeDetailView extends GetView<StudentFeeController> {
  const StudentFeeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(
          () => Text(
            'Details - ${controller.selectedMonthFee.value?.monthName ?? ""}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          final fee = controller.selectedMonthFee.value;
          if (fee == null) return const SizedBox();

          return Column(
            children: [
              const SizedBox(height: 100),
              _buildMonthSummary(fee),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'TRANSACTION HISTORY',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: fee.transactions.isEmpty
                    ? _buildEmptyHistory()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: fee.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = fee.transactions[index];
                          return _buildTransactionTile(tx);
                        },
                      ),
              ),
              if (fee.remainingAmount > 0)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _showPaymentSheet(fee),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLime,
                        foregroundColor: AppColors.primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Record Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showPaymentSheet(FeeRecordModel fee) {
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
              'Submit Payment Proof',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the amount you paid for ${fee.monthName}',
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
                labelText: 'Remarks / Transaction ID',
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
                  'Confirm Submission',
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

  Widget _buildMonthSummary(FeeRecordModel fee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSummaryRow(
              'Total Monthly Fee',
              'PKR ${fee.totalAmount.toInt()}',
              isBold: true,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Amount Paid',
              'PKR ${fee.paidAmount.toInt()}',
              color: AppColors.accentLime,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Remaining Balance',
              'PKR ${fee.remainingAmount.toInt()}',
              color: fee.remainingAmount > 0
                  ? Colors.redAccent
                  : Colors.white60,
            ),
            const Divider(color: Colors.white10, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (fee.status == FeeStatus.paid
                                ? AppColors.accentLime
                                : Colors.orangeAccent)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fee.status.name.toUpperCase(),
                    style: TextStyle(
                      color: fee.status == FeeStatus.paid
                          ? AppColors.accentLime
                          : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(FeeTransactionModel tx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PKR ${tx.amount.toInt()}',
                  style: const TextStyle(
                    color: AppColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('MMM d, y').format(tx.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 6),
                Text(
                  tx.receiptId != null
                      ? 'Receipt ID: ${tx.receiptId}'
                      : 'Manual Payment',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            if (tx.remarks != null) ...[
              const SizedBox(height: 4),
              Text(
                tx.remarks!,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: Colors.white.withValues(alpha: 0.05),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions recorded yet.',
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}
