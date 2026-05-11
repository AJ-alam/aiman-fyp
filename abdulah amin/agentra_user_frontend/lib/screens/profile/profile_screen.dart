import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/side_drawer.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../models/user.dart';
import '../../models/booking.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;
  User? _user;
  List<Booking> _completedBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final user = await AuthService.getCurrentUser(forceRefresh: true);
    final bookings = await BookingService.getMyBookings();
    
    if (mounted) {
      setState(() {
        _user = user;
        // Filter for completed or at least confirmed bookings to show as "trips"
        _completedBookings = bookings.where((b) => 
          b.status.toLowerCase() == 'completed' || b.status.toLowerCase() == 'confirmed'
        ).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Profile',
          style: AppTextStyles.headingSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile').then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Profile Header
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    backgroundImage: (_user?.profileImage != null && _user!.profileImage!.isNotEmpty)
                        ? NetworkImage(_user!.profileImage!)
                        : null,
                    child: (_user?.profileImage == null || _user!.profileImage!.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user?.fullName ?? 'Guest User',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? 'Sign in to see details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Reward\nPoints', '${_user?.rewardPoints ?? 0}'),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                        _buildStatItem('Travel\nTrips', '${_user?.totalBookings ?? 0}'),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                        _buildStatItem('Favourites', '${_user?.favoritesCount ?? 0}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Trips Completed
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Trips Completed',
                        style: AppTextStyles.headingSmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _completedBookings.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No trips completed yet.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                        ),
                      )
                    : SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _completedBookings.length,
                          itemBuilder: (context, index) {
                            return _buildTripCard(_completedBookings[index]);
                          },
                        ),
                      ),
                  const SizedBox(height: 24),
                  // Optional Action Button
                  if (_user != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButton(
                        text: 'Edit Profile',
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-profile').then((_) => _loadData());
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4) return;
          
          setState(() => _currentIndex = index);
          
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/bookings');
              break;
            case 2:
              Navigator.pushNamed(context, '/chat');
              break;
            case 3:
              Navigator.pushNamed(context, '/search');
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(Booking booking) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: (booking.packageImage != null && booking.packageImage!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(booking.packageImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (booking.packageImage == null || booking.packageImage!.isEmpty)
                ? const Center(
                    child: Icon(Icons.image, color: AppColors.textTertiary, size: 40),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.packageTitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  booking.travelDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Write a Review button for completed bookings
                if (booking.status.toLowerCase() == 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/write-review',
                          arguments: {
                            'packageId': booking.packageId,
                            'packageTitle': booking.packageTitle,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text(
                        'Write Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
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
}
