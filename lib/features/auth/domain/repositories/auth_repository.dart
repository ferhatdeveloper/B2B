import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser?> getCurrentUser();

  Future<AuthUser> login({
    required String username,
    required String password,
    String firmNr,
  });

  Future<void> logout();
}
