import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
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

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
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
        Uri.parse('${ApiConfig.BASE_URL}/api/bookings/agent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List rawBookings = data['bookings'] ?? [];
        setState(() {
          _bookings = rawBookings
              .map((b) => Map<String, dynamic>.from(b))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Failed to load bookings';
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

  List<Map<String, dynamic>> get _confirmedBookings =>
      _bookings.where((b) => b['status'] == 'CONFIRMED').toList();

  List<Map<String, dynamic>> get _cancelledBookings =>
      _bookings.where((b) => b['status'] == 'CANCELLED').toList();

  double get _totalRevenue => _confirmedBookings.fold(
      0.0, (sum, b) => sum + ((b['totalAmount'] ?? 0) as num).toDouble());

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

  String _getUserName(Map<String, dynamic> booking) {
    final user = booking['userId'];
    if (user is Map) return user['fullName'] ?? 'Unknown';
    return 'Unknown';
  }

  String _getUserContact(Map<String, dynamic> booking) {
    final user = booking['userId'];
    if (user is Map) return user['phone'] ?? 'N/A';
    return 'N/A';
  }

  String _getUserEmail(Map<String, dynamic> booking) {
    final user = booking['userId'];
    if (user is Map) return user['email'] ?? 'N/A';
    return 'N/A';
  }

  String _getPackageTitle(Map<String, dynamic> booking) {
    final pkg = booking['packageId'];
    if (pkg is Map) return pkg['title'] ?? 'Unknown Package';
    return 'Unknown Package';
  }

  String _getPackageLocation(Map<String, dynamic> booking) {
    final pkg = booking['packageId'];
    if (pkg is Map) return pkg['location'] ?? '';
    return '';
  }

  String _getPackageImage(Map<String, dynamic> booking) {
    final pkg = booking['packageId'];
    if (pkg is Map) {
      final images = pkg['images'];
      if (images is List && images.isNotEmpty) return images[0] as String;
      return pkg['image'] ?? '';
    }
    return '';
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
                      Row(
                        children: [
                          _buildChip(
                              '${_confirmedBookings.length} Confirmed',
                              Colors.green),
                          const SizedBox(width: 8),
                          _buildChip(
                              '${_cancelledBookings.length} Cancelled',
                              Colors.red),
                          const SizedBox(width: 8),
                          _buildChip(
                              'PKR ${_totalRevenue.toStringAsFixed(0)}',
                              AppColors.primary),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _fetchBookings,
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
                                              'Confirmed (${_confirmedBookings.length})'),
                                      Tab(
                                          text:
                                              'Cancelled (${_cancelledBookings.length})'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildBookingsList(_confirmedBookings),
                                      _buildBookingsList(_cancelledBookings),
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
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchBookings,
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

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.black12),
            SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(color: Color(0xFF7D848D), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(32),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final bool isConfirmed = booking['status'] == 'CONFIRMED';
    final userName = _getUserName(booking);
    final packageTitle = _getPackageTitle(booking);
    final packageLocation = _getPackageLocation(booking);
    final packageImage = _getPackageImage(booking);
    final travelDate = _formatDate(booking['travelDate']);
    final bookedOn = _formatDate(booking['createdAt']);
    final seats = booking['seats'] ?? 0;
    final totalAmount = booking['totalAmount'] ?? 0;
    final paymentMethod = booking['paymentMethod'] ?? 'N/A';

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
          // Package header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Package image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: packageImage.isNotEmpty
                      ? Image.network(
                          packageImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _packageImagePlaceholder(),
                        )
                      : _packageImagePlaceholder(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packageTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B1E28),
                        ),
                      ),
                      if (packageLocation.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: Color(0xFF7D848D)),
                            const SizedBox(width: 4),
                            Text(
                              packageLocation,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF7D848D)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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
          ),
          // Booking details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.person_outline,
                              'Traveller: $userName'),
                          _buildDetailRow(Icons.phone_outlined,
                              'Contact: ${_getUserContact(booking)}'),
                          _buildDetailRow(Icons.email_outlined,
                              'Email: ${_getUserEmail(booking)}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.event_seat_outlined,
                              'Seats: $seats'),
                          _buildDetailRow(Icons.payments_outlined,
                              'Total: PKR $totalAmount'),
                          _buildDetailRow(Icons.calendar_today_outlined,
                              'Travel: $travelDate'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDetailRow(Icons.credit_card_outlined,
                        'Payment: $paymentMethod'),
                    const SizedBox(width: 24),
                    _buildDetailRow(Icons.access_time_outlined,
                        'Booked: $bookedOn'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.landscape_outlined,
          color: AppColors.primary, size: 28),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7D848D)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A4A4A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
