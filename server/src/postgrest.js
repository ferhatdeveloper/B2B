import { config } from './config.js';

// Minimal PostgREST helper for the integration server (schema via profiles).
function headers(schema, extra = {}) {
  return {
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'Accept-Profile': schema,
    'Content-Profile': schema,
    ...extra,
  };
}

export async function pgGet(path, { schema = 'public' } = {}) {
  const res = await fetch(`${config.postgrestUrl}${path}`, { headers: headers(schema) });
  if (!res.ok) throw new Error(`PostgREST GET ${path}: ${res.status} ${await res.text()}`);
  return res.json();
}

export async function pgPost(path, body, { schema = 'public', prefer = 'return=representation' } = {}) {
  const res = await fetch(`${config.postgrestUrl}${path}`, {
    method: 'POST',
    headers: headers(schema, { Prefer: prefer }),
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`PostgREST POST ${path}: ${res.status} ${await res.text()}`);
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

export async function pgPatch(path, body, { schema = 'public', prefer = 'return=representation' } = {}) {
  const res = await fetch(`${config.postgrestUrl}${path}`, {
    method: 'PATCH',
    headers: headers(schema, { Prefer: prefer }),
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`PostgREST PATCH ${path}: ${res.status} ${await res.text()}`);
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

// Upsert helper: merge-duplicates on a unique column.
export async function pgUpsert(path, rows, onConflict, opts = {}) {
  const sep = path.includes('?') ? '&' : '?';
  return pgPost(`${path}${sep}on_conflict=${onConflict}`, rows, {
    ...opts,
    prefer: 'resolution=merge-duplicates,return=minimal',
  });
}
