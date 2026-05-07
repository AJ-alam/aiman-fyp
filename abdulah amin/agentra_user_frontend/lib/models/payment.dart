class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'CARD',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getMethodIcon() {
    switch (paymentMethod.toUpperCase()) {
      case 'CARD':
        return '💳';
      case 'JAZZCASH':
        return '📱';
      case 'EASYPAISA':
        return '📲';
      case 'BANK':
        return '🏦';
      default:
        return '💰';
    }
  }
}