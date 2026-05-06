class Complaint {
  final String id;
  final String userId;
  final String bookingId;
  final String subject;
  final String description;
  final String status;
  final String? response;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.subject,
    required this.description,
    required this.status,
    this.response,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      response: json['response'],
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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'green';
      case 'pending':
        return 'orange';
      case 'closed':
        return 'grey';
      default:
        return 'blue';
    }
  }
}