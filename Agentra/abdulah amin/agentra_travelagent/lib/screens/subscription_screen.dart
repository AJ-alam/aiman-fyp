import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/side_navigation.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedNavIndex = 6;

  bool _isTrialActive = false;
  final bool _isPremium = false;
  int _daysLeft = 20;
  final int _promotedUsers = 100;
  final double _chatbotEngagement = 20.0;

  void _activateTrial() {
    setState(() {
      _isTrialActive = true;
      _daysLeft = 30;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Free trial activated! Enjoy 30 days of AI tools.'),
        backgroundColor: Colors.green,
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
                      bottom:
                          BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Tools & Subscription',
                              style: AppTextStyles.headingMedium),
                          Text(
                            'Supercharge your travel business with AI',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isPremium
                              ? Colors.amber.withOpacity(0.1)
                              : _isTrialActive
                                  ? Colors.green.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isPremium
                                ? Colors.amber
                                : _isTrialActive
                                    ? Colors.green
                                    : AppColors.primary,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPremium
                                  ? Icons.workspace_premium
                                  : Icons.card_membership_outlined,
                              size: 16,
                              color: _isPremium
                                  ? Colors.amber
                                  : _isTrialActive
                                      ? Colors.green
                                      : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isPremium
                                  ? 'Premium Plan'
                                  : _isTrialActive
                                      ? 'Free Trial Active'
                                      : 'Free Plan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _isPremium
                                    ? Colors.amber
                                    : _isTrialActive
                                        ? Colors.green
                                        : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── AI Tools Card ──────────────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
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
                                  // Card header
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                              Icons.smart_toy_outlined,
                                              color: Colors.white,
                                              size: 32),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'AI Sales Agent & Customer Support Chatbot',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star,
                                                        color: Colors.white,
                                                        size: 14),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Free 1 Month Trial',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_isTrialActive)
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'Active',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Days Left: $_daysLeft',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Card body
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'What you get:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1B1E28),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...[
                                          {
                                            'icon': Icons.campaign_outlined,
                                            'text': 'Promote your packages to suitable users automatically',
                                            'color': Colors.blue,
                                          },
                                          {
                                            'icon': Icons.chat_bubble_outline,
                                            'text': 'Let AI chatbot answer queries about your packages 24/7',
                                            'color': Colors.purple,
                                          },
                                          {
                                            'icon': Icons.trending_up_outlined,
                                            'text': 'Get more bookings with AI-powered recommendations',
                                            'color': Colors.green,
                                          },
                                          {
                                            'icon': Icons.analytics_outlined,
                                            'text': 'Track promotion performance and chatbot engagement',
                                            'color': Colors.orange,
                                          },
                                        ].map((feature) => Padding(
                                              padding: const EdgeInsets.only(bottom: 16),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: (feature['color'] as Color)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(
                                                      feature['icon'] as IconData,
                                                      color: feature['color'] as Color,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      feature['text'] as String,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Color(0xFF4A4A4A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                        if (_isTrialActive) ...[
                                          const SizedBox(height: 8),
                                          const Divider(),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Your AI Performance',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1B1E28),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildStatBox(
                                                  'Packages Promoted to',
                                                  '$_promotedUsers Users',
                                                  Icons.people_outlined,
                                                  Colors.blue,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildStatBox(
                                                  'Chatbot Engagement',
                                                  '$_chatbotEngagement%',
                                                  Icons.chat_bubble_outline,
                                                  Colors.purple,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildStatBox(
                                                  'Days Remaining',
                                                  '$_daysLeft days',
                                                  Icons.timer_outlined,
                                                  Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: !_isTrialActive
                                              ? ElevatedButton(
                                                  onPressed: _activateTrial,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Activate Free Trial',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                )
                                              : OutlinedButton(
                                                  onPressed: null,
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                    side: const BorderSide(
                                                        color: Colors.green),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '✓ Trial Active',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 16,
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
                            ),
                            const SizedBox(height: 32),

                            // ── Upgrade Banner ─────────────────────────
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade700,
                                    Colors.orange.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.workspace_premium,
                                      color: Colors.white, size: 48),
                                  const SizedBox(width: 24),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upgrade to Premium',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Get unlimited AI promotion, priority listings and advanced analytics',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  ElevatedButton(
                                    // ✅ NOW NAVIGATES TO PAYMENT PAGE
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/premium-payment'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Upgrade Now',
                                      style: TextStyle(
                                        color: Colors.amber.shade700,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStatBox(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7D848D),
            ),
          ),
        ],
      ),
    );
  }
}