import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking.dart';
import 'auth_service.dart';

class BookingService {
  static Future<List<Booking>> getMyBookings() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      print('🔵 Fetching my bookings');

      final response = await http.get(
        Uri.parse(ApiConfig.MY_BOOKINGS),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('🟢 Bookings Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> bookingsJson = data['bookings'] ?? data['data'] ?? [];
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (e) {
      print('🔴 Get bookings error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> createBooking({
    required String packageId,
    required int seats,
    required String travelDate,
    required String paymentMethod,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Please log in to create a booking'
        };
      }

      print('🔵 Creating booking for package: $packageId');
      print('🔵 Seats: $seats, Date: $travelDate, Payment: $paymentMethod');

      final response = await http.post(
        Uri.parse(ApiConfig.BOOKINGS),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'packageId': packageId,
          'seats': seats,
          'travelDate': travelDate,
          'paymentMethod': paymentMethod,
        }),
      );

      print('🟢 Create Booking Status: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Booking created successfully!'
        };
      } else {
        // Parse error message from backend
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to create booking'
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to create booking. Status: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print('🔴 Create booking error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.'
      };
    }
  }

  static Future<bool> cancelBooking(String bookingId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.BOOKINGS}/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('🔴 Cancel booking error: $e');
      return false;
    }
  }
}
