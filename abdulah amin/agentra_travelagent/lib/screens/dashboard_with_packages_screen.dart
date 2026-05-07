import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/side_navigation_drawer.dart';
import '../widgets/custom_button.dart';
import '../services/package_service.dart';
import '../models/package.dart';
import 'agent_reviews_screen.dart';
import 'edit_package_screen.dart';

class DashboardWithPackagesScreen extends StatefulWidget {
  const DashboardWithPackagesScreen({Key? key}) : super(key: key);

  @override
  State<DashboardWithPackagesScreen> createState() => _DashboardWithPackagesScreenState();
}

class _DashboardWithPackagesScreenState extends State<DashboardWithPackagesScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    final packages = await PackageService.getAgentPackages();
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const SideNavigationDrawer(),
      body: Row(
        children: [
          // On large screens, we could show a permanent sidebar here
          // For now, let's stick to the mobile/tablet responsive look
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Top Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: false,
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Agent!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1E28),
                        ),
                      ),
                      Text(
                        'Check your travel portal overview today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7D848D),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF1B1E28)),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFF7F8F9),
                        child: Icon(Icons.person_outline, color: Color(0xFF1B1E28)),
                      ),
                    ),
                  ],
                ),
                
                // Stats Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatCard('Total Sales', 'PKR 0', '0%', Colors.green),
                              const SizedBox(width: 16),
                              _buildStatCard('Active Bookings', '0', '0%', Colors.blue),
                              const SizedBox(width: 16),
                              _buildStatCard('Pending Payouts', 'PKR 0', '0%', Colors.orange),
                              const SizedBox(width: 16),
                              _buildStatCard('Rating', '5.0', '0%', Colors.amber),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Packages',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B1E28),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/create-package').then((_) => _loadPackages());
                              },
                              child: const Text(
                                '+ Add New',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // Package List
                _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(child: Padding(
                          padding: EdgeInsets.all(100.0),
                          child: CircularProgressIndicator(),
                        )),
                      )
                    : _packages.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 50),
                                  const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.black12),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No packages created yet',
                                    style: TextStyle(
                                      color: Color(0xFF7D848D),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CustomButton(
                                    text: 'Create First Package',
                                    onPressed: () => Navigator.pushNamed(context, '/create-package').then((_) => _loadPackages()),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 0.85,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildPackageCard(context, _packages[index]),
                                childCount: _packages.length,
                              ),
                            ),
                          ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7D848D),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1E28),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                change,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'vs last month',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7D848D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this package? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PackageService.deletePackage(id);
      if (success && mounted) {
        _loadPackages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package deleted successfully'), backgroundColor: Color(0xFF4CAF50)),
        );
      }
    }
  }

  Widget _buildPackageCard(BuildContext context, Package package) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: (package.image != null && package.image!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(package.image!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?q=80&w=1000'),
                        fit: BoxFit.cover,
                      ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            package.rating?.toString() ?? '4.8',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B1E28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${package.duration} | Full Tour',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7D848D),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRICE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7D848D),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'PKR ${package.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
            Row(
  children: [
    // Reviews button
    IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgentReviewsScreen(package: package),
          ),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.star_outline, color: Colors.amber, size: 20),
      ),
    ),
    // Edit button
    IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPackageScreen(package: package),
          ),
        ).then((_) => _loadPackages());
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
      ),
    ),
    // Delete button
    IconButton(
      onPressed: () => _handleDelete(package.id),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
      ),
    ),
  ],
),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
