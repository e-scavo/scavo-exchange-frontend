import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scavo_exchange_frontend/app/responsive_app_shell.dart';

void main() {
  testWidgets('responsive shell renders title and destination labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveAppShell(
          title: 'SCAVO Exchange',
          selectedIndex: 0,
          destinations: [
            ShellDestination(
              label: 'Bootstrap',
              icon: Icons.home_outlined,
              onTap: () {},
            ),
            ShellDestination(label: 'Login', icon: Icons.login, onTap: () {}),
            ShellDestination(
              label: 'Wallet',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () {},
            ),
          ],
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('SCAVO Exchange'), findsOneWidget);
    expect(find.text('Bootstrap'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
  });
}
