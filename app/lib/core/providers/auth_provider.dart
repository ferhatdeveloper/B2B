import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../utils/session_store.dart';
import 'cart_provider.dart';
import 'app_settings_provider.dart';
import 'service_providers.dart';

final authProvider = NotifierProvider<AuthNotifier, SessionUser?>(AuthNotifier.new);

final isLoggedInProvider = Provider<bool>((ref) => ref.watch(authProvider) != null);

class AuthNotifier extends Notifier<SessionUser?> {
  @override
  SessionUser? build() => _restore();

  SessionUser? _restore() {
    try {
      final raw = readSession();
      if (raw != null && raw.isNotEmpty) {
        return SessionUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Stay logged out on restore failure.
    }
    return null;
  }

  void _persist() {
    final user = state;
    if (user == null) {
      clearSession();
    } else {
      writeSession(jsonEncode(user.toJson()));
    }
  }

  Future<bool> login(String username, String password) async {
    final user = await ref.read(b2bServiceProvider).login(username, password);
    if (user == null) return false;
    state = user;
    ref.read(appSettingsProvider.notifier).backToStorefront();
    _persist();
    return true;
  }

  void logout() {
    state = null;
    ref.read(cartProvider.notifier).clear();
    ref.read(appSettingsProvider.notifier).resetOnLogout();
    _persist();
  }
}
