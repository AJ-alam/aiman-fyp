import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/owner_side_navigation.dart';
import '../services/admin_service.dart';

class OwnerFinancialScreen extends StatefulWidget {
  const OwnerFinancialScreen({Key? key}) : super(key: key);

  @override
  State<OwnerFinancialScreen> createState() =>
      _OwnerFinancialScreenState();
}

class _OwnerFinancialScreenState extends State<OwnerFinancialScreen> {
  int _selectedNavIndex = 4;
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await AdminService.getOwnerDashboard();
    if (mounted) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    }
  }

  // Real summary cards based on backend data
  List<Map<String, dynamic>> get _summaryCards {
    return [
      {
        'label': 'Total Revenue',
        'value': 'PKR ${_dashboardData['totalRevenue'] ?? '0'}',
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.green,
      },
      {
        'label': 'Total Users',
        'value': '${_dashboardData['totalUsers'] ?? 0}',
        'icon': Icons.people_outlined,
        'color': Colors.blue,
      },
      {
        'label': 'Pending Payouts',
        'value': '${_dashboardData['pendingPayouts'] ?? 0}',
        'icon': Icons.pending_outlined,
        'color': Colors.orange,
      },
      {
        'label': 'Total Bookings',
        'value': '${_dashboardData['totalBookings'] ?? 0}',
        'icon': Icons.card_travel_outlined,
        'color': Colors.purple,
      },
    ];
  }


  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Oct', 'revenue': 2200000, 'bookings': 45},
    {'month': 'Nov', 'revenue': 2800000, 'bookings': 60},
    {'month': 'Dec', 'revenue': 3500000, 'bookings': 78},
    {'month': 'Jan', 'revenue': 2900000, 'bookings': 55},
    {'month': 'Feb', 'revenue': 3100000, 'bookings': 67},
    {'month': 'Mar', 'revenue': 3800000, 'bookings': 82},
  ];

  List<dynamic> get _topAgents {
    return _dashboardData['topAgents'] ?? [];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          OwnerSideNavigation(
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
                      bottom: BorderSide(
                          color: Color(0xFFEEEEEE), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Overview',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B1E28),
                            ),
                          ),
                          Text(
                            'Platform revenue and financial summary',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7D848D),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Report download coming soon!')),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Summary Cards ──────────────────────────
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1E28),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: _summaryCards
                              .map((card) => _buildSummaryCard(card))
                              .toList(),
                        ),
                        const SizedBox(height: 32),

                        // ── Monthly Revenue ────────────────────────
                        const Text(
                          'Monthly Revenue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1E28),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _monthlyData.map((month) {
                              const double maxRevenue = 4000000;
                              final double barWidth =
                                  (month['revenue'] / maxRevenue)
                                      .clamp(0.0, 1.0);
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      child: Text(
                                        month['month'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Color(0xFF7D848D),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child:
                                            LinearProgressIndicator(
                                          value: barWidth,
                                          backgroundColor:
                                              const Color(0xFFF0F0F0),
                                         valueColor: const AlwaysStoppedAnimation<Color>(
  AppColors.primary,
),
                                          minHeight: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        'PKR ${(month['revenue'] / 1000000).toStringAsFixed(1)}M',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Top Earning Agents ─────────────────────
                        const Text(
                          'Top Earning Agents',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1E28),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._topAgents.asMap().entries.map((entry) {
                          final i = entry.key;
                          final agent = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Rank
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? Colors.amber
                                        : i == 1
                                            ? Colors.grey.shade400
                                            : i == 2
                                                ? Colors.brown.shade300
                                                : AppColors.primary
                                                    .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${i + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        color: i < 3
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        agent['businessName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xFF1B1E28),
                                        ),
                                      ),
                                      Text(
                                        agent['fullName'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7D848D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${agent['totalBookings'] ?? 0} Bookings',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      '${agent['totalPackages'] ?? 0} Packages',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7D848D),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
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

  Widget _buildSummaryCard(Map<String, dynamic> card) {
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
                  card['label'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7D848D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (card['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card['icon'] as IconData,
                    color: card['color'] as Color, size: 18),
              ),
            ],
          ),
          Text(
            card['value'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1E28),
            ),
          ),
        ],
      ),
    );
  }
}