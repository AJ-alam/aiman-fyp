import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

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
          'Payment History',
          style: AppTextStyles.headingSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSummaryCard('Total Paid', 'PKR 45,000', AppColors.primary),
            const SizedBox(height: 16),
            _buildSummaryCard('Refunded Amount', 'PKR 5,000', AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.headingMedium.copyWith(
              color: color,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
