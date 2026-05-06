import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: (_user?.profileImage != null && _user!.profileImage!.isNotEmpty)
                      ? NetworkImage(_user!.profileImage!)
                      : null,
                  child: (_user?.profileImage == null || _user!.profileImage!.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _user?.fullName ?? 'Loading...',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  Icons.person_outline,
                  'Edit Profile',
                  () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                _buildMenuItem(
                  context,
                  Icons.bookmark_border,
                  'Saved Packages',
                  () => Navigator.pushNamed(context, '/saved-packages'),
                ),
                _buildMenuItem(
                  context,
                  Icons.local_offer_outlined,
                  'Promotions',
                  () => Navigator.pushNamed(context, '/promotions'),
                ),
                _buildMenuItem(
                  context,
                  Icons.calendar_today_outlined,
                  'Booking Details',
                  () => Navigator.pushNamed(context, '/bookings'),
                ),
                _buildMenuItem(
                  context,
                  Icons.payment_outlined,
                  'Payment History',
                  () => Navigator.pushNamed(context, '/payment-history'),
                ),
                _buildMenuItem(
                  context,
                  Icons.money_off_outlined,
                  'Request Refund',
                  () => Navigator.pushNamed(context, '/refund-request'),
                ),
                _buildMenuItem(
                  context,
                  Icons.report_problem_outlined,
                  'File Complaint',
                  () => Navigator.pushNamed(context, '/complaint'),
                ),
                const Divider(),
              ],
            ),
          ),
          // Logout
          _buildMenuItem(
            context,
            Icons.logout,
            'Logout',
            () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            isLogout: true,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isLogout ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
