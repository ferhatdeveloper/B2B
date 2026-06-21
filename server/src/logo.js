import { config } from './config.js';
import { pgGet, pgUpsert, pgPatch } from './postgrest.js';

// Logo Object REST Service client. Talks to a real Logo LRS when LOGO_BASE_URL
// is configured, otherwise to the built-in mock server (same wire shape).
export class LogoClient {
  constructor({ baseUrl }) {
    this.baseUrl = baseUrl.replace(/\/+$/, '');
    this.token = null;
  }

  async authenticate() {
    const body = config.logo.clientId
      ? { clientId: config.logo.clientId, clientSecret: config.logo.clientSecret, firmNo: config.logo.firmNo, periodNo: config.logo.periodNo }
      : { username: config.logo.username, password: config.logo.password, firmNo: config.logo.firmNo, periodNo: config.logo.periodNo };

    const res = await fetch(`${this.baseUrl}/api/v1/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (!res.ok) throw new Error(`Logo token: ${res.status} ${await res.text()}`);
    const data = await res.json();
    this.token = data.token;
    return this.token;
  }

  async get(path) {
    if (!this.token) await this.authenticate();
    const res = await fetch(`${this.baseUrl}${path}`, {
      headers: { Authorization: `Bearer ${this.token}`, Accept: 'application/json' },
    });
    if (!res.ok) throw new Error(`Logo GET ${path}: ${res.status} ${await res.text()}`);
    return res.json();
  }

  items() { return this.get('/api/v1/items'); }
  inventories() { return this.get('/api/v1/inventories'); }
  arps() { return this.get('/api/v1/arps'); }
}

// Maps a Logo category hint to a local category id (best-effort by slug).
async function categoryMap() {
  const cats = await pgGet('/categories?select=id,slug');
  return new Map(cats.map((c) => [c.slug, c.id]));
}

// Pulls items/inventories/arps from Logo and upserts into the local B2B tables.
export async function syncFromLogo(client) {
  const [items, inventories, arps] = await Promise.all([client.items(), client.inventories(), client.arps()]);
  const stockByCode = new Map(inventories.map((i) => [i.ITEMCODE, Number(i.ONHAND ?? 0)]));
  const cats = await categoryMap();

  const productRows = items
    .filter((it) => Number(it.ACTIVE ?? 1) === 1)
    .map((it) => ({
      sku: it.CODE,
      external_code: it.CODE,
      source: 'logo',
      name: it.NAME,
      currency_code: it.CURRENCY ?? 'TRY',
      price: Number(it.PRICE ?? 0),
      tax_rate: Number(it.VATRATE ?? 20),
      stock_qty: stockByCode.get(it.CODE) ?? 0,
      category_id: cats.get(it.CATEGORY) ?? null,
      is_active: true,
    }));

  if (productRows.length) await pgUpsert('/products', productRows, 'sku');

  // Update existing customers' financials from Logo arps (match on code).
  let customersUpdated = 0;
  for (const a of arps) {
    const patched = await pgPatch(`/customers?code=eq.${encodeURIComponent(a.CODE)}`, {
      balance: Number(a.BALANCE ?? 0),
      credit_limit: Number(a.CREDIT_LIMIT ?? 0),
      past_due_balance: Number(a.OVERDUE ?? 0),
      source: 'logo',
      external_code: a.CODE,
    });
    if (Array.isArray(patched)) customersUpdated += patched.length;
  }

  return { products: productRows.length, customers: customersUpdated };
}
