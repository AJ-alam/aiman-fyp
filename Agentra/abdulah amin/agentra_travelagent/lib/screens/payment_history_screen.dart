import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/side_navigation.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 5;
  late TabController _tabController;

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _earnings = [];
  List<Map<String, dynamic>> _subscriptions = [];
  List<Map<String, dynamic>> _refunds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchPaymentHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Not logged in. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}/api/earnings/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List raw = data['transactions'] ?? [];
        final all =
            raw.map((t) => Map<String, dynamic>.from(t)).toList();

        setState(() {
          _earnings =
              all.where((t) => t['type'] == 'EARNING').toList();
          _subscriptions =
              all.where((t) => t['type'] == 'SUBSCRIPTION').toList();
          _refunds =
              all.where((t) => t['type'] == 'REFUND').toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load payment history';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  double get _totalEarned => _earnings
      .where((t) => t['payoutStatus'] == 'PAID')
      .fold(0.0, (sum, t) => sum + ((t['amount'] ?? 0) as num).toDouble());

  double get _totalSubscriptions => _subscriptions
      .fold(0.0, (sum, t) => sum + ((t['amount'] ?? 0) as num).toDouble());

  double get _totalRefunded => _refunds
      .where((t) => t['payoutStatus'] == 'PAID')
      .fold(0.0, (sum, t) => sum + ((t['amount'] ?? 0) as num).toDouble());

  double get _totalCommission => _earnings
      .fold(0.0, (sum, t) => sum + ((t['commissionAmount'] ?? 0) as num).toDouble());

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }

  String _getPackageTitle(Map<String, dynamic> t) {
    final pkg = t['packageId'];
    if (pkg is Map) return pkg['title'] ?? 'Unknown Package';
    return 'Unknown Package';
  }

  String _getUserName(Map<String, dynamic> t) {
    final user = t['userId'];
    if (user is Map) return user['fullName'] ?? 'Unknown';
    return 'Unknown';
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
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment History',
                              style: AppTextStyles.headingMedium),
                          Text(
                            'Track all your financial transactions',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _fetchPaymentHistory,
                        icon: const Icon(Icons.refresh,
                            color: AppColors.primary),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
                // Body
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? _buildErrorState()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Summary Cards
                                  GridView.count(
                                    crossAxisCount: 4,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.6,
                                    children: [
                                      _buildSummaryCard(
                                        'Total Earned',
                                        'PKR ${_totalEarned.toStringAsFixed(0)}',
                                        Icons.trending_up,
                                        Colors.green,
                                      ),
                                      _buildSummaryCard(
                                        'Subscriptions Paid',
                                        'PKR ${_totalSubscriptions.toStringAsFixed(0)}',
                                        Icons.card_membership_outlined,
                                        Colors.blue,
                                      ),
                                      _buildSummaryCard(
                                        'Refunded Amount',
                                        'PKR ${_totalRefunded.toStringAsFixed(0)}',
                                        Icons.undo_outlined,
                                        Colors.orange,
                                      ),
                                      _buildSummaryCard(
                                        'Commission Paid',
                                        'PKR ${_totalCommission.toStringAsFixed(0)}',
                                        Icons.percent_outlined,
                                        Colors.purple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  // Tabs
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.04),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        TabBar(
                                          controller: _tabController,
                                          labelColor: AppColors.primary,
                                          unselectedLabelColor:
                                              AppColors.textTertiary,
                                          indicatorColor: AppColors.primary,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          labelStyle: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                          tabs: [
                                            Tab(
                                                text:
                                                    'Package Sales (${_earnings.length})'),
                                            Tab(
                                                text:
                                                    'Subscriptions (${_subscriptions.length})'),
                                            Tab(
                                                text:
                                                    'Refunds (${_refunds.length})'),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 500,
                                          child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                              _buildEarningsList(),
                                              _buildSubscriptionsList(),
                                              _buildRefundsList(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchPaymentHistory,
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
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7D848D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1E28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1B1E28),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF7D848D)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
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
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    if (_earnings.isEmpty) {
      return const Center(
          child: Text('No package sales yet',
              style: TextStyle(color: Color(0xFF7D848D))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _earnings.length,
      itemBuilder: (context, index) {
        final t = _earnings[index];
        final isPending = t['payoutStatus'] == 'PENDING';
        return _buildTransactionRow(
          icon: Icons.sell_outlined,
          iconColor: Colors.green,
          title: _getPackageTitle(t),
          subtitle:
              '${_getUserName(t)} • ${_formatDate(t['createdAt'])}',
          amount: 'PKR ${t['amount'] ?? 0}',
          status: isPending ? 'Pending' : 'Received',
          statusColor: isPending ? Colors.orange : Colors.green,
        );
      },
    );
  }

  Widget _buildSubscriptionsList() {
    if (_subscriptions.isEmpty) {
      return const Center(
          child: Text('No subscription payments yet',
              style: TextStyle(color: Color(0xFF7D848D))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final t = _subscriptions[index];
        final method = t['paymentMethod'] ?? 'N/A';
        return _buildTransactionRow(
          icon: Icons.card_membership_outlined,
          iconColor: Colors.blue,
          title: 'Subscription Payment',
          subtitle: '$method • ${_formatDate(t['createdAt'])}',
          amount: 'PKR ${t['amount'] ?? 0}',
          status: 'Paid',
          statusColor: Colors.green,
        );
      },
    );
  }

  Widget _buildRefundsList() {
    if (_refunds.isEmpty) {
      return const Center(
          child: Text('No refunds yet',
              style: TextStyle(color: Color(0xFF7D848D))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _refunds.length,
      itemBuilder: (context, index) {
        final t = _refunds[index];
        final isPending = t['payoutStatus'] == 'PENDING';
        return _buildTransactionRow(
          icon: Icons.undo_outlined,
          iconColor: Colors.orange,
          title: _getPackageTitle(t),
          subtitle:
              '${_getUserName(t)} • ${_formatDate(t['createdAt'])}',
          amount: 'PKR ${t['amount'] ?? 0}',
          status: isPending ? 'Pending' : 'Processed',
          statusColor: isPending ? Colors.orange : Colors.green,
        );
      },
    );
  }
}
