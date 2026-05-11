import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/owner_side_navigation.dart';
import '../services/admin_service.dart';

class OwnerManageAccountsScreen extends StatefulWidget {
  const OwnerManageAccountsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerManageAccountsScreen> createState() =>
      _OwnerManageAccountsScreenState();
}

class _OwnerManageAccountsScreenState
    extends State<OwnerManageAccountsScreen> {
  int _selectedNavIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<dynamic> _agents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    final agents = await AdminService.getAllAgents();
    if (mounted) {
      setState(() {
        _agents = agents;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredAgents {
    if (_searchQuery.isEmpty) return _agents;
    return _agents.where((a) {
      final name = (a['fullName'] ?? '').toString().toLowerCase();
      final businessName = (a['businessName'] ?? '').toString().toLowerCase();
      final email = (a['email'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) ||
          businessName.contains(_searchQuery) ||
          email.contains(_searchQuery);
    }).toList();
  }


  void _showDeleteDialog(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete ${agent['fullName']}\'s account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await AdminService.rejectAgent(agent['_id']);
              if (success && mounted) {
                Navigator.pop(context);
                _loadAgents();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Block Account',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to block ${agent['fullName']}\'s account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await AdminService.blockAgent(agent['_id']);
              if (success && mounted) {
                Navigator.pop(context);
                _loadAgents();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Block', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNoticeSentDialog(String name, String action) {
    showDialog(
      context: context,
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
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text(
                'Notice Sent!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$name has been notified about the $action of their account. They have 30 days to respond.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7D848D),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Okay',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _unblockAgent(String id) async {
    final success = await AdminService.unblockAgent(id);
    if (success && mounted) {
      _loadAgents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account unblocked successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED': return Colors.green;
      case 'BLOCKED': return Colors.red;
      case 'PENDING_APPROVAL': return Colors.orange;
      case 'REJECTED': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'APPROVED': return 'Active';
      case 'BLOCKED': return 'Blocked';
      case 'PENDING_APPROVAL': return 'Pending';
      case 'REJECTED': return 'Rejected';
      default: return 'Unknown';
    }
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
                            'Account Management',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B1E28),
                            ),
                          ),
                          Text(
                            'Manage travel agent accounts',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7D848D),
                            ),
                          ),
                        ],
                      ),
                // Status chips
                Row(
                  children: [
                    _buildChip(
                        '${_agents.where((a) => a['status'] == 'APPROVED').length} Active',
                        Colors.green),
                    const SizedBox(width: 8),
                    _buildChip(
                        '${_agents.where((a) => a['status'] == 'BLOCKED').length} Blocked',
                        Colors.red),
                    const SizedBox(width: 8),
                    _buildChip(
                        '${_agents.where((a) => a['status'] == 'PENDING_APPROVAL').length} Pending',
                        Colors.orange),
                  ],
                ),
                    ],
                  ),
                ),
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by name, business or email...',
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF7D848D)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFEEEEEE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFEEEEEE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: _filteredAgents.isEmpty
                      ? const Center(
                          child: Text('No agents found',
                              style: TextStyle(
                                  color: Color(0xFF7D848D),
                                  fontSize: 16)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(32),
                          itemCount: _filteredAgents.length,
                          itemBuilder: (context, index) {
                            final agent = _filteredAgents[index];
                            return _buildAgentCard(agent);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final String status = agent['status'];
    final bool isDeleted = status == 'deleted';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDeleted ? Colors.grey.shade50 : Colors.white,
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
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: isDeleted
                    ? Colors.grey.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                child: Text(
                  (agent['fullName'] ?? agent['businessName'] ?? 'A')[0].toUpperCase(),
                  style: TextStyle(
                    color: isDeleted ? Colors.grey : AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent['fullName'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDeleted
                            ? Colors.grey
                            : const Color(0xFF1B1E28),
                        decoration: isDeleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      agent['businessName'] ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF7D848D)),
                    ),
                    Text(
                      'Travel Agent  •  Joined ${agent['createdAt']?.toString().split('T')[0] ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF7D848D)),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Action buttons
              if (!isDeleted) ...[
                if (status == 'BLOCKED')
                  ElevatedButton(
                    onPressed: () => _unblockAgent(agent['_id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Unblock',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13)),
                  )
                else if (status != 'notice_sent') ...[
                  ElevatedButton(
                    onPressed: () => _showDeleteDialog(agent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Delete',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showBlockDialog(agent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Block',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                ],
              ],
            ],
          ),
          // Notice sent info
          if (status == 'notice_sent') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_outlined,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notice sent on ${agent['noticeDate']} • ${agent['noticeDaysLeft']} days remaining until ${agent['noticeType'] == 'delete' ? 'deletion' : 'blocking'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        final index = _agents.indexWhere(
                            (a) => a['id'] == agent['id']);
                        if (index != -1) {
                          _agents[index]['status'] =
                              agent['noticeType'] == 'delete'
                                  ? 'deleted'
                                  : 'blocked';
                        }
                      });
                    },
                    child: Text(
                      'Confirm ${agent['noticeType'] == 'delete' ? 'Delete' : 'Block'} Now',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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