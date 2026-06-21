import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:zen_b2b/main.dart';
import 'package:zen_b2b/state/app_state.dart';

void main() {
  testWidgets('Login screen renders when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const ZenB2bApp(),
      ),
    );
    await tester.pump();

    // Login screen shows the brand and the Giriş Yap button.
    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.text('Tekrar hoş geldiniz'), findsOneWidget);
  });
}
