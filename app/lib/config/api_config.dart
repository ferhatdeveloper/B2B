/// Base URL of the PostgREST API.
///
/// Override at build/run time, e.g.:
///   flutter run -d chrome --dart-define=POSTGREST_URL=http://localhost:3002
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'POSTGREST_URL',
    defaultValue: 'http://localhost:3002',
  );

  /// PostgREST schema profiles exposed by the B2B backend.
  static const String schemaPublic = 'public';
  static const String schemaLogic = 'logic';
  static const String schemaB2b = 'b2b';

  /// Integration server (Stripe payments + Logo REST sync).
  ///   flutter run --dart-define=INTEGRATION_URL=http://localhost:4000
  static const String integrationUrl = String.fromEnvironment(
    'INTEGRATION_URL',
    defaultValue: 'http://localhost:4000',
  );
}
