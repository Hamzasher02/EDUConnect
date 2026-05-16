class ParentModel {
  final String id;
  final String parentCnic;
  final String name;
  final String email;
  final String contactNumber;
  final String? address;
  final List<String> linkedStudentIds;
  bool isPasswordCreated;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ParentModel({
    required this.id,
    required this.parentCnic,
    required this.name,
    required this.email,
    required this.contactNumber,
    this.address,
    this.linkedStudentIds = const [],
    this.isPasswordCreated = false,
    required this.createdAt,
    this.updatedAt,
  });

  ParentModel copyWith({
    String? id,
    String? parentCnic,
    String? name,
    String? email,
    String? contactNumber,
    String? address,
    List<String>? linkedStudentIds,
    bool? isPasswordCreated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentModel(
      id: id ?? this.id,
      parentCnic: parentCnic ?? this.parentCnic,
      name: name ?? this.name,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      linkedStudentIds: linkedStudentIds ?? this.linkedStudentIds,
      isPasswordCreated: isPasswordCreated ?? this.isPasswordCreated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentCnic': parentCnic,
    'name': name,
    'email': email,
    'contactNumber': contactNumber,
    'address': address,
    'linkedStudentIds': linkedStudentIds,
    'isPasswordCreated': isPasswordCreated,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'],
      parentCnic: json['parentCnic'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'],
      linkedStudentIds: json['linkedStudentIds'] != null
          ? List<String>.from(json['linkedStudentIds'])
          : [],
      isPasswordCreated: json['isPasswordCreated'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
