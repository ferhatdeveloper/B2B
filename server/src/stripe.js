import { config } from './config.js';

let _stripe = null;
async function getStripe() {
  if (config.stripe.mock) return null;
  if (!_stripe) {
    const { default: Stripe } = await import('stripe');
    _stripe = new Stripe(config.stripe.secretKey);
  }
  return _stripe;
}

// Creates a hosted-checkout session for a B2B balance payment.
// MOCK mode returns a URL to this server's own mock-complete endpoint so the
// end-to-end flow (redirect → success → payment recorded) works without keys.
export async function createCheckoutSession({ amount, currency, paymentNo, customerLabel }) {
  const successUrl = `${config.publicAppUrl}/?payment=success`;
  const cancelUrl = `${config.publicAppUrl}/?payment=cancel`;

  if (config.stripe.mock) {
    const url =
      `http://localhost:${config.port}/api/payments/mock-complete` +
      `?payment_no=${encodeURIComponent(paymentNo)}&redirect=${encodeURIComponent(successUrl)}`;
    return { url, sessionId: `mock_sess_${paymentNo}`, mock: true };
  }

  const stripe = await getStripe();
  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    success_url: successUrl,
    cancel_url: cancelUrl,
    client_reference_id: paymentNo,
    line_items: [
      {
        quantity: 1,
        price_data: {
          currency: (currency ?? 'try').toLowerCase(),
          unit_amount: Math.round(amount * 100),
          product_data: { name: `B2B bakiye ödemesi · ${customerLabel ?? ''}`.trim() },
        },
      },
    ],
    metadata: { payment_no: paymentNo },
  });
  return { url: session.url, sessionId: session.id, mock: false };
}

export async function constructWebhookEvent(rawBody, signature) {
  const stripe = await getStripe();
  if (!stripe) throw new Error('Stripe not configured');
  return stripe.webhooks.constructEvent(rawBody, signature, config.stripe.webhookSecret);
}
