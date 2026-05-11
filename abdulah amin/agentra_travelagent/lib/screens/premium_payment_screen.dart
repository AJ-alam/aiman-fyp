import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/side_navigation.dart';
import '../widgets/custom_input.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class PremiumPaymentScreen extends StatefulWidget {
  const PremiumPaymentScreen({Key? key}) : super(key: key);

  @override
  State<PremiumPaymentScreen> createState() => _PremiumPaymentScreenState();
}

class _PremiumPaymentScreenState extends State<PremiumPaymentScreen> {
  int _selectedNavIndex = 6;
  int _selectedPlan = 0;
  int _currentStep = 0; // 0 = Select Plan, 1 = Payment
  bool _isLoading = true;
  bool _isAlreadyPro = false;
  String _currentPlan = '';

  final _jazzcashNumberController = TextEditingController();
  final _cnicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}/subscription/current'),
        headers: {'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sub = data['subscription'];
        if (mounted) {
          setState(() {
            _isAlreadyPro = sub['isActive'] ?? false;
            _currentPlan = sub['plan'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Monthly',
      'price': 1000,
      'period': 'month',
      'saving': null,
      'features': [
        'Promote your packages',
        'Email + in-app promotions',
        'AI Chatbot for customer inquiries',
        'Cancel any time',
      ],
    },
    {
      'name': 'Annual',
      'price': 10000,
      'period': 'year',
      'saving': 'Save PKR 2,000',
      'features': [
        'Promote your packages',
        'Email + in-app promotions',
        'AI Chatbot for customer inquiries',
        'Cancel any time',
        'Priority support',
        '2 months free',
      ],
    },
  ];

  @override
  void dispose() {
    _jazzcashNumberController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  void _handlePayNow() async {
    // Validate inputs using PaymentService
    final validation = PaymentService.validatePaymentDetails(
      mobileNumber: _jazzcashNumberController.text,
      cnicLastSix: _cnicController.text,
    );

    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.errors.values.first),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Simulate JazzCash payment
      final result = await PaymentService.processPayment(
        mobileNumber: _jazzcashNumberController.text,
        cnicLastSix: _cnicController.text,
        amount: _plans[_selectedPlan]['price'].toDouble(),
      );

      if (!result.success) {
        setState(() => _isLoading = false);
        _showFailureDialog(result.errorCode!, result.errorMessage!);
        return;
      }

      // Step 2: Save subscription to backend
      final planName =
          _plans[_selectedPlan]['name'].toString().toUpperCase(); // MONTHLY | YEARLY
      final token = await AuthService.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${ApiConfig.BASE_URL}/subscription/subscribe'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'plan': planName,
            'paymentMethod': 'JAZZCASH',
          }),
        );
      }

      setState(() => _isLoading = false);
      _showSuccessDialog(result.bookingReference!);
    } catch (e) {
      setState(() => _isLoading = false);
      _showFailureDialog(
          'NETWORK_ERROR', 'An unexpected error occurred. Please try again.');
    }
  }

  void _showSuccessDialog(String bookingReference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(40),
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are now on the ${_plans[_selectedPlan]['name']} Premium Plan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking Reference: $bookingReference',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                        context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go to Subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailureDialog(String errorCode, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(40),
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Failed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error Code: $errorCode',
                style: const TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          SideNavigation(
            selectedIndex: _selectedNavIndex,
            onItemSelected: (index) =>
                setState(() => _selectedNavIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom:
                          BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (_currentStep == 1) {
                            setState(() => _currentStep = 0);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _currentStep == 0
                            ? 'Premium Subscription'
                            : 'Payment',
                        style: AppTextStyles.headingMedium,
                      ),
                      const Spacer(),
                      // Step indicator
                      Row(
                        children: [
                          _buildStepIndicator(1, 'Select Plan',
                              _currentStep >= 0),
                          Container(
                            width: 40,
                            height: 2,
                            color: _currentStep >= 1
                                ? AppColors.primary
                                : const Color(0xFFEEEEEE),
                          ),
                          _buildStepIndicator(
                              2, 'Payment', _currentStep >= 1),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: _isAlreadyPro
                                  ? _buildAlreadyProStatus()
                                  : (_currentStep == 0
                                      ? _buildSelectPlanStep()
                                      : _buildPaymentStep()),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPlanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B1E28),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose the plan that works best for you',
          style: TextStyle(color: Color(0xFF7D848D), fontSize: 16),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            _plans.length,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: index == 0 ? 16 : 0,
                    left: index == 1 ? 16 : 0),
                child: _buildPlanCard(index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue with ${_plans[_selectedPlan]['name']} Plan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final bool isSelected = _selectedPlan == index;
    final bool isAnnual = index == 1;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFEEEEEE),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Annual badge
            if (isAnnual)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Save PKR 2,000',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.amber,
                  ),
                ),
              ),
            if (isAnnual) const SizedBox(height: 12),
            Text(
              plan['name'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF1B1E28),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ',
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF7D848D),
                  ),
                ),
                Text(
                  '${plan['price']}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
                Text(
                  ' PKR/${plan['period']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF7D848D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            ...(plan['features'] as List<String>).map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPlan = index;
                    _currentStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.white
                      : AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Subscribe',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    final plan = _plans[_selectedPlan];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order summary
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan['name']} Premium Plan',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    Text(
                      'PKR ${plan['price']} / ${plan['period']}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Payment form
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // JazzCash header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payment,
                        color: Color(0xFFFF0000), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay with JazzCash',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1E28),
                        ),
                      ),
                      Text(
                        'Secure & instant payment',
                        style: TextStyle(
                          color: Color(0xFF7D848D),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              CustomInput(
                label: 'JazzCash Mobile Number',
                controller: _jazzcashNumberController,
                hint: 'e.g., 03001234567',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              CustomInput(
                label: 'Last 6 digits of your CNIC',
                controller: _cnicController,
                hint: 'e.g., 123456',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const Text(
                '🔒 Your payment is secured with 256-bit SSL encryption',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7D848D),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pay PKR ${plan['price']} Now',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlreadyProStatus() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
          ),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.orange.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium,
                    color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pro Premium Status',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE: ${_currentPlan == 'YEARLY' ? 'Annual Plan' : 'Monthly Plan'}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You have full access to all AI tools and premium features. Your subscription is active and working perfectly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Manage Subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFEEEEEE),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF7D848D),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive
                ? AppColors.primary
                : const Color(0xFF7D848D),
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}