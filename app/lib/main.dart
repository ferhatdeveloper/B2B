import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.restoreSession();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
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
        builder: (context, app, _) => app.isLoggedIn ? const HomeShell() : const LoginScreen(),
      ),
    );
  }
}
