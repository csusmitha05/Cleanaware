import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthWrapperScreen extends StatelessWidget {
  static const routeName = '/auth-wrapper';

  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data ?? authService.currentUser;

            if (user != null) {
              if (authService.isCurrentUserPasswordProvider &&
                  !authService.isCurrentUserEmailVerified) {
                return const VerifyEmailScreen();
              }
              NotificationService.saveUserTokenIfLoggedIn(authService);
              return const DashboardScreen();
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}
