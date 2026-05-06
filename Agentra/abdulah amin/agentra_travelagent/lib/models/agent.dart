class Agent {
  final String id;
  final String fullName;
  final String businessName;
  final String email;
  final String phone;
  final String cnic;
  final String? profileImage;
  final String? bio;
  final String? location;
  final String? refundPolicy;
  final String? cancellationPolicy;
  final String role;
  final bool isVerified;
  final String status; // Added status field
  final String? rejectionReason; // Added rejection reason
  final int totalPackages;
  final int totalBookings;
  final double averageRating;

  Agent({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.cnic,
    this.profileImage,
    this.bio,
    this.location,
    this.refundPolicy,
    this.cancellationPolicy,
    this.role = 'AGENT',
    this.isVerified = false,
    this.status = 'PENDING_APPROVAL', // Default status
    this.rejectionReason,
    this.totalPackages = 0,
    this.totalBookings = 0,
    this.averageRating = 0.0,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      businessName: json['businessName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      cnic: json['cnic'] ?? '',
      profileImage: json['profileImage'],
      bio: json['bio'],
      location: json['location'],
      refundPolicy: json['refundPolicy'],
      cancellationPolicy: json['cancellationPolicy'],
      role: json['role'] ?? 'AGENT',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? 'PENDING_APPROVAL', // Parse status
      rejectionReason: json['rejectionReason'], // Parse rejection reason
      totalPackages: json['totalPackages'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'profileImage': profileImage,
      'bio': bio,
      'location': location,
      'refundPolicy': refundPolicy,
      'cancellationPolicy': cancellationPolicy,
    };
  }
}