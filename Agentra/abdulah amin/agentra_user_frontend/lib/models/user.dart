class User {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? bio;
  final String? profileImage;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.bio,
    this.profileImage,
    this.role = 'user',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'bio': bio,
      'profileImage': profileImage,
      'role': role,
    };
  }
}
