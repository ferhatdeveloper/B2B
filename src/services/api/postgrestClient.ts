import { getPostgrestUrl, postgrestConfig, type PostgrestSchema } from '../../config/postgrest.config';

export interface PostgrestClientOptions {
  schema?: PostgrestSchema;
  headers?: Record<string, string>;
  jwt?: string;
  prefer?: 'return=representation' | 'return=minimal' | string;
}

export interface PostgrestQueryParams {
  select?: string;
  order?: string;
  limit?: number;
  offset?: number;
  [key: string]: string | number | boolean | undefined;
}

function buildHeaders(options: PostgrestClientOptions = {}): Record<string, string> {
  const schema = options.schema ?? postgrestConfig.defaultSchema;
  const headers: Record<string, string> = {
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'Accept-Profile': schema,
    'Content-Profile': schema,
    ...options.headers,
  };

  if (options.jwt) headers.Authorization = `Bearer ${options.jwt}`;
  if (options.prefer) headers.Prefer = options.prefer;

  return headers;
}

function toQueryString(params?: PostgrestQueryParams): string {
  if (!params) return '';

  const search = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== '') search.set(key, String(value));
  }

  const query = search.toString();
  return query ? `?${query}` : '';
}

async function parseResponse<T>(response: Response, method: string, path: string): Promise<T> {
  if (!response.ok) {
    const text = await response.text();
    throw new Error(`PostgREST ${method} ${path}: ${response.status} ${response.statusText}${text ? ` - ${text}` : ''}`);
  }

  const contentType = response.headers.get('Content-Type') ?? '';
  if (contentType.includes('application/json')) return response.json() as Promise<T>;
  return undefined as T;
}

export async function postgrestGet<T = unknown>(
  path: string,
  query?: PostgrestQueryParams,
  options?: PostgrestClientOptions,
): Promise<T> {
  const response = await fetch(getPostgrestUrl(path) + toQueryString(query), {
    method: 'GET',
    headers: buildHeaders(options),
  });

  return parseResponse<T>(response, 'GET', path);
}

export async function postgrestPost<T = unknown>(
  path: string,
  body: Record<string, unknown> | unknown[],
  options?: PostgrestClientOptions,
): Promise<T> {
  const response = await fetch(getPostgrestUrl(path), {
    method: 'POST',
    headers: buildHeaders({ prefer: 'return=representation', ...options }),
    body: JSON.stringify(body),
  });

  return parseResponse<T>(response, 'POST', path);
}

export async function postgrestPatch<T = unknown>(
  path: string,
  body: Record<string, unknown>,
  options?: PostgrestClientOptions,
): Promise<T> {
  const response = await fetch(getPostgrestUrl(path), {
    method: 'PATCH',
    headers: buildHeaders({ prefer: 'return=representation', ...options }),
    body: JSON.stringify(body),
  });

  return parseResponse<T>(response, 'PATCH', path);
}

export async function postgrestDelete<T = unknown>(
  path: string,
  options?: PostgrestClientOptions,
): Promise<T> {
  const response = await fetch(getPostgrestUrl(path), {
    method: 'DELETE',
    headers: buildHeaders({ prefer: 'return=minimal', ...options }),
  });

  return parseResponse<T>(response, 'DELETE', path);
}

export async function postgrestRpc<T = unknown>(
  name: string,
  body: Record<string, unknown>,
  options?: PostgrestClientOptions,
): Promise<T> {
  return postgrestPost<T>(`/rpc/${name}`, body, { schema: 'logic', ...options });
}

export const postgrest = {
  get: postgrestGet,
  post: postgrestPost,
  patch: postgrestPatch,
  delete: postgrestDelete,
  rpc: postgrestRpc,
};

export default postgrest;
