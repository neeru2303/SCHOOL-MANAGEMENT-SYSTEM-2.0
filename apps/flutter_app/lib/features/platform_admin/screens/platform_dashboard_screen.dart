import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';

class PlatformDashboardScreen extends StatefulWidget {
  const PlatformDashboardScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<PlatformDashboardScreen> createState() =>
      _PlatformDashboardScreenState();
}

class _PlatformDashboardScreenState extends State<PlatformDashboardScreen> {
  int selectedIndex = 0;

  String selectedSchool = 'All Schools';
  String selectedAcademicSession = '2026-27';

  bool isRefreshing = false;

  final List<_NavigationItem> navigationItems = [
    _NavigationItem(title: 'Overview', icon: Icons.dashboard_rounded),
    _NavigationItem(title: 'School Management', icon: Icons.apartment_rounded),
    _NavigationItem(title: 'Platform Users', icon: Icons.people_alt_rounded),
    _NavigationItem(
      title: 'Roles & Permissions',
      icon: Icons.admin_panel_settings_rounded,
    ),
    _NavigationItem(title: 'Audit Logs', icon: Icons.history_rounded),
    _NavigationItem(title: 'System Health', icon: Icons.monitor_heart_rounded),
    _NavigationItem(title: 'Platform Settings', icon: Icons.settings_rounded),
  ];

  Future<void> _refreshDashboard() async {
    setState(() => isRefreshing = true);

    // Backend dashboard API will be connected here.

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;
        final isTablet = constraints.maxWidth >= 700;

        return Scaffold(
          drawer: isDesktop
              ? null
              : Drawer(width: 270, child: _buildSidebar(isDark)),
          body: Row(
            children: [
              if (isDesktop) SizedBox(width: 260, child: _buildSidebar(isDark)),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, isDesktop, isTablet, isDark),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshDashboard,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: selectedIndex == 0
                              ? _buildOverview(context, isTablet, isDark)
                              : _buildPlaceholderPage(context, isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // SIDEBAR
  // --------------------------------------------------

  Widget _buildSidebar(bool isDark) {
    return Container(
      color: const Color(0xFF102957),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 25, 15, 25),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 27,
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
                        SizedBox(height: 3),
                        Text(
                          'Platform Administration',
                          style: TextStyle(
                            color: Color(0xFFB9C9E5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 5, 15, 12),
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: navigationItems.length,
                itemBuilder: (context, index) {
                  final item = navigationItems[index];
                  final selected = selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() => selectedIndex = index);

                        if (Scaffold.of(context).hasDrawer) {
                          Navigator.maybePop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF3B82F6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFFB9C9E5),
                              size: 20,
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFFD5E0F2),
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFF59E0B),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Platform Administrator',
                            style: TextStyle(
                              color: Color(0xFFB9C9E5),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
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

  // --------------------------------------------------
  // TOP BAR
  // --------------------------------------------------

  Widget _buildTopBar(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
    bool isDark,
  ) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 15),
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
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  navigationItems[selectedIndex].title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Platform control centre',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          if (isDesktop || isTablet) ...[
            _buildSchoolSelector(context),
            const SizedBox(width: 10),
            _buildAcademicSessionSelector(context),
            const SizedBox(width: 10),
          ],

          PopupMenuButton<ThemeMode>(
            tooltip: 'Change appearance',
            icon: const Icon(Icons.palette_outlined),
            onSelected: (mode) {
              ThemeController.instance.setThemeMode(mode);
            },
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
              _showMessage(context, 'Notifications will be connected later.');
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),

          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF1E3A8A),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await widget.onLogout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('My Profile')),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolSelector(BuildContext context) {
    return _selector(
      context,
      icon: Icons.apartment_rounded,
      value: selectedSchool,
      items: const ['All Schools', 'Sandipani Academy'],
      onChanged: (value) {
        setState(() {
          selectedSchool = value!;
        });
      },
    );
  }

  Widget _buildAcademicSessionSelector(BuildContext context) {
    return _selector(
      context,
      icon: Icons.calendar_month_rounded,
      value: selectedAcademicSession,
      items: const ['2025-26', '2026-27', '2027-28'],
      onChanged: (value) {
        setState(() {
          selectedAcademicSession = value!;
        });
      },
    );
  }

  Widget _selector(
    BuildContext context, {
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              iconSize: 17,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // OVERVIEW
  // --------------------------------------------------

  Widget _buildOverview(BuildContext context, bool isTablet, bool isDark) {
    final width = MediaQuery.of(context).size.width;

    final columns = width >= 1300
        ? 4
        : width >= 800
        ? 2
        : 1;

    return ListView(
      key: const ValueKey('overview'),
      padding: EdgeInsets.all(isTablet ? 28 : 16),
      children: [
        _buildWelcomeSection(context),

        const SizedBox(height: 22),

        _buildSampleDataNotice(context),

        const SizedBox(height: 22),

        _buildSectionTitle(
          context,
          'Platform Overview',
          'Lifetime platform statistics',
        ),

        const SizedBox(height: 15),

        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: width >= 1300
              ? 1.8
              : width >= 800
              ? 2.0
              : 2.5,
          children: const [
            _MetricCard(
              title: 'Total Registered Schools',
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

        const SizedBox(height: 28),

        _buildSectionTitle(
          context,
          'Registration Analytics',
          'Illustrative monthly school registrations',
        ),

        const SizedBox(height: 15),

        _buildRegistrationChart(context),

        const SizedBox(height: 28),

        _buildSectionTitle(
          context,
          'Recent Platform Activity',
          'Latest administrative events',
        ),

        const SizedBox(height: 15),

        _buildRecentActivity(context),

        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                  'Monitor schools, manage platform users, '
                  'and control your School ERP ecosystem.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PLATFORM ADMINISTRATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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

  Widget _buildSampleDataNotice(BuildContext context) {
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
              'Preview mode: All dashboard figures and activity '
              'are sample data, not live platform records.',
              style: TextStyle(color: Color(0xFF805B19), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
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
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // REGISTRATION CHART
  // --------------------------------------------------

  Widget _buildRegistrationChart(BuildContext context) {
    final months = [
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
      height: 265,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New School Registrations',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: month.$2 / 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      (
        'New school registered',
        'Green Valley Public School',
        'Today, 10:30 AM',
        Icons.add_business_rounded,
        const Color(0xFF16A34A),
      ),
      (
        'School status updated',
        'ABC International School',
        'Yesterday, 3:45 PM',
        Icons.edit_rounded,
        const Color(0xFF3B82F6),
      ),
      (
        'Platform user created',
        'New administrator account',
        'Yesterday, 11:20 AM',
        Icons.person_add_alt_rounded,
        const Color(0xFF8B5CF6),
      ),
      (
        'School suspended',
        'Demo Public School',
        '06 Nov, 2:15 PM',
        Icons.pause_circle_outline_rounded,
        const Color(0xFFF59E0B),
      ),
    ];

    return Container(
      decoration: _cardDecoration(context),
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
  // PLACEHOLDER PAGES
  // --------------------------------------------------

  Widget _buildPlaceholderPage(BuildContext context, bool isDark) {
    return Center(
      key: ValueKey(selectedIndex),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              navigationItems[selectedIndex].icon,
              size: 65,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 18),
            Text(
              navigationItems[selectedIndex].title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'This module will be implemented in the next phase.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Theme.of(context).dividerColor),
    );
  }

  void _showMessage(BuildContext context, String message) {
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

// --------------------------------------------------
// NAVIGATION MODEL
// --------------------------------------------------

class _NavigationItem {
  const _NavigationItem({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
