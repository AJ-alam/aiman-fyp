import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class RefundRequestScreen extends StatefulWidget {
  const RefundRequestScreen({super.key});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  // Mode: 'list' shows cancelled bookings, 'form' shows refund form for a booking
  String _mode = 'list';
  Map<String, dynamic>? _selectedBooking;

  bool _isLoadingBookings = true;
  bool _isSubmitting = false;
  String? _error;
  List<Map<String, dynamic>> _cancelledBookings = [];
  List<Map<String, dynamic>> _myRefunds = [];

  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingBookings = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Please log in to view refunds';
          _isLoadingBookings = false;
        });
        return;
      }

      // Fetch cancelled bookings (eligible for refund)
      final bookingsResponse = await http.get(
        Uri.parse(ApiConfig.MY_BOOKINGS),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Fetch existing refund requests
      final refundsResponse = await http.get(
        Uri.parse(ApiConfig.MY_REFUNDS),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (bookingsResponse.statusCode == 200) {
        final data = jsonDecode(bookingsResponse.body);
        final List raw = data['bookings'] ?? [];
        // Only show cancelled bookings that haven't been refunded yet
        setState(() {
          _cancelledBookings = raw
              .map((b) => Map<String, dynamic>.from(b))
              .where((b) =>
                  b['status'] == 'CANCELLED' && b['refundStatus'] == 'NONE')
              .toList();
        });
      }

      if (refundsResponse.statusCode == 200) {
        final data = jsonDecode(refundsResponse.body);
        final List raw = data['refundRequests'] ?? [];
        setState(() {
          _myRefunds =
              raw.map((r) => Map<String, dynamic>.from(r)).toList();
        });
      }

      setState(() => _isLoadingBookings = false);
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoadingBookings = false;
      });
    }
  }

  Future<void> _submitRefund() async {
    if (_selectedBooking == null) return;
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason for the refund'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse(ApiConfig.REQUEST_REFUND),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookingId': _selectedBooking!['_id'],
          'reason': _reasonController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/refund-success');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to submit refund'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getPackageTitle(Map<String, dynamic> booking) {
    final pkg = booking['packageId'];
    if (pkg is Map) return pkg['title'] ?? 'Unknown Package';
    return 'Unknown Package';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
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
          onPressed: () {
            if (_mode == 'form') {
              setState(() {
                _mode = 'list';
                _selectedBooking = null;
                _reasonController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _mode == 'form' ? 'Request Refund' : 'My Refunds',
          style: AppTextStyles.headingSmall,
        ),
        actions: [
          if (_mode == 'list')
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _fetchData,
            ),
        ],
      ),
      body: _isLoadingBookings
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _mode == 'list'
                  ? _buildListView()
                  : _buildFormView(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cancelled bookings eligible for refund
            Text(
              'Cancelled Bookings',
              style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a cancelled booking to request a refund',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (_cancelledBookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radius),
                ),
                child: const Center(
                  child: Text(
                    'No cancelled bookings eligible for refund',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...(_cancelledBookings.map((b) => _buildBookingCard(b))),
            const SizedBox(height: 32),
            // Existing refund requests
            if (_myRefunds.isNotEmpty) ...[
              Text(
                'My Refund Requests',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ...(_myRefunds.map((r) => _buildRefundStatusCard(r))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final packageTitle = _getPackageTitle(booking);
    final amount = booking['totalAmount'] ?? 0;
    final travelDate = _formatDate(booking['travelDate']?.toString());

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBooking = booking;
          _mode = 'form';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cancel_outlined,
                  color: Colors.red, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageTitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Travel: $travelDate • PKR $amount',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundStatusCard(Map<String, dynamic> refund) {
    final packageTitle = _getPackageTitle(refund);
    final amount = refund['totalAmount'] ?? 0;
    final status = refund['refundStatus'] ?? 'REQUESTED';
    Color statusColor;
    switch (status) {
      case 'APPROVED':
        statusColor = Colors.green;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.undo_outlined, color: statusColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageTitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR $amount',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    final packageTitle = _getPackageTitle(_selectedBooking!);
    final amount = _selectedBooking!['totalAmount'] ?? 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Details', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageTitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: PKR $amount',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'Reason for Refund',
              controller: _reasonController,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter reason';
                }
                return null;
              },
            ),
            const Spacer(),
            CustomButton(
              text: 'Submit Request',
              onPressed: _submitRefund,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
