import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/agent.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({Key? key}) : super(key: key);

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer>  {
  Agent? _agent;

  @override
  void initState() {
    super.initState();
    _loadAgent();
  }

  Future<void> _loadAgent() async {
    final agent = await AuthService.getCurrentAgent();
    if (mounted) {
      setState(() => _agent = agent);
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
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: (_agent?.profileImage != null &&
                          _agent!.profileImage!.isNotEmpty)
                      ? NetworkImage(_agent!.profileImage!)
                      : null,
                  child: (_agent?.profileImage == null ||
                          _agent!.profileImage!.isEmpty)
                      ? const Icon(Icons.person,
                          size: 40, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _agent?.businessName ?? _agent?.fullName ?? 'Loading...',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_agent?.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _agent!.email,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70),
                  ),
                ],
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
                  Icons.dashboard_outlined,
                  'Dashboard',
                  () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.inventory_2_outlined,
                  'My Packages',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/dashboard-packages');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.person_outline,
                  'Profile',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.edit_outlined,
                  'Edit Profile',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/edit-profile');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.money_off_outlined,
                  'Refund Requests',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/refund-requests');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.calendar_today_outlined,
                  'Booking Details',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/bookings');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.card_membership_outlined,
                  'Subscriptions',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscription');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.payment_outlined,
                  'Payment History',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/payment-history');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.bar_chart_outlined,
                  'Performance',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/performance');
                  },
                ),
                _buildMenuItem(
                  context,
                  Icons.report_problem_outlined,
                  'File Complaint',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/complaint');
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  Icons.logout,
                  'Logout',
                  () async {
                    Navigator.pop(context);
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
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
        size: 20,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isLogout ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.chevron_right,
              color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }
}