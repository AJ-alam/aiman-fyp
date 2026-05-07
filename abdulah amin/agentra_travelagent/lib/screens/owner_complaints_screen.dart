import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/owner_side_navigation.dart';

class OwnerComplaintsScreen extends StatefulWidget {
  const OwnerComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerComplaintsScreen> createState() =>
      _OwnerComplaintsScreenState();
}

class _OwnerComplaintsScreenState extends State<OwnerComplaintsScreen> {
  int _selectedNavIndex = 3;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '1',
      'from': 'Aimen Nadeem',
      'role': 'Travel Agent',
      'email': 'aimen@gmail.com',
      'subject': 'Refund was not done',
      'description':
          'I requested a refund 2 weeks ago for a cancelled booking but have not received it yet. The booking ID is #BK1234.',
      'date': '10 Mar 2026',
      'status': 'pending',
      'response': '',
    },
    {
      'id': '2',
      'from': 'Ahmed Khan',
      'role': 'Travel Agent',
      'email': 'ahmed@gmail.com',
      'subject': 'Package not showing in search',
      'description':
          'My packages are not appearing in search results even though they are active. This has been going on for 3 days.',
      'date': '8 Mar 2026',
      'status': 'pending',
      'response': '',
    },
    {
      'id': '3',
      'from': 'Sara Ali',
      'role': 'Travel Agent',
      'email': 'sara@gmail.com',
      'subject': 'Payment not received',
      'description':
          'I completed a booking last month but the payment has not been transferred to my account.',
      'date': '5 Mar 2026',
      'status': 'resolved',
      'response':
          'We have investigated and the payment has been processed. Please check your account within 2-3 business days.',
    },
    {
      'id': '4',
      'from': 'Usman Tariq',
      'role': 'Travel Agent',
      'email': 'usman@gmail.com',
      'subject': 'Unable to upload images',
      'description':
          'I am unable to upload images for my packages. The upload button does not work.',
      'date': '1 Mar 2026',
      'status': 'resolved',
      'response':
          'This issue has been fixed in the latest update. Please refresh your portal.',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _complaints;
    return _complaints.where((c) {
      return c['from'].toString().toLowerCase().contains(_searchQuery) ||
          c['subject'].toString().toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _showDetailDialog(Map<String, dynamic> complaint) {
    final TextEditingController responseController =
        TextEditingController(text: complaint['response']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Complaint Details',
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
              const Divider(),
              const SizedBox(height: 16),
              // From
              _buildDetailRow('From',
                  '${complaint['from']} (${complaint['role']})'),
              _buildDetailRow('Email', complaint['email']),
              _buildDetailRow('Date', complaint['date']),
              _buildDetailRow('Subject', complaint['subject']),
              const SizedBox(height: 12),
              // Description
              const Text('Description',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7D848D),
                      fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  complaint['description'],
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      height: 1.6),
                ),
              ),
              const SizedBox(height: 16),
              // Response
              const Text('Your Response',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7D848D),
                      fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: responseController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your response here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      child: const Text('Close',
                          style: TextStyle(
                              color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          final index = _complaints.indexWhere(
                              (c) => c['id'] == complaint['id']);
                          if (index != -1) {
                            _complaints[index]['status'] = 'resolved';
                            _complaints[index]['response'] =
                                responseController.text;
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Response sent and complaint resolved!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Send Response & Resolve',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7D848D),
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1B1E28))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _complaints.where((c) => c['status'] == 'pending').length;
    final resolved =
        _complaints.where((c) => c['status'] == 'resolved').length;

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
                            'Complaint Management',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B1E28),
                            ),
                          ),
                          Text(
                            'View and respond to complaints',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7D848D),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildChip('$pending Pending', Colors.red),
                          const SizedBox(width: 8),
                          _buildChip(
                              '$resolved Resolved', Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                // Search
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(
                        () => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search complaints...',
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
                    ),
                  ),
                ),
                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(32),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final complaint = _filtered[index];
                      final bool isPending =
                          complaint['status'] == 'pending';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                            // Status dot
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.red
                                    : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isPending
                                            ? 'Pending'
                                            : 'Resolved',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isPending
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        complaint['date'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF7D848D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'From: ${complaint['from']} (${complaint['role']})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                  Text(
                                    'Complaint: ${complaint['subject']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7D848D),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // View Detail button
                            ElevatedButton(
                              onPressed: () =>
                                  _showDetailDialog(complaint),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('View Detail',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                      );
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13)),
    );
  }
}