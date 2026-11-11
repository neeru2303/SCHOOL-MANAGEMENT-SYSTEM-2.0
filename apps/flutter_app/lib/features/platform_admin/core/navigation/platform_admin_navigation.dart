import 'package:flutter/material.dart';

class PlatformNavItem {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const PlatformNavItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}

class PlatformNavGroup {
  final String title;
  final List<PlatformNavItem> items;

  const PlatformNavGroup({required this.title, required this.items});
}

class PlatformAdminNavigation {
  PlatformAdminNavigation._();

  static const List<PlatformNavGroup> groups = [
    PlatformNavGroup(
      title: 'OVERVIEW',
      items: [
        PlatformNavItem(
          id: 'dashboard',
          title: 'Dashboard',
          icon: Icons.dashboard_rounded,
          description: 'Platform statistics and administrative overview.',
        ),
      ],
    ),
    PlatformNavGroup(
      title: 'SCHOOL MANAGEMENT',
      items: [
        PlatformNavItem(
          id: 'register_school',
          title: 'Register School',
          icon: Icons.add_business_rounded,
          description: 'Register a new school on the platform.',
        ),
        PlatformNavItem(
          id: 'schools',
          title: 'All Schools',
          icon: Icons.apartment_rounded,
          description: 'View and manage registered schools.',
        ),
        PlatformNavItem(
          id: 'branches',
          title: 'Branch Management',
          icon: Icons.account_tree_rounded,
          description: 'Manage school branches.',
        ),
        PlatformNavItem(
          id: 'subscriptions',
          title: 'Subscription Plans',
          icon: Icons.workspace_premium_rounded,
          description: 'Manage platform subscription plans.',
        ),
      ],
    ),
    PlatformNavGroup(
      title: 'PLATFORM USERS',
      items: [
        PlatformNavItem(
          id: 'users',
          title: 'All Users',
          icon: Icons.people_alt_rounded,
          description: 'View and manage platform administrators.',
        ),
        PlatformNavItem(
          id: 'create_user',
          title: 'Create User',
          icon: Icons.person_add_alt_rounded,
          description: 'Create a new platform user.',
        ),
        PlatformNavItem(
          id: 'user_activity',
          title: 'User Activity',
          icon: Icons.manage_accounts_rounded,
          description: 'Review platform user activity.',
        ),
      ],
    ),
    PlatformNavGroup(
      title: 'ACCESS CONTROL',
      items: [
        PlatformNavItem(
          id: 'roles',
          title: 'Platform Roles',
          icon: Icons.admin_panel_settings_rounded,
          description: 'Manage platform roles.',
        ),
        PlatformNavItem(
          id: 'permissions',
          title: 'Permissions',
          icon: Icons.verified_user_rounded,
          description: 'Manage access permissions.',
        ),
        PlatformNavItem(
          id: 'role_assignments',
          title: 'Role Assignments',
          icon: Icons.assignment_ind_rounded,
          description: 'Assign roles to platform users.',
        ),
      ],
    ),
    PlatformNavGroup(
      title: 'ACADEMIC MANAGEMENT',
      items: [
        PlatformNavItem(
          id: 'academic_schools',
          title: 'Select School',
          icon: Icons.domain_rounded,
          description: 'Select a school to inspect its academic data.',
        ),
        PlatformNavItem(
          id: 'academic_sessions',
          title: 'Academic Sessions',
          icon: Icons.calendar_month_rounded,
          description: 'Manage school-specific academic sessions.',
        ),
        PlatformNavItem(
          id: 'historical_sessions',
          title: 'Historical Sessions',
          icon: Icons.history_edu_rounded,
          description: 'Access historical academic records.',
        ),
      ],
    ),
    PlatformNavGroup(
      title: 'SECURITY & MONITORING',
      items: [
        PlatformNavItem(
          id: 'audit_logs',
          title: 'Audit Logs',
          icon: Icons.history_rounded,
          description: 'Review administrative audit records.',
        ),
        PlatformNavItem(
          id: 'login_activity',
          title: 'Login Activity',
          icon: Icons.login_rounded,
          description: 'Review authentication activity.',
        ),
        PlatformNavItem(
          id: 'active_sessions',
          title: 'Active Sessions',
          icon: Icons.devices_rounded,
          description: 'Review and revoke active sessions.',
        ),
        PlatformNavItem(
          id: 'security_events',
          title: 'Security Events',
          icon: Icons.security_rounded,
          description: 'Monitor security-related events.',
        ),
      ],
    ),
    PlatformNavGroup(
      title: 'SYSTEM ADMINISTRATION',
      items: [
        PlatformNavItem(
          id: 'system_health',
          title: 'System Health',
          icon: Icons.monitor_heart_rounded,
          description: 'Monitor platform services.',
        ),
        PlatformNavItem(
          id: 'database',
          title: 'Database Status',
          icon: Icons.storage_rounded,
          description: 'Inspect database health.',
        ),
        PlatformNavItem(
          id: 'api',
          title: 'API Status',
          icon: Icons.cloud_rounded,
          description: 'Inspect backend API health.',
        ),
        PlatformNavItem(
          id: 'settings',
          title: 'Platform Settings',
          icon: Icons.settings_rounded,
          description: 'Configure global platform settings.',
        ),
      ],
    ),
  ];

  static const List<PlatformNavGroup> accountGroup = [
    PlatformNavGroup(
      title: 'ACCOUNT',
      items: [
        PlatformNavItem(
          id: 'profile',
          title: 'My Profile',
          icon: Icons.person_outline_rounded,
          description: 'Manage your administrator profile.',
        ),
        PlatformNavItem(
          id: 'security_settings',
          title: 'Security Settings',
          icon: Icons.lock_outline_rounded,
          description: 'Manage account security.',
        ),
      ],
    ),
  ];

  static List<PlatformNavGroup> get allGroups => [...groups, ...accountGroup];

  static List<PlatformNavItem> get allItems => [
    for (final group in allGroups) ...group.items,
  ];

  static PlatformNavItem findById(String id) {
    return allItems.firstWhere((item) => item.id == id);
  }
}
