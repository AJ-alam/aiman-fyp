import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isCancelling = false;

  Future<void> _cancelBooking() async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cancel Booking?',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Booking for ${widget.booking.packageTitle}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Reason for cancellation (optional)',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius),
                        ),
                      ),
                      child: Text(
                        'Keep',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius),
                        ),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    final success =
        await BookingService.cancelBooking(widget.booking.id);
    if (mounted) {
      setState(() => _isCancelling = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Booking cancelled. Refund request submitted to agent.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // signal refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final bool canCancel = booking.status.toLowerCase() == 'confirmed' ||
        booking.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image
                Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        image: (booking.packageImage != null &&
                                booking.packageImage!.isNotEmpty)
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                    booking.packageImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (booking.packageImage == null ||
                              booking.packageImage!.isEmpty)
                          ? const Center(
                              child: Icon(Icons.landscape,
                                  size: 80, color: Colors.white54))
                          : null,
                    ),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Text(
                        booking.packageTitle,
                        style: AppTextStyles.headingMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                // Booking Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        title: 'Booking Details',
                        children: [
                          _row('Booking ID',
                              '#${booking.id.length > 8 ? booking.id.substring(booking.id.length - 8) : booking.id}'),
                          _row('Travel Date', booking.travelDate),
                          _row('Seats', '${booking.seats}'),
                          _row('Total Paid',
                              'PKR ${booking.totalPrice.toStringAsFixed(0)}'),
                          _row('Payment Method', booking.paymentMethod),
                          _row('Status', booking.status.toUpperCase(),
                              valueColor:
                                  _statusColor(booking.status)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Cancellation policy info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cancellation Policy',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Cancel before 7 days: Full refund\n'
                              '• Cancel 3–7 days before: 50% refund\n'
                              '• Cancel within 3 days: No refund',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Cancel Button
          if (canCancel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: 'Cancel Booking',
                    backgroundColor: AppColors.error,
                    isLoading: _isCancelling,
                    onPressed: _isCancelling ? null : _cancelBooking,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
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
          Text(title,
              style: AppTextStyles.headingSmall.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.orange;
    }
  }
}
