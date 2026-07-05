import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'storefront/storefront_shell.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: ExfinB2bApp()));
}

class ExfinB2bApp extends ConsumerWidget {
  const ExfinB2bApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showStorefront = ref.watch(showStorefrontProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return MaterialApp(
      title: 'EXFIN B2B',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: showStorefront
          ? const StorefrontShell()
          : isLoggedIn
              ? const HomeShell()
              : const LoginScreen(),
    );
  }
}
