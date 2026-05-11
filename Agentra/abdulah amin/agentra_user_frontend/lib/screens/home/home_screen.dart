import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/package_card.dart';
import '../../models/package.dart';
import '../../services/package_service.dart';
import '../../widgets/side_drawer.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Package> _packages = [];
  User? _user;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh packages every 30 seconds for real-time sync
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _refreshPackages();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Silently refresh packages without showing loading spinner
  Future<void> _refreshPackages() async {
    final packages = await PackageService.getPackages();
    if (mounted) {
      setState(() => _packages = packages);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getCurrentUser();
    final packages = await PackageService.getPackages();
    if (mounted) {
      setState(() {
        _user = user;
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
  if (index == _currentIndex) return;

  setState(() => _currentIndex = index);

  switch (index) {
    case 0:
      break;
    case 1:
      Navigator.pushNamed(context, '/bookings').then((_) {
        setState(() => _currentIndex = 0);
      });
      break;
    case 2:
      Navigator.pushNamed(context, '/chat').then((_) {
        setState(() => _currentIndex = 0);
      });
      break;
    case 3:
      Navigator.pushNamed(context, '/search').then((_) {
        setState(() => _currentIndex = 0);
      });
      break;
    case 4:
      Navigator.pushNamed(context, '/profile').then((_) {
        setState(() => _currentIndex = 0);
      });
      break;
  }
}
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const SideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    backgroundImage: (_user?.profileImage != null && _user!.profileImage!.isNotEmpty)
                        ? NetworkImage(_user!.profileImage!)
                        : null,
                    child: (_user?.profileImage == null || _user!.profileImage!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_user != null)
                      Text(
                        'Hello, ${_user!.fullName.split(' ')[0]}!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 28,
                          height: 1.2,
                        ),
                        children: const [
                          TextSpan(text: 'Explore the\nBeautiful '),
                          TextSpan(
                            text: 'world!',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Search Input Entry Point
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Search destinations...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : _packages.isEmpty
                      ? const Center(
                          child: Text(
                            'No packages available',
                            style: AppTextStyles.bodyMedium,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _packages.length,
                            itemBuilder: (context, index) {
                              final package = _packages[index];

                              return PackageCard(
                                imageUrl: package.image ?? '',
                                title: package.title,
                                duration: package.duration,
                                price: 'PKR ${package.price}',
                                description: package.description,
                                rating: package.rating ?? 4.5,
                                showSaleBadge: false,
                                package: package,
                                onReviewTap: () {
    Navigator.pushNamed(
      context,
      '/reviews',
      arguments: package.id,
    );
  },
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/package-detail',
                                    arguments: package.id,
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
