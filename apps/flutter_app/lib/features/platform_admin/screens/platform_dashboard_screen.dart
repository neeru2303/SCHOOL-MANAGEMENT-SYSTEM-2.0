import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../core/navigation/platform_admin_navigation.dart';

class PlatformDashboardScreen extends StatefulWidget {
  const PlatformDashboardScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<PlatformDashboardScreen> createState() =>
      _PlatformDashboardScreenState();
}

class _PlatformDashboardScreenState extends State<PlatformDashboardScreen> {
  String selectedPage = 'dashboard';

  PlatformNavItem get currentPage =>
      PlatformAdminNavigation.findById(selectedPage);

  void _navigate(String pageId) {
    setState(() => selectedPage = pageId);

    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;
        final isTablet = constraints.maxWidth >= 700;

        return Scaffold(
          drawer: isDesktop
              ? null
              : Drawer(width: 285, child: _buildSidebar(isDrawer: true)),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Row(
              children: [
                if (isDesktop)
                  SizedBox(width: 265, child: _buildSidebar(isDrawer: false)),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(isDesktop: isDesktop, isTablet: isTablet),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: selectedPage == 'dashboard'
                              ? _buildDashboardOverview(isTablet)
                              : _buildModulePage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // SIDEBAR
  // --------------------------------------------------

  Widget _buildSidebar({required bool isDrawer}) {
    return Container(
      color: const Color(0xFF102957),
      child: SafeArea(
        child: Column(
          children: [
            _buildBrand(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 15),
                children: [
                  for (final group in PlatformAdminNavigation.allGroups) ...[
                    _buildGroupTitle(group.title),
                    const SizedBox(height: 7),
                    for (final item in group.items)
                      _buildNavigationItem(item, isDrawer: isDrawer),
                    const SizedBox(height: 15),
                  ],
                ],
              ),
            ),

            _buildAdminProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 23, 15, 25),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCHOOL ERP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Platform Administration',
                  style: TextStyle(color: Color(0xFFB9C9E5), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 5),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.48),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  Widget _buildNavigationItem(PlatformNavItem item, {required bool isDrawer}) {
    final selected = selectedPage == item.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            setState(() => selectedPage = item.id);

            if (isDrawer) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 19,
                  color: selected ? Colors.white : const Color(0xFFB9C9E5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFD5E0F2),
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Container(
      margin: const EdgeInsets.all(13),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFF59E0B),
            child: Icon(Icons.person_rounded, color: Colors.white),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Platform Administrator',
                  style: TextStyle(color: Color(0xFFB9C9E5), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // TOP BAR
  // --------------------------------------------------

  Widget _buildTopBar({required bool isDesktop, required bool isTablet}) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 27 : 13),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu_rounded),
                );
              },
            ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPage.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Platform control centre',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<ThemeMode>(
            tooltip: 'Appearance',
            icon: const Icon(Icons.palette_outlined),
            onSelected: ThemeController.instance.setThemeMode,
            itemBuilder: (context) => const [
              PopupMenuItem(value: ThemeMode.light, child: Text('Light theme')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dark theme')),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System default'),
              ),
            ],
          ),

          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              _showMessage(
                'Notification integration will be implemented later.',
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),

          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) async {
              if (value == 'logout') {
                await widget.onLogout();
              } else if (value == 'profile') {
                _navigate('profile');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('My Profile')),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 9),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DASHBOARD OVERVIEW
  // --------------------------------------------------

