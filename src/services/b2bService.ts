import { postgrest } from './api/postgrestClient';

export interface ProductCatalogItem {
  id: string;
  sku: string;
  name: string;
  description?: string;
  brand?: string;
  unit: string;
  currency_code: string;
  price: number;
  tax_rate: number;
  stock_qty: number;
  image_url?: string;
  is_featured: boolean;
  is_campaign: boolean;
  is_discounted: boolean;
  is_personal: boolean;
  category_id?: string;
  category_code?: string;
  category_name?: string;
  category_slug?: string;
}

export interface LoginResult {
  id: string;
  username: string;
  email?: string;
  full_name: string;
  customer_id?: string;
  customer_code?: string;
  customer_title?: string;
  firm_nr?: string;
  role_id?: string;
  role_name?: string;
  role_permissions?: Record<string, unknown>;
  balance?: number;
  credit_limit?: number;
  average_maturity_days?: number;
  past_due_balance?: number;
  created_at: string;
}

export interface CreateOrderLineInput {
  product_id?: string;
  sku: string;
  product_name: string;
  qty: number;
  unit_price: number;
  discount_pct?: number;
  tax_rate?: number;
  line_total: number;
}

export interface CreateOrderInput {
  order_no: string;
  customer_id: string;
  shipping_address_id?: string;
  note?: string;
  lines: CreateOrderLineInput[];
}

function orderTotals(lines: CreateOrderLineInput[]) {
  return lines.reduce(
    (totals, line) => {
      const discountPct = line.discount_pct ?? 0;
      const taxRate = line.tax_rate ?? 20;
      const gross = line.qty * line.unit_price;
      const discount = gross * (discountPct / 100);
      const taxable = gross - discount;
      const tax = taxable * (taxRate / 100);

      totals.subtotal += gross;
      totals.discount_total += discount;
      totals.tax_total += tax;
      totals.grand_total += taxable + tax;
      return totals;
    },
    { subtotal: 0, discount_total: 0, tax_total: 0, grand_total: 0 },
  );
}

export async function login(username: string, password: string, firmNr = ''): Promise<LoginResult | null> {
  const rows = await postgrest.rpc<LoginResult[]>('verify_login', {
    username,
    password,
    firm_nr: firmNr,
  });

  return rows[0] ?? null;
}

export function getFeaturedProducts(limit = 12): Promise<ProductCatalogItem[]> {
  return postgrest.get<ProductCatalogItem[]>(
    '/product_catalog',
    {
      select: '*',
      is_featured: 'eq.true',
      order: 'name.asc',
      limit,
    },
    { schema: 'b2b' },
  );
}

export function getCampaignProducts(limit = 12): Promise<ProductCatalogItem[]> {
  return postgrest.get<ProductCatalogItem[]>(
    '/product_catalog',
    {
      select: '*',
      is_campaign: 'eq.true',
      order: 'name.asc',
      limit,
    },
    { schema: 'b2b' },
  );
}

export function searchProducts(query: string, limit = 24): Promise<ProductCatalogItem[]> {
  return postgrest.get<ProductCatalogItem[]>(
    '/product_catalog',
    {
      select: '*',
      or: `(name.ilike.*${query}*,sku.ilike.*${query}*)`,
      order: 'name.asc',
      limit,
    },
    { schema: 'b2b' },
  );
}

export async function createOrder(input: CreateOrderInput) {
  const totals = orderTotals(input.lines);
  const createdOrders = await postgrest.post<Array<{ id: string }>>('/orders', {
    order_no: input.order_no,
    customer_id: input.customer_id,
    shipping_address_id: input.shipping_address_id,
    note: input.note,
    status: 'open',
    ...totals,
  });

  const order = createdOrders[0];
  if (!order?.id) throw new Error('Siparis olusturulamadi: PostgREST yanitinda id yok.');

  const lines = input.lines.map((line) => ({
    ...line,
    order_id: order.id,
    discount_pct: line.discount_pct ?? 0,
    tax_rate: line.tax_rate ?? 20,
  }));

  await postgrest.post('/order_lines', lines, { prefer: 'return=minimal' });
  return order;
}

export function createPayment(input: {
  payment_no: string;
  customer_id: string;
  order_id?: string;
  method?: string;
  amount: number;
  currency_code?: string;
}) {
  return postgrest.post('/payments', {
    status: 'pending',
    method: input.method ?? 'card',
    currency_code: input.currency_code ?? 'TRY',
    ...input,
  });
}
