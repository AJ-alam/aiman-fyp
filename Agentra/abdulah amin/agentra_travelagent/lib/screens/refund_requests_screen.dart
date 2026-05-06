import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/side_navigation.dart';

class RefundRequestsScreen extends StatefulWidget {
  const RefundRequestsScreen({Key? key}) : super(key: key);

  @override
  State<RefundRequestsScreen> createState() => _RefundRequestsScreenState();
}

class _RefundRequestsScreenState extends State<RefundRequestsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 9;
  late TabController _tabController;

  // Dummy refund requests
  final List<Map<String, dynamic>> _requests = [
    {
      'id': '1',
      'user': 'Aimen Nadeem',
      'contact': '03135766158',
      'email': 'aaiman@gmail.com',
      'package': 'Nathia Gali Adventure',
      'date': '10-2-2025',
      'amount': 15000,
      'reason': 'Personal emergency',
      'status': 'pending',
    },
    {
      'id': '2',
      'user': 'Ahmed Khan',
      'contact': '03001234567',
      'email': 'ahmed@gmail.com',
      'package': 'Hunza Valley Trip',
      'date': '10-2-2025',
      'amount': 25000,
      'reason': 'Trip cancelled due to weather',
      'status': 'pending',
    },
    {
      'id': '3',
      'user': 'Sara Ali',
      'contact': '03211234567',
      'email': 'sara@gmail.com',
      'package': 'Lahore City Tour',
      'date': '8-2-2025',
      'amount': 8000,
      'reason': 'Change of plans',
      'status': 'pending',
    },
    {
      'id': '4',
      'user': 'Usman Tariq',
      'contact': '03451234567',
      'email': 'usman@gmail.com',
      'package': 'Swat Valley Tour',
      'date': '5-2-2025',
      'amount': 12000,
      'reason': 'Medical emergency',
      'status': 'accepted',
    },
    {
      'id': '5',
      'user': 'Fatima Zahra',
      'contact': '03111234567',
      'email': 'fatima@gmail.com',
      'package': 'Murree Trip',
      'date': '1-2-2025',
      'amount': 9000,
      'reason': 'Visa issues',
      'status': 'rejected',
      'rejectionReason': 'Trip already commenced',
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

  List<Map<String, dynamic>> get _pendingRequests =>
      _requests.where((r) => r['status'] == 'pending').toList();
  List<Map<String, dynamic>> get _acceptedRequests =>
      _requests.where((r) => r['status'] == 'accepted').toList();
  List<Map<String, dynamic>> get _rejectedRequests =>
      _requests.where((r) => r['status'] == 'rejected').toList();

  void _acceptRequest(String id) {
    setState(() {
      final index = _requests.indexWhere((r) => r['id'] == id);
      if (index != -1) _requests[index]['status'] = 'accepted';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refund request accepted!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRejectDialog(String id) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.undo_outlined,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reject Request',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to reject this request?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for Rejection',
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side:
                            const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel',
                          style:
                              TextStyle(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          final index = _requests
                              .indexWhere((r) => r['id'] == id);
                          if (index != -1) {
                            _requests[index]['status'] = 'rejected';
                            _requests[index]['rejectionReason'] =
                                reasonController.text.isNotEmpty
                                    ? reasonController.text
                                    : 'No reason provided';
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Refund request rejected'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
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
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Refund Requests',
                              style: AppTextStyles.headingMedium),
                          Text(
                            'Manage customer refund requests',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      // Summary chips
                      Row(
                        children: [
                          _buildCountChip(
                              '${_pendingRequests.length} Pending',
                              Colors.orange),
                          const SizedBox(width: 8),
                          _buildCountChip(
                              '${_acceptedRequests.length} Accepted',
                              Colors.green),
                          const SizedBox(width: 8),
                          _buildCountChip(
                              '${_rejectedRequests.length} Rejected',
                              Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textTertiary,
                          indicatorColor: AppColors.primary,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700),
                          tabs: [
                            Tab(
                                text:
                                    'Pending (${_pendingRequests.length})'),
                            Tab(
                                text:
                                    'Accepted (${_acceptedRequests.length})'),
                            Tab(
                                text:
                                    'Rejected (${_rejectedRequests.length})'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRequestsList(_pendingRequests,
                                showActions: true),
                            _buildRequestsList(_acceptedRequests),
                            _buildRequestsList(_rejectedRequests,
                                showRejectionReason: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    List<Map<String, dynamic>> requests, {
    bool showActions = false,
    bool showRejectionReason = false,
  }) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.black12),
            SizedBox(height: 16),
            Text(
              'No requests here',
              style: TextStyle(
                color: Color(0xFF7D848D),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(
          request,
          showActions: showActions,
          showRejectionReason: showRejectionReason,
        );
      },
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request, {
    bool showActions = false,
    bool showRejectionReason = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  request['user'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User: ${request['user']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact: ${request['contact']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    Text(
                      'Email id: ${request['email']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    Text(
                      'Package: ${request['package']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    Text(
                      'Requested: ${request['date']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                    if (request['reason'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${request['reason']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7D848D),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PKR ${request['amount']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B1E28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(request['status']),
                ],
              ),
            ],
          ),

          // Rejection reason
          if (showRejectionReason &&
              request['rejectionReason'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection reason: ${request['rejectionReason']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          if (showActions) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(request['id']),
                  icon: const Icon(Icons.close,
                      color: Colors.red, size: 18),
                  label: const Text('Reject',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _acceptRequest(request['id']),
                  icon: const Icon(Icons.check,
                      color: Colors.white, size: 18),
                  label: const Text('Accept',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}