  Widget _buildDashboardOverview(bool isTablet) {
    return LayoutBuilder(
      key: const ValueKey('dashboard'),
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1250
            ? 4
            : constraints.maxWidth >= 650
            ? 2
            : 1;

        return RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: ListView(
            padding: EdgeInsets.all(isTablet ? 27 : 16),
            children: [
              _buildWelcomeBanner(),

              const SizedBox(height: 20),

              _buildSampleDataNotice(),

              const SizedBox(height: 25),

              _buildSectionHeading(
                'Platform Overview',
                'Lifetime platform statistics',
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 3.0 : 1.8,
                children: const [
                  _MetricCard(
                    title: 'Registered Schools',
                    value: '248',
                    subtitle: 'All-time registrations',
                    icon: Icons.apartment_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                  _MetricCard(
                    title: 'Active Schools',
                    value: '221',
                    subtitle: 'Currently active',
                    icon: Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                  ),
                  _MetricCard(
                    title: 'Suspended Schools',
                    value: '12',
                    subtitle: 'Currently suspended',
                    icon: Icons.pause_circle_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  _MetricCard(
                    title: 'Platform Users',
                    value: '36',
                    subtitle: 'Platform administrators',
                    icon: Icons.people_alt_rounded,
                    color: Color(0xFF8B5CF6),
                  ),
                ],
              ),

              const SizedBox(height: 27),

              _buildSectionHeading(
                'Quick Actions',
                'Frequently used platform operations',
              ),

              const SizedBox(height: 14),

              _buildQuickActions(),

              const SizedBox(height: 27),

              _buildSectionHeading(
                'Registration Analytics',
                'Illustrative monthly school registrations',
              ),

              const SizedBox(height: 14),

              _buildRegistrationChart(),

              const SizedBox(height: 27),

              _buildSectionHeading(
                'Recent Platform Activity',
                'Illustrative administrative events',
              ),

              const SizedBox(height: 14),

              _buildRecentActivity(),

              const SizedBox(height: 27),

              _buildSectionHeading('System Monitoring', 'Integration status'),

              const SizedBox(height: 14),

              _buildSystemMonitoring(),

              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, Super Admin!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Manage schools, platform users, permissions '
                  'and the entire School ERP ecosystem.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'PLATFORM ADMINISTRATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.admin_panel_settings_rounded,
            size: 75,
            color: Color(0x66FFFFFF),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleDataNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFF5D58A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFB7791F), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview mode: Statistics and activity shown here '
              'are illustrative sample data, not live records.',
              style: TextStyle(color: Color(0xFF805B19), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // QUICK ACTIONS
  // --------------------------------------------------

  Widget _buildQuickActions() {
    final actions = [
      (
        'Register School',
        Icons.add_business_rounded,
        'register_school',
        const Color(0xFF3B82F6),
      ),
      (
        'View Schools',
        Icons.apartment_rounded,
        'schools',
        const Color(0xFF16A34A),
      ),
      (
        'Manage Users',
        Icons.people_alt_rounded,
        'users',
        const Color(0xFF8B5CF6),
      ),
      (
        'Audit Logs',
        Icons.history_rounded,
        'audit_logs',
        const Color(0xFFF59E0B),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) {
        return SizedBox(
          width: 190,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigate(action.$3),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: action.$4.withValues(alpha: 0.12),
                    child: Icon(action.$2, size: 19, color: action.$4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action.$1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --------------------------------------------------
  // REGISTRATION CHART
  // --------------------------------------------------

  Widget _buildRegistrationChart() {
    const months = [
      ('Jan', 12),
      ('Feb', 18),
      ('Mar', 15),
      ('Apr', 25),
      ('May', 20),
      ('Jun', 32),
      ('Jul', 27),
      ('Aug', 38),
      ('Sep', 30),
      ('Oct', 45),
      ('Nov', 36),
      ('Dec', 48),
    ];

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New School Registrations',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.map((month) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${month.$2}',
                          style: const TextStyle(fontSize: 9),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: month.$2 / 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(month.$1, style: const TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // RECENT ACTIVITY
  // --------------------------------------------------

  Widget _buildRecentActivity() {
    final activities = [
      (
        'New school registered',
        'Green Valley Public School',
        'Sample event',
        Icons.add_business_rounded,
        const Color(0xFF16A34A),
      ),
      (
        'School status updated',
        'ABC International School',
        'Sample event',
        Icons.edit_rounded,
        const Color(0xFF3B82F6),
      ),
      (
        'Platform user created',
        'New administrator account',
        'Sample event',
        Icons.person_add_alt_rounded,
        const Color(0xFF8B5CF6),
      ),
      (
        'School suspended',
        'Demo Public School',
        'Sample event',
        Icons.pause_circle_outline_rounded,
        const Color(0xFFF59E0B),
      ),
    ];

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: activities.map((activity) {
          return ListTile(
            leading: CircleAvatar(
              radius: 19,
              backgroundColor: activity.$5.withValues(alpha: 0.12),
              child: Icon(activity.$4, size: 18, color: activity.$5),
            ),
            title: Text(
              activity.$1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${activity.$2} • ${activity.$3}',
              style: const TextStyle(fontSize: 10),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --------------------------------------------------
  // SYSTEM MONITORING
  // --------------------------------------------------

  Widget _buildSystemMonitoring() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primaryLight),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'System monitoring integration is pending. '
              'Live service health will appear here after '
              'the monitoring APIs are implemented.',
              style: TextStyle(fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MODULE LANDING PAGES
  // --------------------------------------------------

  Widget _buildModulePage() {
    return ListView(
      key: ValueKey(selectedPage),
      padding: const EdgeInsets.all(25),
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
                child: Icon(
                  currentPage.icon,
                  size: 27,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                currentPage.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentPage.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(),
              const SizedBox(height: 15),
              const Text(
                'Module implementation pending',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'The navigation is ready. This module will be '
                'implemented with its own Flutter screens, '
                'NestJS APIs, permission checks and database '
                'operations. No sample operation is presented '
                'as a real administrative action.',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Theme.of(context).dividerColor),
    );
  }

  Future<void> _refreshDashboard() async {
    // Live dashboard API will be connected in a later phase.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// --------------------------------------------------
// METRIC CARD
// --------------------------------------------------

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 21),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
