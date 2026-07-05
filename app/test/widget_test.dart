import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exfin_b2b/core/enums/app_enums.dart';
import 'package:exfin_b2b/core/providers/app_providers.dart';
import 'package:exfin_b2b/main.dart';

import 'package:exfin_b2b/core/providers/app_settings_provider.dart';

class _PanelModeSettings extends AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings(appMode: AppMode.panel);
}

void main() {
  testWidgets('Dealer login renders in panel mode when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(_PanelModeSettings.new),
        ],
        child: const ExfinB2bApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Giriş Yap'), findsOneWidget);
  });

  testWidgets('Storefront renders in storefront mode when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ExfinB2bApp(),
      ),
    );
    await tester.pump();

    expect(find.text('EXFIN'), findsWidgets);
    expect(find.text('Bayi Girişi'), findsWidgets);
  });
}
