import 'package:flutter/material.dart';

import '../modules/auth/ui/login_page.dart';
import '../modules/auth/ui/session_page.dart';
import '../modules/system/ui/bootstrap_page.dart';

class AppRouter {
  static const bootstrap = '/';
  static const login = '/login';
  static const session = '/session';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case session:
        return MaterialPageRoute<void>(
          builder: (_) => const SessionPage(),
          settings: settings,
        );
      case bootstrap:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const BootstrapPage(),
          settings: settings,
        );
    }
  }
}
