import express from 'express';

// In-memory mock of the Logo Object REST Service (LRS).
// Mirrors the real endpoints' shape closely enough to exercise the connector
// and sync logic without a licensed Logo ERP. Endpoints:
//   POST /api/v1/token, GET /api/v1/items, /api/v1/arps, /api/v1/inventories
const MOCK_TOKEN = 'mock-logo-token';

const ITEMS = [
  { CODE: 'LOGO-1001', NAME: 'Logo Endustriyel Matkap', PRICE: 2450.0, CURRENCY: 'TRY', VATRATE: 20, ACTIVE: 1, CATEGORY: 'yapi-market' },
  { CODE: 'LOGO-1002', NAME: 'Logo Profesyonel Tornavida Seti', PRICE: 899.9, CURRENCY: 'TRY', VATRATE: 20, ACTIVE: 1, CATEGORY: 'yapi-market' },
  { CODE: 'LOGO-1003', NAME: 'Logo Akilli Termostat', PRICE: 3199.0, CURRENCY: 'TRY', VATRATE: 20, ACTIVE: 1, CATEGORY: 'electronics' },
  { CODE: 'LOGO-1004', NAME: 'Logo Kablosuz Kamera', PRICE: 1799.5, CURRENCY: 'TRY', VATRATE: 20, ACTIVE: 1, CATEGORY: 'electronics' },
];

const INVENTORIES = {
  'LOGO-1001': 120,
  'LOGO-1002': 64,
  'LOGO-1003': 18,
  'LOGO-1004': 7,
};

const ARPS = [
  { CODE: 'demo', DEFINITION: 'Demo Bayi', BALANCE: 16000.0, CREDIT_LIMIT: 100000.0, OVERDUE: 0.0 },
];

export function createMockLogoRouter() {
  const router = express.Router();
  router.use(express.json());

  router.post('/api/v1/token', (req, res) => {
    res.json({ token: MOCK_TOKEN, expiration: new Date(Date.now() + 8 * 3600 * 1000).toISOString() });
  });

  const auth = (req, res, next) => {
    const h = req.headers.authorization ?? '';
    if (!h.includes(MOCK_TOKEN)) return res.status(401).json({ message: 'invalid token' });
    next();
  };

  router.get('/api/v1/items', auth, (req, res) => res.json(ITEMS));
  router.get('/api/v1/inventories', auth, (req, res) =>
    res.json(Object.entries(INVENTORIES).map(([ITEMCODE, ONHAND]) => ({ ITEMCODE, ONHAND }))),
  );
  router.get('/api/v1/arps', auth, (req, res) => res.json(ARPS));

  return router;
}
