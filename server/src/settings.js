import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

import { config } from './config.js';

// Runtime settings let the front-end configure the Logo REST connection (and
// other options) without restarting the server. They are persisted to a
// gitignored JSON file and take precedence over environment variables.
const __dirname = dirname(fileURLToPath(import.meta.url));
const SETTINGS_FILE = join(__dirname, '..', '.runtime-settings.json');

function read() {
  try {
    if (existsSync(SETTINGS_FILE)) return JSON.parse(readFileSync(SETTINGS_FILE, 'utf8'));
  } catch {
    // fall through to defaults
  }
  return {};
}

function write(obj) {
  writeFileSync(SETTINGS_FILE, JSON.stringify(obj, null, 2), 'utf8');
}

export function saveLogoSettings(input = {}) {
  const current = read();
  const logo = { ...(current.logo ?? {}) };
  // Only overwrite provided, non-empty fields (so secrets aren't wiped by
  // a masked round-trip that omits them).
  for (const key of ['baseUrl', 'clientId', 'clientSecret', 'username', 'password']) {
    if (typeof input[key] === 'string' && input[key].trim() !== '') logo[key] = input[key].trim();
  }
  for (const key of ['firmNo', 'periodNo']) {
    if (input[key] !== undefined && input[key] !== null && `${input[key]}` !== '') logo[key] = Number(input[key]);
  }
  if (input.clearSecrets === true) {
    delete logo.clientSecret;
    delete logo.password;
  }
  write({ ...current, logo });
  return effectiveLogo();
}

// Effective Logo config = runtime overrides merged over environment defaults.
export function effectiveLogo() {
  const r = read().logo ?? {};
  const e = config.logo;
  const merged = {
    baseUrl: r.baseUrl ?? e.baseUrl ?? '',
    clientId: r.clientId ?? e.clientId ?? '',
    clientSecret: r.clientSecret ?? e.clientSecret ?? '',
    username: r.username ?? e.username ?? 'ADMIN',
    password: r.password ?? e.password ?? '',
    firmNo: r.firmNo ?? e.firmNo ?? 1,
    periodNo: r.periodNo ?? e.periodNo ?? 1,
  };
  merged.mock = !merged.baseUrl;
  return merged;
}

// Non-secret view safe to return to the browser.
export function maskedSettings() {
  const logo = effectiveLogo();
  return {
    logo: {
      baseUrl: logo.baseUrl,
      username: logo.username,
      firmNo: logo.firmNo,
      periodNo: logo.periodNo,
      hasClientId: !!logo.clientId,
      hasClientSecret: !!logo.clientSecret,
      hasPassword: !!logo.password,
      mode: logo.mock ? 'mock' : 'live',
    },
    stripe: { mode: config.stripe.mock ? 'mock' : 'live' },
    postgrestUrl: config.postgrestUrl,
  };
}
