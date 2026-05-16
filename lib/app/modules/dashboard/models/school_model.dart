class SchoolModel {
  String id;
  String name;
  String address;
  String contactNumber;
  String adminEmail;
  String? adminUid;
  String? adminPassword;
  String principalName;
  DateTime registrationDate;
  String status; // 'active', 'pending', 'restricted', 'removed'
  int studentCount;
  int teacherCount;
  int adminCount;
  String category; // e.g., 'Excellent', 'Good', 'Improving'
  double rankingScore;
  String? logoUrl;
  bool isVisibleOnRanking;

  SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.adminEmail,
    this.adminUid,
    this.adminPassword,
    required this.principalName,
    required this.registrationDate,
    required this.status,
    this.studentCount = 0,
    this.teacherCount = 0,
    this.adminCount = 0,
    this.category = 'Not Evaluated',
    this.rankingScore = 0.0,
    this.logoUrl,
    this.isVisibleOnRanking = true,
  });

  double get subscriptionFee => studentCount * 15.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'contactNumber': contactNumber,
    'adminEmail': adminEmail,
    'adminUid': adminUid,
    'adminPassword': adminPassword,
    'principalName': principalName,
    'registrationDate': registrationDate.toIso8601String(),
    'status': status,
    'studentCount': studentCount,
    'teacherCount': teacherCount,
    'adminCount': adminCount,
    'category': category,
    'rankingScore': rankingScore,
    'logoUrl': logoUrl,
    'isVisibleOnRanking': isVisibleOnRanking,
  };

  factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    contactNumber: json['contactNumber'] ?? '',
    adminEmail: json['adminEmail'] ?? '',
    adminUid: json['adminUid'],
    adminPassword: json['adminPassword'],
    principalName: json['principalName'] ?? '',
    registrationDate: json['registrationDate'] != null
        ? (json['registrationDate'] is String
              ? DateTime.parse(json['registrationDate'])
              : (json['registrationDate'] as dynamic).toDate())
        : DateTime.now(),
    status: json['status'] ?? 'pending',
    studentCount: (json['studentCount'] as num? ?? 0).toInt(),
    teacherCount: (json['teacherCount'] as num? ?? 0).toInt(),
    adminCount: (json['adminCount'] as num? ?? 0).toInt(),
    category: json['category'] ?? 'Not Evaluated',
    rankingScore: (json['rankingScore'] as num? ?? 0.0).toDouble(),
    logoUrl: json['logoUrl'],
    isVisibleOnRanking: json['isVisibleOnRanking'] ?? true,
  );
}
