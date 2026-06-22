import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:zen_b2b/main.dart';
import 'package:zen_b2b/state/app_state.dart' show AppState, AppMode;

void main() {
  testWidgets('Dealer login renders in panel mode when logged out', (WidgetTester tester) async {
    final app = AppState()..setAppMode(AppMode.panel);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: app,
        child: const ZenB2bApp(),
      ),
    );
    await tester.pump();

    // Panel mode + logged out → dealer login with the Giriş Yap button.
    expect(find.text('Giriş Yap'), findsOneWidget);
  });

  testWidgets('Storefront renders in storefront mode when logged out', (WidgetTester tester) async {
    final app = AppState()..setAppMode(AppMode.storefront);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: app,
        child: const ZenB2bApp(),
      ),
    );
    await tester.pump();

    // Default mode is storefront → public shop header is shown.
    expect(find.text('ZenShop'), findsOneWidget);
    expect(find.text('Bayi Girişi'), findsWidgets);
  });
}
