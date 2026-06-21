abstract final class AppConfig {
  static const appName = 'Zensoft B2B';

  static const postgrestUrl = String.fromEnvironment(
    'POSTGREST_URL',
    defaultValue: 'http://localhost:3002',
  );

  static const publicSchema = 'public';
  static const logicSchema = 'logic';
  static const apiSchema = 'b2b';

  static const demoUsername = 'demo';
  static const demoPassword = '1234';

  static const useDemoFallback = bool.fromEnvironment(
    'USE_DEMO_FALLBACK',
    defaultValue: true,
  );
}
