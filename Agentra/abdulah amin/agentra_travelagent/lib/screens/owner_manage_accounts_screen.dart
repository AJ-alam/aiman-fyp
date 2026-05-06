import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/owner_side_navigation.dart';

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

  // Dummy travel agents
  final List<Map<String, dynamic>> _agents = [
    {
      'id': '1',
      'name': 'Aimen Nadeem',
      'businessName': 'Mind Travellers',
      'email': 'aimen@gmail.com',
      'phone': '03135766156',
      'status': 'active', // active, blocked, notice_sent, deleted
      'joinDate': '10 Jan 2025',
      'totalPackages': 5,
      'totalBookings': 23,
    },
    {
      'id': '2',
      'name': 'Stranger Things',
      'businessName': 'Stranger Tours',
      'email': 'stranger@gmail.com',
      'phone': '03135766158',
      'status': 'active',
      'joinDate': '15 Feb 2025',
      'totalPackages': 3,
      'totalBookings': 10,
    },
    {
      'id': '3',
      'name': 'Muhammad Nadeem',
      'businessName': 'Nadeem Travels',
      'email': 'nadeem@gmail.com',
      'phone': '03001234567',
      'status': 'blocked',
      'joinDate': '20 Mar 2025',
      'totalPackages': 8,
      'totalBookings': 45,
    },
    {
      'id': '4',
      'name': 'Sara Ali',
      'businessName': 'Ali Adventures',
      'email': 'sara@gmail.com',
      'phone': '03211234567',
      'status': 'notice_sent',
      'joinDate': '5 Apr 2025',
      'totalPackages': 2,
      'totalBookings': 7,
      'noticeDate': '1 Mar 2026',
      'noticeDaysLeft': 13,
    },
  ];

  List<Map<String, dynamic>> get _filteredAgents {
    if (_searchQuery.isEmpty) return _agents;
    return _agents.where((a) {
      return a['name'].toString().toLowerCase().contains(_searchQuery) ||
          a['businessName'].toString().toLowerCase().contains(_searchQuery) ||
          a['email'].toString().toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _showDeleteDialog(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are about to delete ${agent['businessName']}\'s account.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF4A4A4A), fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A 1-month notice will be sent to the travel agent before their account is permanently deleted.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
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
                        side: const BorderSide(
                            color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          final index = _agents.indexWhere(
                              (a) => a['id'] == agent['id']);
                          if (index != -1) {
                            _agents[index]['status'] = 'notice_sent';
                            _agents[index]['noticeDate'] =
                                '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}';
                            _agents[index]['noticeDaysLeft'] = 30;
                            _agents[index]['noticeType'] = 'delete';
                          }
                        });
                        _showNoticeSentDialog(agent['name'], 'deletion');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Send Notice & Delete',
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

  void _showBlockDialog(Map<String, dynamic> agent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block_outlined,
                    color: Colors.blue, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Block Account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are about to block ${agent['businessName']}\'s account.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF4A4A4A), fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A 1-month notice will be sent to the travel agent before their account is blocked.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
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
                        side: const BorderSide(
                            color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          final index = _agents.indexWhere(
                              (a) => a['id'] == agent['id']);
                          if (index != -1) {
                            _agents[index]['status'] = 'notice_sent';
                            _agents[index]['noticeDate'] =
                                '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}';
                            _agents[index]['noticeDaysLeft'] = 30;
                            _agents[index]['noticeType'] = 'block';
                          }
                        });
                        _showNoticeSentDialog(agent['name'], 'blocking');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Send Notice & Block',
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

  void _unblockAgent(String id) {
    setState(() {
      final index = _agents.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _agents[index]['status'] = 'active';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account unblocked successfully'),
        backgroundColor: Colors.green,
      ),
    );
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
      case 'active': return Colors.green;
      case 'blocked': return Colors.red;
      case 'notice_sent': return Colors.orange;
      case 'deleted': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active': return 'Active';
      case 'blocked': return 'Blocked';
      case 'notice_sent': return 'Notice Sent';
      case 'deleted': return 'Deleted';
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
                              '${_agents.where((a) => a['status'] == 'active').length} Active',
                              Colors.green),
                          const SizedBox(width: 8),
                          _buildChip(
                              '${_agents.where((a) => a['status'] == 'blocked').length} Blocked',
                              Colors.red),
                          const SizedBox(width: 8),
                          _buildChip(
                              '${_agents.where((a) => a['status'] == 'notice_sent').length} Notice Sent',
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
                  agent['name'][0].toUpperCase(),
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
                      agent['name'],
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
                      agent['businessName'],
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF7D848D)),
                    ),
                    Text(
                      'Travel Agent  •  Joined ${agent['joinDate']}',
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
                if (status == 'blocked')
                  ElevatedButton(
                    onPressed: () => _unblockAgent(agent['id']),
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