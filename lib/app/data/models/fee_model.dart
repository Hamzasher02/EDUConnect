import '../enums/app_enums.dart';

class FeeTransactionModel {
  final String id;
  final double amount;
  final DateTime date; // Unified from paidAt/date
  final String? remarks;
  final String? receiptId; // From student model
  final String? proofImageUrl;
  final TransactionStatus status;

  // Constructor capable of handling both legacy inputs if needed,
  // but we'll standardize on these fields.
  FeeTransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    this.remarks,
    this.receiptId,
    this.proofImageUrl,
    this.status = TransactionStatus.successful,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'remarks': remarks,
    'receiptId': receiptId,
    'proofImageUrl': proofImageUrl,
    'status': status.name,
  };

  factory FeeTransactionModel.fromJson(Map<String, dynamic> json) {
    return FeeTransactionModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      remarks: json['remarks'],
      receiptId: json['receiptId'],
      proofImageUrl: json['proofImageUrl'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.successful,
      ),
    );
  }

  FeeTransactionModel copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? remarks,
    String? receiptId,
    String? proofImageUrl,
    TransactionStatus? status,
  }) {
    return FeeTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      remarks: remarks ?? this.remarks,
      receiptId: receiptId ?? this.receiptId,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      status: status ?? this.status,
    );
  }
}

class FeeRecordModel {
  final String id;
  final String schoolId;
  final String studentId;
  final int month; // 1-12
  final int year;
  final FeeStatus status;
  final double totalAmount; // duesAmount/totalFee
  final double paidAmount;
  final String? remarks;
  final DateTime updatedAt;
  final bool isEditable;
  final List<FeeTransactionModel> transactions;

  FeeRecordModel({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.month,
    required this.year,
    required this.status,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.remarks,
    required this.updatedAt,
    this.isEditable = true,
    List<FeeTransactionModel>? transactions,
  }) : transactions = transactions ?? [];

  double get remainingAmount => totalAmount - paidAmount;
  double get duesAmount => totalAmount; // Alias for backward compatibility

  String get monthName {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return 'Unknown';
    return months[month - 1];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolId': schoolId,
    'studentId': studentId,
    'month': month,
    'year': year,
    'status': status.name,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'remarks': remarks,
    'updatedAt': updatedAt.toIso8601String(),
    'isEditable': isEditable,
    'transactions': transactions.map((x) => x.toJson()).toList(),
  };

  factory FeeRecordModel.fromJson(Map<String, dynamic> json) {
    return FeeRecordModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      studentId: json['studentId'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      status: FeeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FeeStatus.pending,
      ),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      remarks: json['remarks'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isEditable: json['isEditable'] ?? true,
      transactions: (json['transactions'] as List?)
          ?.map((x) => FeeTransactionModel.fromJson(x))
          .toList(),
    );
  }

  FeeRecordModel copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    int? month,
    int? year,
    FeeStatus? status,
    double? totalAmount,
    double? paidAmount,
    String? remarks,
    DateTime? updatedAt,
    bool? isEditable,
    List<FeeTransactionModel>? transactions,
  }) {
    return FeeRecordModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      month: month ?? this.month,
      year: year ?? this.year,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remarks: remarks ?? this.remarks,
      updatedAt: updatedAt ?? this.updatedAt,
      isEditable: isEditable ?? this.isEditable,
      transactions: transactions ?? this.transactions,
    );
  }
}
