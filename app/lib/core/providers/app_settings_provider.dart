import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/session_store.dart';
import '../enums/app_enums.dart';
import 'auth_provider.dart';

class AppSettings {
  const AppSettings({
    this.appMode = AppMode.storefront,
    this.storeTheme = StoreTheme.zetem,
    this.dealerLoginRequested = false,
    this.storefrontPreview = false,
  });

  final AppMode appMode;
  final StoreTheme storeTheme;
  final bool dealerLoginRequested;
  final bool storefrontPreview;

  AppSettings copyWith({
    AppMode? appMode,
    StoreTheme? storeTheme,
    bool? dealerLoginRequested,
    bool? storefrontPreview,
  }) {
    return AppSettings(
      appMode: appMode ?? this.appMode,
      storeTheme: storeTheme ?? this.storeTheme,
      dealerLoginRequested: dealerLoginRequested ?? this.dealerLoginRequested,
      storefrontPreview: storefrontPreview ?? this.storefrontPreview,
    );
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

final showStorefrontProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final isLoggedIn = ref.watch(isLoggedInProvider);
  return settings.storefrontPreview ||
      (!isLoggedIn && settings.appMode == AppMode.storefront && !settings.dealerLoginRequested);
});

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _modeKey = 'exfin_b2b_appmode';
  static const _themeKey = 'exfin_b2b_store_theme';

  @override
  AppSettings build() => _restore();

  AppSettings _restore() {
    var settings = const AppSettings();
    final mode = readKey(_modeKey);
    if (mode == AppMode.panel.name) {
      settings = settings.copyWith(appMode: AppMode.panel);
    } else if (mode == AppMode.storefront.name) {
      settings = settings.copyWith(appMode: AppMode.storefront);
    }
    final theme = readKey(_themeKey);
    for (final value in StoreTheme.values) {
      if (value.name == theme) {
        settings = settings.copyWith(storeTheme: value);
      }
    }
    return settings;
  }

  void setAppMode(AppMode mode) {
    state = state.copyWith(appMode: mode);
    writeKey(_modeKey, mode.name);
  }

  void setStoreTheme(StoreTheme theme) {
    state = state.copyWith(storeTheme: theme);
    writeKey(_themeKey, theme.name);
  }

  void requestDealerLogin() {
    state = state.copyWith(dealerLoginRequested: true, storefrontPreview: false);
  }

  void backToStorefront() {
    state = state.copyWith(dealerLoginRequested: false, storefrontPreview: false);
  }

  void previewStorefront() {
    state = state.copyWith(storefrontPreview: true);
  }

  void exitStorefrontPreview() {
    state = state.copyWith(storefrontPreview: false);
  }

  void resetOnLogout() {
    state = state.copyWith(dealerLoginRequested: false, storefrontPreview: false);
  }
}
