class Complaint {
  final String id;
  final String userId;
  final String bookingId;
  final String subject;
  final String description;
  final String status;
  final String? response;
  final String? adminResponse; // maps to ownerResponse from backend
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.subject,
    required this.description,
    required this.status,
    this.response,
    this.adminResponse,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is Map ? (json['userId']['_id'] ?? '') : (json['userId'] ?? ''),
      bookingId: json['bookingId'] is Map ? (json['bookingId']['_id'] ?? '') : (json['bookingId'] ?? ''),
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      response: json['response'],
      adminResponse: json['ownerResponse'] ?? json['adminResponse'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'bookingId': bookingId,
      'subject': subject,
      'description': description,
      'status': status,
      'response': response,
      'ownerResponse': adminResponse,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getStatusColor() {
    switch (status.toUpperCase()) {
      case 'RESOLVED':
        return 'green';
      case 'OPEN':
        return 'red';
      case 'IN_PROGRESS':
        return 'orange';
      default:
        return 'blue';
    }
  }
}