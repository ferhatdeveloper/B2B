const defaultPort = 3002;

function normalizeBaseUrl(input: string | undefined): string {
  return (input ?? '').trim().replace(/\/+$/, '');
}

function getEnvBaseUrl(): string {
  const meta = import.meta as unknown as { env?: { VITE_POSTGREST_URL?: string } };
  const viteEnv = meta.env?.VITE_POSTGREST_URL;
  return normalizeBaseUrl(viteEnv);
}

function getBrowserFallback(): string {
  if (typeof window === 'undefined') return `http://localhost:${defaultPort}`;

  const { protocol, hostname } = window.location;
  const isLocal = hostname === 'localhost' || hostname === '127.0.0.1';
  return isLocal ? `http://localhost:${defaultPort}` : `${protocol}//${hostname}:${defaultPort}`;
}

export const postgrestConfig = {
  defaultSchema: 'public' as const,
  schemas: ['public', 'logic', 'b2b'] as const,
};

export type PostgrestSchema = (typeof postgrestConfig.schemas)[number];

export function getPostgrestBaseUrl(): string {
  return getEnvBaseUrl() || getBrowserFallback();
}

export function getPostgrestUrl(path: string): string {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  return `${getPostgrestBaseUrl()}${normalizedPath}`;
}
