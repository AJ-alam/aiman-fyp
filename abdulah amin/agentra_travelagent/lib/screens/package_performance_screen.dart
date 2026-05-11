import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/side_navigation.dart';
import '../models/package.dart';
import '../services/package_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class PackagePerformanceScreen extends StatefulWidget {
  const PackagePerformanceScreen({Key? key}) : super(key: key);

  @override
  State<PackagePerformanceScreen> createState() =>
      _PackagePerformanceScreenState();
}

class _PackagePerformanceScreenState extends State<PackagePerformanceScreen> {
  int _selectedNavIndex = 4;
  List<Package> _packages = [];
  int _totalBookings = 0;
  bool _isLoading = true;

  // Dummy performance data per package
  final Map<String, Map<String, dynamic>> _performanceData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      // Load real analytics data
      final response = await http.get(
        Uri.parse(ApiConfig.AGENT_ANALYTICS),
        headers: {'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final overview = data['overview'] ?? {};
        final List<dynamic> packagesData = data['packages'] ?? [];

        final List<Package> packages = [];
        final Map<String, Map<String, dynamic>> perfData = {};

        for (var item in packagesData) {
          if (item['package'] != null) {
            final pkg = Package.fromJson(item['package']);
            packages.add(pkg);
            
            final analytics = item['analytics'] ?? {};
            perfData[pkg.id] = {
              'views': analytics['views'] ?? 0,
              'clicks': analytics['clicks'] ?? 0,
              'bookings': analytics['bookings'] ?? 0,
              'conversionRate': (analytics['conversionRate'] ?? 0).toStringAsFixed(1),
            };
          }
        }

        if (mounted) {
          setState(() {
            _packages = packages;
            _totalBookings = overview['totalBookings'] ?? 0;
            _performanceData.clear();
            _performanceData.addAll(perfData);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading analytics: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport() async {
    if (_packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No packages to generate report for')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF Report...')),
    );

    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      // We'll use the first package as an example or provide a way to select
      // For now, let's generate a report for the top package
      final packageId = _topPackage?.id;
      if (packageId == null) return;

      final url = '${ApiConfig.BASE_URL}/analytics/package/$packageId/report';
      
      // In a real app, we'd use url_launcher or similar. 
      // For this web/desktop demo, we'll just show a success message.
      // But we call the endpoint to verify it works.
      final response = await http.get(
        Uri.parse(url),
        headers: {'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated for ${_topPackage!.title}!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Summary stats
  int get _totalViews => _performanceData.values
      .fold(0, (sum, p) => sum + (p['views'] as int));
  int get _totalClicks => _performanceData.values
      .fold(0, (sum, p) => sum + (p['clicks'] as int));
  double get _avgConversionRate => _performanceData.isEmpty
      ? 0
      : _performanceData.values
              .map((p) => double.tryParse(p['conversionRate']) ?? 0)
              .reduce((a, b) => a + b) /
          _performanceData.length;

  // Top package by bookings
  Package? get _topPackage {
    if (_packages.isEmpty) return null;
    return _packages.reduce((a, b) =>
        (_performanceData[a.id]?['bookings'] ?? 0) >
                (_performanceData[b.id]?['bookings'] ?? 0)
            ? a
            : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          SideNavigation(
            selectedIndex: _selectedNavIndex,
            onItemSelected: (index) {
              setState(() => _selectedNavIndex = index);
            },
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
                          const Text('Package Performance',
                              style: AppTextStyles.headingMedium),
                          Text(
                            'Track how your packages are performing',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      // Download Report Button
                      ElevatedButton.icon(
                        onPressed: _downloadReport,
                        icon: const Icon(Icons.picture_as_pdf_outlined,
                            color: Colors.white),
                        label: const Text('Generate Report',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ── Top Package ────────────────────────────
                              if (_topPackage != null) ...[
                                const Text(
                                  'Top Package',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B1E28),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTopPackageCard(_topPackage!),
                                const SizedBox(height: 32),
                              ],

                              // ── Summary Stats ──────────────────────────
                              const Text(
                                'Summary Stats',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B1E28),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.count(
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildStatCard(
                                    'Total Views',
                                    _totalViews.toString(),
                                    Icons.visibility_outlined,
                                    Colors.blue,
                                  ),
                                  _buildStatCard(
                                    'Total Clicks',
                                    _totalClicks.toString(),
                                    Icons.ads_click_outlined,
                                    Colors.purple,
                                  ),
                                  _buildStatCard(
                                    'Conversion Rate',
                                    '${_avgConversionRate.toStringAsFixed(1)}%',
                                    Icons.percent_outlined,
                                    Colors.green,
                                  ),
                                  _buildStatCard(
                                    'Total Bookings',
                                    _totalBookings.toString(),
                                    Icons.calendar_today_outlined,
                                    Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // ── All Packages Performance ───────────────
                              const Text(
                                'All Packages',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B1E28),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _packages.isEmpty
                                  ? const Center(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 40),
                                          Icon(
                                              Icons.inventory_2_outlined,
                                              size: 64,
                                              color: Colors.black12),
                                          SizedBox(height: 16),
                                          Text('No packages yet'),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: _packages
                                          .map((p) =>
                                              _buildPackagePerformanceRow(p))
                                          .toList(),
                                    ),
                            ],
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

  Widget _buildTopPackageCard(Package package) {
    final perf = _performanceData[package.id] ?? {};
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Package image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              ApiConfig.getImageUrl(package.image),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 24),
          // Package info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${package.duration} | PKR ${package.price}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTopStat('${perf['views'] ?? 0}', 'Views'),
                    const SizedBox(width: 24),
                    _buildTopStat('${perf['clicks'] ?? 0}', 'Clicks'),
                    const SizedBox(width: 24),
                    _buildTopStat('${perf['bookings'] ?? 0}', 'Bookings'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7D848D),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1E28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagePerformanceRow(Package package) {
    final perf = _performanceData[package.id] ?? {};
    final int views = perf['views'] ?? 0;
    final int clicks = perf['clicks'] ?? 0;
    final int bookings = perf['bookings'] ?? 0;
    final String convRate = perf['conversionRate'] ?? '0';
    final double progress = views > 0 ? clicks / views : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiConfig.getImageUrl(package.image),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Title & duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B1E28),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${package.duration} | PKR ${package.price}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7D848D),
                      ),
                    ),
                  ],
                ),
              ),
              // Stats chips
              Row(
                children: [
                  _buildChip('$views Views', Colors.blue),
                  const SizedBox(width: 8),
                  _buildChip('$clicks Clicks', Colors.purple),
                  const SizedBox(width: 8),
                  _buildChip('$bookings Bookings', Colors.orange),
                  const SizedBox(width: 8),
                  _buildChip('$convRate% CVR', Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              const Text(
                'Click Rate',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7D848D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1E28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}