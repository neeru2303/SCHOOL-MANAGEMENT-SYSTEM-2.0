import 'package:flutter/material.dart';

import '../providers/platform_auth_provider.dart';
import '../../platform_admin/screens/platform_login_screen.dart';
import '../../platform_admin/screens/platform_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlatformAuthController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.status) {
          case PlatformAuthStatus.initializing:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case PlatformAuthStatus.authenticated:
            return PlatformDashboardScreen(onLogout: controller.logout);

          case PlatformAuthStatus.unauthenticated:
            return PlatformLoginScreen(onAuthenticated: () {});
        }
      },
    );
  }
}
