import 'package:flutter/material.dart';
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

  // Dummy data
  final List<Map<String, dynamic>> _subscriptionPayments = [
    {
      'plan': 'Premium Plan',
      'date': '1 Mar 2026',
      'amount': 5000,
      'status': 'Paid',
      'method': 'JazzCash',
    },
    {
      'plan': 'Premium Plan',
      'date': '1 Feb 2026',
      'amount': 5000,
      'status': 'Paid',
      'method': 'EasyPaisa',
    },
    {
      'plan': 'Basic Plan',
      'date': '1 Jan 2026',
      'amount': 2000,
      'status': 'Paid',
      'method': 'Bank Transfer',
    },
  ];

  final List<Map<String, dynamic>> _packageSales = [
    {
      'package': 'Nathia Gali Adventure',
      'customer': 'Ahmed Khan',
      'date': '10 Mar 2026',
      'amount': 15000,
      'commission': 1500,
      'net': 13500,
      'status': 'Received',
    },
    {
      'package': 'Lahore City Tour',
      'customer': 'Sara Ali',
      'date': '8 Mar 2026',
      'amount': 8000,
      'commission': 800,
      'net': 7200,
      'status': 'Received',
    },
    {
      'package': 'Hunza Valley Trip',
      'customer': 'Usman Tariq',
      'date': '5 Mar 2026',
      'amount': 25000,
      'commission': 2500,
      'net': 22500,
      'status': 'Pending',
    },
    {
      'package': 'Swat Valley Tour',
      'customer': 'Ayesha Malik',
      'date': '1 Mar 2026',
      'amount': 12000,
      'commission': 1200,
      'net': 10800,
      'status': 'Received',
    },
  ];

  final List<Map<String, dynamic>> _refunds = [
    {
      'package': 'Hunza Valley Trip',
      'customer': 'Ali Hassan',
      'date': '12 Mar 2026',
      'amount': 25000,
      'reason': 'Trip cancelled by customer',
      'status': 'Processed',
    },
    {
      'package': 'Nathia Gali Adventure',
      'customer': 'Fatima Zahra',
      'date': '7 Mar 2026',
      'amount': 15000,
      'reason': 'Weather conditions',
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Summary calculations
  double get _totalEarned => _packageSales
      .where((s) => s['status'] == 'Received')
      .fold(0.0, (sum, s) => sum + (s['net'] as int));

  double get _totalSubscriptions => _subscriptionPayments
      .fold(0.0, (sum, s) => sum + (s['amount'] as int));

  double get _totalRefunded => _refunds
      .where((r) => r['status'] == 'Processed')
      .fold(0.0, (sum, r) => sum + (r['amount'] as int));

  double get _totalCommission => _packageSales
      .fold(0.0, (sum, s) => sum + (s['commission'] as int));

  double get _netAmount =>
      _totalEarned - _totalSubscriptions - _totalRefunded - _totalCommission;

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
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Report download coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.download_outlined,
                            color: Colors.white),
                        label: const Text('Download Report',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Summary Cards ──────────────────────────────
                        GridView.count(
                          crossAxisCount: 5,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4,
                          children: [
                            _buildSummaryCard(
                              'Total Earned',
                              'PKR ${_totalEarned.toStringAsFixed(0)}',
                              Icons.trending_up,
                              Colors.green,
                            ),
                            _buildSummaryCard(
                              'Paid to Subscriptions',
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
                              'Commission',
                              'PKR ${_totalCommission.toStringAsFixed(0)}',
                              Icons.percent_outlined,
                              Colors.purple,
                            ),
                            _buildSummaryCard(
                              'Net Amount',
                              'PKR ${_netAmount.toStringAsFixed(0)}',
                              Icons.account_balance_wallet_outlined,
                              _netAmount >= 0 ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Tabs ───────────────────────────────────────
                        Container(
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
                            children: [
                              TabBar(
                                controller: _tabController,
                                labelColor: AppColors.primary,
                                unselectedLabelColor: AppColors.textTertiary,
                                indicatorColor: AppColors.primary,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w700),
                                tabs: const [
                                  Tab(text: 'Package Sales'),
                                  Tab(text: 'Subscriptions'),
                                  Tab(text: 'Refunds'),
                                ],
                              ),
                              SizedBox(
                                height: 500,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildPackageSalesTab(),
                                    _buildSubscriptionsTab(),
                                    _buildRefundsTab(),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color == Colors.red
                  ? Colors.red
                  : const Color(0xFF1B1E28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSalesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _packageSales.length,
      itemBuilder: (context, index) {
        final sale = _packageSales[index];
        final bool isPending = sale['status'] == 'Pending';
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sell_outlined,
                    color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale['package'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sale['customer']} • ${sale['date']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PKR ${sale['net']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sale['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _subscriptionPayments.length,
      itemBuilder: (context, index) {
        final sub = _subscriptionPayments[index];
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.card_membership_outlined,
                    color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub['plan'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sub['method']} • ${sub['date']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PKR ${sub['amount']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefundsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _refunds.length,
      itemBuilder: (context, index) {
        final refund = _refunds[index];
        final bool isPending = refund['status'] == 'Pending';
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.undo_outlined,
                    color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      refund['package'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${refund['customer']} • ${refund['date']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      refund['reason'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7D848D),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PKR ${refund['amount']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      refund['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}