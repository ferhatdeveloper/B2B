import express from 'express';
import cors from 'cors';

import { config } from './config.js';
import { pgPost, pgPatch, pgGet } from './postgrest.js';
import { createCheckoutSession, constructWebhookEvent } from './stripe.js';
import { LogoClient, syncFromLogo } from './logo.js';
import { createMockLogoRouter } from './mockLogo.js';
import { effectiveLogo, saveLogoSettings, maskedSettings } from './settings.js';

const app = express();
app.use(cors());

// Stripe webhook needs the raw body for signature verification — mount before json().
app.post('/api/stripe/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const event = await constructWebhookEvent(req.body, req.headers['stripe-signature']);
    if (event.type === 'checkout.session.completed') {
      const paymentNo = event.data.object.metadata?.payment_no ?? event.data.object.client_reference_id;
      if (paymentNo) await markPaymentPaid(paymentNo, event.data.object.id);
    }
    res.json({ received: true });
  } catch (err) {
    console.error('webhook error', err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
  }
});

app.use(express.json());

// Built-in mock Logo LRS (used when no real LOGO_BASE_URL is configured).
app.use('/mock-logo', createMockLogoRouter());

app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    stripe: config.stripe.mock ? 'mock' : 'live',
    logo: effectiveLogo().mock ? 'mock' : 'live',
  });
});

// --- Settings ---------------------------------------------------------------
app.get('/api/settings', (req, res) => res.json(maskedSettings()));

app.put('/api/settings/logo', (req, res) => {
  try {
    saveLogoSettings(req.body ?? {});
    res.json(maskedSettings());
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Tests the (effective) Logo connection by attempting to authenticate.
app.post('/api/logo/test', async (req, res) => {
  try {
    const client = buildLogoClient();
    await client.authenticate();
    const items = await client.items();
    res.json({ ok: true, mode: effectiveLogo().mock ? 'mock' : 'live', itemCount: items.length });
  } catch (err) {
    res.status(502).json({ ok: false, error: err.message });
  }
});

// --- Payments (Stripe) ------------------------------------------------------
app.post('/api/payments/checkout', async (req, res) => {
  try {
    const { customer_id, amount, currency = 'TRY', order_id } = req.body ?? {};
    if (!customer_id || !amount || Number(amount) <= 0) {
      return res.status(400).json({ error: 'customer_id ve pozitif amount gerekli' });
    }
    const paymentNo = `PAY-${Date.now()}`;
    await pgPost('/payments', {
      customer_id,
      order_id: order_id ?? null,
      payment_no: paymentNo,
      method: 'card',
      status: 'pending',
      currency_code: currency,
      amount: Number(amount),
      provider: config.stripe.mock ? 'stripe_mock' : 'stripe',
    });

    const session = await createCheckoutSession({ amount: Number(amount), currency, paymentNo });
    await pgPatch(`/payments?payment_no=eq.${paymentNo}`, {
      stripe_session_id: session.sessionId,
      stripe_status: 'created',
    });

    res.json({ url: session.url, payment_no: paymentNo, mock: session.mock });
  } catch (err) {
    console.error('checkout error', err.message);
    res.status(500).json({ error: err.message });
  }
});

// MOCK success callback — simulates Stripe redirecting back after payment.
app.get('/api/payments/mock-complete', async (req, res) => {
  try {
    const paymentNo = req.query.payment_no;
    const redirect = req.query.redirect ?? config.publicAppUrl;
    if (paymentNo) await markPaymentPaid(paymentNo, `mock_sess_${paymentNo}`);
    res.redirect(String(redirect));
  } catch (err) {
    res.status(500).send(err.message);
  }
});

async function markPaymentPaid(paymentNo, sessionId) {
  const updated = await pgPatch(`/payments?payment_no=eq.${encodeURIComponent(paymentNo)}`, {
    status: 'approved',
    stripe_status: 'paid',
    stripe_session_id: sessionId,
    paid_at: new Date().toISOString(),
  });
  const payment = Array.isArray(updated) ? updated[0] : null;
  if (payment) {
    await pgPost('/account_transactions', {
      customer_id: payment.customer_id,
      doc_no: paymentNo,
      doc_type: 'Tahsilat',
      debit: 0,
      credit: payment.amount,
      description: 'Online (Stripe) tahsilat',
    });
  }
}

// --- Logo REST integration --------------------------------------------------
function buildLogoClient() {
  const logo = effectiveLogo();
  const baseUrl = logo.mock ? `http://localhost:${config.port}/mock-logo` : logo.baseUrl;
  return new LogoClient({ ...logo, baseUrl });
}

app.get('/api/logo/status', async (req, res) => {
  const logo = effectiveLogo();
  res.json({ mode: logo.mock ? 'mock' : 'live', baseUrl: logo.mock ? '(built-in mock)' : logo.baseUrl });
});

app.post('/api/logo/sync', async (req, res) => {
  try {
    const client = buildLogoClient();
    const result = await syncFromLogo(client);
    res.json({ ok: true, mode: config.logo.mock ? 'mock' : 'live', ...result });
  } catch (err) {
    console.error('logo sync error', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/logo/products', async (req, res) => {
  try {
    const rows = await pgGet('/products?select=sku,name,price,stock_qty,source&source=eq.logo&order=name.asc');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(config.port, () => {
  console.log(`B2B integration server on :${config.port} (stripe=${config.stripe.mock ? 'mock' : 'live'}, logo=${config.logo.mock ? 'mock' : 'live'})`);
});
