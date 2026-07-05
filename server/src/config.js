// Integration server configuration, sourced from environment variables.
// Sensible local-dev defaults; production values come from Secrets.

const env = process.env;

export const config = {
  port: Number(env.INTEGRATION_PORT ?? 4000),

  // PostgREST API this server reads/writes through.
  postgrestUrl: env.POSTGREST_URL ?? 'http://localhost:3002',

  // Public URL of the front-end (Stripe success/cancel redirect target).
  publicAppUrl: env.PUBLIC_APP_URL ?? 'http://localhost:8080',

  // Stripe. When STRIPE_SECRET_KEY is absent we fall back to MOCK mode so the
  // payment flow is still demonstrable locally without real credentials.
  stripe: {
    secretKey: env.STRIPE_SECRET_KEY ?? '',
    webhookSecret: env.STRIPE_WEBHOOK_SECRET ?? '',
    get mock() {
      return !this.secretKey;
    },
  },

  // Logo Object REST Service. When LOGO_BASE_URL is absent we use the built-in
  // mock Logo server so sync can be demonstrated without a real Logo ERP.
  logo: {
    baseUrl: env.LOGO_BASE_URL ?? '',
    clientId: env.LOGO_CLIENT_ID ?? '',
    clientSecret: env.LOGO_CLIENT_SECRET ?? '',
    username: env.LOGO_USERNAME ?? 'ADMIN',
    password: env.LOGO_PASSWORD ?? '',
    firmNo: Number(env.LOGO_FIRM_NO ?? 1),
    periodNo: Number(env.LOGO_PERIOD_NO ?? 1),
    get mock() {
      return !this.baseUrl;
    },
  },
};
