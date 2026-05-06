import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment.dart';
import 'auth_service.dart';

class PaymentService {
  static Future<List<Payment>> getPaymentHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.PAYMENT_HISTORY),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> paymentsJson = data['payments'] ?? data['data'] ?? [];
        return paymentsJson.map((json) => Payment.fromJson(json)).toList();
      }
    } catch (e) {
      print('🔴 Get payment history error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required String bookingId,
    required String paymentMethod,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse(ApiConfig.PAYMENT_INTENT),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('🔴 Create payment intent error: $e');
    }
    return null;
  }

  static Future<bool> processPayment({
    required String bookingId,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse(ApiConfig.PROCESS_PAYMENT),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'paymentDetails': paymentDetails,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('🔴 Process payment error: $e');
      return false;
    }
  }

  static Future<List<String>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.PAYMENT_METHODS),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['methods'] ?? ['CARD', 'JAZZCASH', 'EASYPAISA', 'BANK']);
      }
    } catch (e) {
      print('🔴 Get payment methods error: $e');
    }
    return ['CARD', 'JAZZCASH', 'EASYPAISA', 'BANK'];
  }
}
