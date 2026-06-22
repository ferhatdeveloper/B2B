import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'storefront/storefront_shell.dart';
import 'theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ZenB2bApp(),
    ),
  );
}

class ZenB2bApp extends StatelessWidget {
  const ZenB2bApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zen B2B/C2C',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Consumer<AppState>(
        builder: (context, app, _) {
          if (app.showStorefront) return const StorefrontShell();
          if (app.isLoggedIn) return const HomeShell();
          return const LoginScreen();
        },
      ),
    );
  }
}
