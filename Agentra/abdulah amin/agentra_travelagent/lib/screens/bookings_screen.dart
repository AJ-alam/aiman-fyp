import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/side_navigation.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 3;
  late TabController _tabController;

  // Track which packages are expanded
  final Set<String> _expandedPackages = {};

  // Dummy bookings grouped by package
  final List<Map<String, dynamic>> _packages = [
    {
      'id': 'p1',
      'title': 'Nathia Gali Adventure',
      'image': '',
      'location': 'Nathia Gali',
      'date': '15 Mar 2026',
      'price': 15000,
      'bookings': [
        {
          'id': 'b1',
          'user': 'Aimen Nadeem',
          'contact': '03135766158',
          'email': 'aaiman@gmail.com',
          'cnic': '35201-1234567-1',
          'seats': 2,
          'totalPaid': 30000,
          'bookingDate': '10 Feb 2026',
          'status': 'confirmed',
          'specialRequests': 'Vegetarian meals preferred',
        },
        {
          'id': 'b2',
          'user': 'Ahmed Khan',
          'contact': '03001234567',
          'email': 'ahmed@gmail.com',
          'cnic': '35201-7654321-2',
          'seats': 1,
          'totalPaid': 15000,
          'bookingDate': '12 Feb 2026',
          'status': 'confirmed',
          'specialRequests': '',
        },
        {
          'id': 'b3',
          'user': 'Sara Ali',
          'contact': '03211234567',
          'email': 'sara@gmail.com',
          'cnic': '35201-9876543-3',
          'seats': 3,
          'totalPaid': 45000,
          'bookingDate': '14 Feb 2026',
          'status': 'confirmed',
          'specialRequests': 'Need wheelchair access',
        },
      ],
    },
    {
      'id': 'p2',
      'title': 'Hunza Valley Trip',
      'image': '',
      'location': 'Hunza Valley',
      'date': '20 Mar 2026',
      'price': 25000,
      'bookings': [
        {
          'id': 'b4',
          'user': 'Usman Tariq',
          'contact': '03451234567',
          'email': 'usman@gmail.com',
          'cnic': '35201-1111111-4',
          'seats': 2,
          'totalPaid': 50000,
          'bookingDate': '8 Feb 2026',
          'status': 'confirmed',
          'specialRequests': '',
        },
        {
          'id': 'b5',
          'user': 'Fatima Zahra',
          'contact': '03111234567',
          'email': 'fatima@gmail.com',
          'cnic': '35201-2222222-5',
          'seats': 1,
          'totalPaid': 25000,
          'bookingDate': '9 Feb 2026',
          'status': 'cancelled',
          'specialRequests': '',
        },
      ],
    },
    {
      'id': 'p3',
      'title': 'Lahore City Tour',
      'image': '',
      'location': 'Lahore',
      'date': '25 Mar 2026',
      'price': 8000,
      'bookings': [
        {
          'id': 'b6',
          'user': 'Ali Hassan',
          'contact': '03331234567',
          'email': 'ali@gmail.com',
          'cnic': '35201-3333333-6',
          'seats': 4,
          'totalPaid': 32000,
          'bookingDate': '5 Feb 2026',
          'status': 'confirmed',
          'specialRequests': 'Family trip with kids',
        },
        {
          'id': 'b7',
          'user': 'Ayesha Malik',
          'contact': '03551234567',
          'email': 'ayesha@gmail.com',
          'cnic': '35201-4444444-7',
          'seats': 2,
          'totalPaid': 16000,
          'bookingDate': '6 Feb 2026',
          'status': 'confirmed',
          'specialRequests': '',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalConfirmed => _packages.fold(
      0,
      (sum, p) => sum +
          (p['bookings'] as List)
              .where((b) => b['status'] == 'confirmed')
              .length);

  int get _totalCancelled => _packages.fold(
      0,
      (sum, p) => sum +
          (p['bookings'] as List)
              .where((b) => b['status'] == 'cancelled')
              .length);

  double get _totalRevenue => _packages.fold(
      0.0,
      (sum, p) => sum +
          (p['bookings'] as List)
              .where((b) => b['status'] == 'confirmed')
              .fold(0.0, (s, b) => s + (b['totalPaid'] as int)));

  void _cancelBooking(String packageId, String bookingId) {
  final TextEditingController reasonController = TextEditingController();
  final package = _packages.firstWhere((p) => p['id'] == packageId);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cancel Booking',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are You Sure You Want To Cancel The Booking?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B1E28),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking for ${package['title']}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7D848D),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reason for Cancellation',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1B1E28),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Natural disaster, operational issue...',
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Keep',
                      style: TextStyle(
                        color: Color(0xFF1B1E28),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Update booking status
                      setState(() {
                        final pkg = _packages
                            .firstWhere((p) => p['id'] == packageId);
                        final booking = (pkg['bookings'] as List)
                            .firstWhere((b) => b['id'] == bookingId);
                        booking['status'] = 'cancelled';
                        booking['cancellationReason'] =
                            reasonController.text.isNotEmpty
                                ? reasonController.text
                                : 'No reason provided';
                      });
                      // Show success dialog
                      _showCancelSuccessDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

void _showCancelSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(40),
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red X icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cancelled successfully',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B1E28),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Homepage',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Confirmed Bookings',
                              style: AppTextStyles.headingMedium),
                          Text(
                            'View and manage all bookings',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      // Summary chips
                      Row(
                        children: [
                          _buildChip(
                              '$_totalConfirmed Confirmed',
                              Colors.green),
                          const SizedBox(width: 8),
                          _buildChip(
                              '$_totalCancelled Cancelled',
                              Colors.red),
                          const SizedBox(width: 8),
                          _buildChip(
                              'PKR ${_totalRevenue.toStringAsFixed(0)}',
                              AppColors.primary),
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
                          tabs: const [
                            Tab(text: 'By Package'),
                            Tab(text: 'All Bookings'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildByPackageTab(),
                            _buildAllBookingsTab(),
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

  Widget _buildByPackageTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        final bookings = package['bookings'] as List;
        final confirmedCount =
            bookings.where((b) => b['status'] == 'confirmed').length;
        final isExpanded = _expandedPackages.contains(package['id']);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Package header — clickable to expand
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedPackages.remove(package['id']);
                    } else {
                      _expandedPackages.add(package['id']);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Package image placeholder
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.landscape_outlined,
                            color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      // Package info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B1E28),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14,
                                    color: Color(0xFF7D848D)),
                                const SizedBox(width: 4),
                                Text(
                                  package['location'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7D848D),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF7D848D)),
                                const SizedBox(width: 4),
                                Text(
                                  package['date'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7D848D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Confirmed count
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.green, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '$confirmedCount confirmed',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Arrow
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF7D848D)),
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded bookings list
              if (isExpanded) ...[
                const Divider(height: 1),
                ...bookings.map((booking) =>
                    _buildBookingRow(booking, package['id'])),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingRow(
      Map<String, dynamic> booking, String packageId) {
    final bool isConfirmed = booking['status'] == 'confirmed';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isConfirmed
            ? Colors.green.withOpacity(0.02)
            : Colors.red.withOpacity(0.02),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              booking['user'][0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'User: ${booking['user']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Status: ${isConfirmed ? 'Confirmed' : 'Cancelled'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isConfirmed ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                    Icons.phone_outlined, 'Contact: ${booking['contact']}'),
                _buildDetailRow(
                    Icons.email_outlined, 'Email id: ${booking['email']}'),
                _buildDetailRow(
                    Icons.badge_outlined, 'CNIC: ${booking['cnic']}'),
                _buildDetailRow(Icons.event_seat_outlined,
                    'Seats: ${booking['seats']}'),
                _buildDetailRow(Icons.payments_outlined,
                    'Total Paid: PKR ${booking['totalPaid']}'),
                _buildDetailRow(Icons.calendar_today_outlined,
                    'Booked on: ${booking['bookingDate']}'),
                if (booking['specialRequests'] != null &&
                    booking['specialRequests'].isNotEmpty)
                  _buildDetailRow(Icons.note_outlined,
                      'Special Requests: ${booking['specialRequests']}'),
              ],
            ),
          ),
          // Cancel button
          if (isConfirmed)
            TextButton(
              onPressed: () =>
                  _cancelBooking(packageId, booking['id']),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7D848D)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBookingsTab() {
    final List<Map<String, dynamic>> allBookings = [];
    for (final package in _packages) {
      for (final booking in package['bookings'] as List) {
        allBookings.add({
          ...Map<String, dynamic>.from(booking),
          'packageTitle': package['title'],
          'packageId': package['id'],
        });
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: allBookings.length,
      itemBuilder: (context, index) {
        final booking = allBookings[index];
        final bool isConfirmed = booking['status'] == 'confirmed';
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  booking['user'][0].toUpperCase(),
                  style: const TextStyle(
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
                      booking['user'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B1E28),
                      ),
                    ),
                    Text(
                      booking['packageTitle'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                    Text(
                      '${booking['contact']} • ${booking['email']}',
                      style: const TextStyle(
                        fontSize: 12,
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
                    'PKR ${booking['totalPaid']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF1B1E28),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isConfirmed ? 'Confirmed' : 'Cancelled',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isConfirmed ? Colors.green : Colors.red,
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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