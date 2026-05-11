import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
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

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRefundRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRefundRequests() async {
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
        Uri.parse('${ApiConfig.BASE_URL}/api/refund/agent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List raw = data['refundRequests'] ?? [];
        setState(() {
          _requests =
              raw.map((r) => Map<String, dynamic>.from(r)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load refund requests';
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

  Future<void> _approveRefund(String bookingId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.BASE_URL}/api/refund/approve/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': 'Approved by agent'}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refund approved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchRefundRequests();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to approve refund'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRejectDialog(String bookingId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: TextStyle(color: Color(0xFF7D848D), fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for Rejection',
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _rejectRefund(
                            bookingId, reasonController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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

  Future<void> _rejectRefund(String bookingId, String reason) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.BASE_URL}/api/refund/reject/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
            {'reason': reason.isNotEmpty ? reason : 'No reason provided'}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refund rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _fetchRefundRequests();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to reject refund'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _pendingRequests =>
      _requests.where((r) => r['refundStatus'] == 'REQUESTED').toList();
  List<Map<String, dynamic>> get _approvedRequests =>
      _requests.where((r) => r['refundStatus'] == 'APPROVED').toList();
  List<Map<String, dynamic>> get _rejectedRequests =>
      _requests.where((r) => r['refundStatus'] == 'REJECTED').toList();

  String _getUserName(Map<String, dynamic> req) {
    final user = req['userId'];
    if (user is Map) return user['fullName'] ?? 'Unknown';
    return 'Unknown';
  }

  String _getUserContact(Map<String, dynamic> req) {
    final user = req['userId'];
    if (user is Map) return user['phone'] ?? 'N/A';
    return 'N/A';
  }

  String _getUserEmail(Map<String, dynamic> req) {
    final user = req['userId'];
    if (user is Map) return user['email'] ?? 'N/A';
    return 'N/A';
  }

  String _getPackageTitle(Map<String, dynamic> req) {
    final pkg = req['packageId'];
    if (pkg is Map) return pkg['title'] ?? 'Unknown Package';
    return 'Unknown Package';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}-${dt.month}-${dt.year}';
    } catch (_) {
      return dateStr;
    }
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
                      Row(
                        children: [
                          _buildCountChip(
                              '${_pendingRequests.length} Pending',
                              Colors.orange),
                          const SizedBox(width: 8),
                          _buildCountChip(
                              '${_approvedRequests.length} Approved',
                              Colors.green),
                          const SizedBox(width: 8),
                          _buildCountChip(
                              '${_rejectedRequests.length} Rejected',
                              Colors.red),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _fetchRefundRequests,
                            icon: const Icon(Icons.refresh,
                                color: AppColors.primary),
                            tooltip: 'Refresh',
                          ),
                        ],
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
                          : Column(
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: TabBar(
                                    controller: _tabController,
                                    labelColor: AppColors.primary,
                                    unselectedLabelColor:
                                        AppColors.textTertiary,
                                    indicatorColor: AppColors.primary,
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                    tabs: [
                                      Tab(
                                          text:
                                              'Pending (${_pendingRequests.length})'),
                                      Tab(
                                          text:
                                              'Approved (${_approvedRequests.length})'),
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
                                      _buildRequestsList(_approvedRequests),
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
            onPressed: _fetchRefundRequests,
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

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 13),
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
            Text('No requests here',
                style: TextStyle(color: Color(0xFF7D848D), fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRefundRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(32),
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildRequestCard(
          requests[index],
          showActions: showActions,
          showRejectionReason: showRejectionReason,
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request, {
    bool showActions = false,
    bool showRejectionReason = false,
  }) {
    final bookingId = request['_id'] ?? '';
    final userName = _getUserName(request);
    final packageTitle = _getPackageTitle(request);
    final amount = request['totalAmount'] ?? 0;
    final reason = request['cancellationReason'] ?? 'No reason provided';
    final date = _formatDate(request['createdAt']);
    final refundStatus = request['refundStatus'] ?? 'REQUESTED';

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
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User: $userName',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Contact: ${_getUserContact(request)}',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF4A4A4A))),
                    Text('Email: ${_getUserEmail(request)}',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF4A4A4A))),
                    Text('Package: $packageTitle',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF4A4A4A))),
                    Text('Requested: $date',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF7D848D))),
                    const SizedBox(height: 4),
                    Text(
                      'Reason: $reason',
                      style: const TextStyle(
                        fontSize: 13,
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
                    'PKR $amount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B1E28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(refundStatus),
                ],
              ),
            ],
          ),
          if (showRejectionReason &&
              request['cancellationReason'] != null) ...[
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
                      'Rejection reason: ${request['cancellationReason']}',
                      style: const TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(bookingId),
                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  label: const Text('Reject',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _approveRefund(bookingId),
                  icon: const Icon(Icons.check,
                      color: Colors.white, size: 18),
                  label: const Text('Approve',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
      case 'APPROVED':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'REJECTED':
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
            color: color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
