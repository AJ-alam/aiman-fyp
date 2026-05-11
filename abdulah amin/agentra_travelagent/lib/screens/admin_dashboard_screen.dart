import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/admin_service.dart';
import '../widgets/owner_side_navigation.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> _agents = [];
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  // Monthly stats (will be updated from real data)
  List<Map<String, dynamic>> _getMonthlyStats() {
    return [
      {
        'label': 'Total Bookings',
        'value': _dashboardData['totalBookings'] ?? 0,
        'color': Colors.red
      },
      {
        'label': 'Pending Refunds',
        'value': _dashboardData['pendingRefunds'] ?? 0,
        'color': Colors.orange
      },
      {
        'label': 'New Agents',
        'value': _dashboardData['newAgents'] ?? 0,
        'color': Colors.amber
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final agents = await AdminService.getAllAgents();
    final dashboard = await AdminService.getOwnerDashboard();
    if (mounted) {
      setState(() {
        _agents = agents;
        _dashboardData = dashboard;
        _isLoading = false;
      });
    }
  }

  void _showAgentDetails(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Agent Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B1E28),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              // Agent name
              Text(
                agent['fullName'] ?? agent['businessName'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 20),
              // Revenue card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        Text('Timeline',
                            style: TextStyle(
                                color: Color(0xFF7D848D), fontSize: 13)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('RS ${agent['revenue'] ?? '0'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Color(0xFF1B1E28))),
                        Text('2023 - 2025',
                            style: TextStyle(
                                color: Color(0xFF7D848D), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Performance card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agent Performance',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPerfRow('Total Packages',
                        '${agent['totalPackages'] ?? 0}'),
                    _buildPerfRow('Overall Rating',
                        '${agent['averageRating'] ?? 0} (good)'),
                    _buildPerfRow('Total Complaints', '${agent['totalComplaints'] ?? 0}'),
                    _buildPerfRow('Total Packages Sold',
                        '${agent['totalBookings'] ?? 0}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Download Report button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Report download coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.download_outlined,
                      color: Colors.white),
                  label: const Text('Download Report',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildPerfRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF4A4A4A))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1E28))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          OwnerSideNavigation(
            selectedIndex: 0,
            onItemSelected: (_) {},
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
                            'Overview',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B1E28),
                            ),
                          ),
                          Text(
                            'Platform statistics and registered agents',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7D848D),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadData,
                        tooltip: 'Refresh',
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
                              // ── Monthly Statistics ─────────────────
                              const Text(
                                'Monthly Statistics',
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
                                    children: _getMonthlyStats().map((stat) {
                                      const double maxVal = 100; // Adjusted max value
                                      final double barWidth =
                                          (stat['value'] / maxVal)
                                              .clamp(0.0, 1.0);
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              '${stat['value']}',
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(4),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: barWidth,
                                                    backgroundColor:
                                                        const Color(
                                                            0xFFF0F0F0),
                                                    valueColor: AlwaysStoppedAnimation<Color>(
  (stat['color'] as Color),
),
                                                    minHeight: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  stat['label'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Color(0xFF7D848D),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ── Registered Travel Agents ───────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Registered Travel Agents',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1B1E28),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_agents.length} Total',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _agents.isEmpty
                                  ? const Center(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 40),
                                          Icon(
                                              Icons.people_outlined,
                                              size: 64,
                                              color: Colors.black12),
                                          SizedBox(height: 16),
                                          Text('No agents found'),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: _agents
                                          .map((agent) =>
                                              _buildAgentRow(agent))
                                          .toList(),
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

  Widget _buildAgentRow(Map<String, dynamic> agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: (agent['profileImage'] != null &&
                    agent['profileImage'].toString().isNotEmpty)
                ? NetworkImage(agent['profileImage'])
                : null,
            child: (agent['profileImage'] == null ||
                    agent['profileImage'].toString().isEmpty)
                ? Text(
                    (agent['fullName'] ??
                            agent['businessName'] ??
                            'A')[0]
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent['businessName'] ??
                      agent['fullName'] ??
                      'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1B1E28),
                  ),
                ),
                Text(
                  agent['phone'] ?? 'No phone',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7D848D),
                  ),
                ),
              ],
            ),
          ),
          // Verified badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: agent['isVerified'] == true
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              agent['isVerified'] == true ? 'Verified' : 'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: agent['isVerified'] == true
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // View details
          TextButton(
            onPressed: () => _showAgentDetails(agent),
            child: const Text(
              'view details',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}