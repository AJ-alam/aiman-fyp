import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/side_navigation_drawer.dart';
import '../widgets/custom_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.backgroundLight,
              child: Icon(Icons.person, color: AppColors.primary, size: 24),
            ),
          ),
        ],
      ),
      drawer: const SideNavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            RichText(
              text: TextSpan(
                style: AppTextStyles.headingLarge.copyWith(fontSize: 26),
                children: const [
                  TextSpan(
                    text: 'Explore the\nBeautiful ',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'world!',
                    style: TextStyle(color: AppColors.orange),
                  ),
                ],
              ),
            ),
            // Empty State
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No Packages',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: '+ Add New Package',
                      onPressed: () {
                        Navigator.pushNamed(context, '/create-package');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

