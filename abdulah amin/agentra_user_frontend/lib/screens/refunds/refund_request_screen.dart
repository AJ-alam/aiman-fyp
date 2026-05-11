import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../models/booking.dart';
import '../../config/api_config.dart';

class RefundRequestScreen extends StatefulWidget {
  const RefundRequestScreen({super.key});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingBookings = true;

  List<Booking> _bookings = [];
  String? _selectedBookingId;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoadingBookings = true);
    final bookings = await BookingService.getMyBookings();
    if (mounted) {
      setState(() {
        // Only show paid/confirmed bookings that haven't been refunded
        _bookings = bookings
            .where((b) =>
                b.paymentStatus == 'PAID' &&
                b.status.toLowerCase() == 'cancelled')
            .toList();
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _submitRefund() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.BASE_URL}/refund/request'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'bookingId': _selectedBookingId,
          'reason': _reasonController.text.trim(),
        }),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pushReplacementNamed(context, '/refund-success');
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to submit refund request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Refund',
          style: AppTextStyles.headingSmall,
        ),
      ),
      body: SafeArea(
        child: _isLoadingBookings
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Booking',
                        style: AppTextStyles.headingSmall,
                      ),
                      const SizedBox(height: 12),
                      if (_bookings.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radius),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: const Text(
                            'No eligible bookings found for refund.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedBookingId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          hint: const Text('Select a booking'),
                          items: _bookings.map((b) {
                            return DropdownMenuItem<String>(
                              value: b.id,
                              child: Text(
                                '${b.packageTitle} — PKR ${b.totalPrice.toStringAsFixed(0)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedBookingId = val),
                        ),
                      const SizedBox(height: 24),
                      CustomInput(
                        label: 'Reason for Refund',
                        controller: _reasonController,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason';
                          }
                          return null;
                        },
                      ),
                      const Spacer(),
                      CustomButton(
                        text: 'Submit Request',
                        onPressed: _bookings.isEmpty ? null : _submitRefund,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
