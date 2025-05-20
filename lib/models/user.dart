class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? department;
  final String? year;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.department,
    this.year,
    this.isAdmin = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a user from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      department: json['department'],
      year: json['year'],
      isAdmin: json['isAdmin'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'department': department,
      'year': year,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of the user with updated fields
  User copyWith({
    String? name,
    String? avatarUrl,
    String? department,
    String? year,
    bool? isAdmin,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      year: year ?? this.year,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
