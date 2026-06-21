import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/postgrest_client.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final PostgrestClient _client;
  static const _sessionKey = 'b2b_auth_session';

  @override
  Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;

    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
    String firmNr = '',
  }) async {
    try {
      final row = await _client.rpc('verify_login', {
        'username': username.trim(),
        'password': password,
        'firm_nr': firmNr.trim(),
      });

      if (row == null) throw Exception('Kullanici bulunamadi.');
      final user = AuthUser.fromJson(row);
      await _saveSession(user);
      return user;
    } catch (_) {
      if (AppConfig.useDemoFallback &&
          username == AppConfig.demoUsername &&
          password == AppConfig.demoPassword) {
        final user = const AuthUser(
          id: 'demo',
          username: AppConfig.demoUsername,
          fullName: 'Demo Kullanici',
          customerCode: 'demo',
          customerTitle: 'Demo Bayi',
        );
        await _saveSession(user);
        return user;
      }
      throw Exception('Kullanici adi veya sifre hatali.');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }
}
