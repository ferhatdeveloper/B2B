import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

class CartLine {
  CartLine({required this.product, this.qty = 1});

  final Product product;
  int qty;

  double get gross => product.price * qty;
  double get tax => gross * (product.taxRate / 100);
  double get total => gross + tax;
}

class B2bService {
  B2bService({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<SessionUser?> login(String username, String password, {String firmNr = ''}) async {
    final data = await _api.rpc('verify_login', {
      'username': username,
      'password': password,
      'firm_nr': firmNr,
    });
    final rows = (data as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;
    return SessionUser.fromJson(rows.first);
  }

  Future<List<Category>> categories() async {
    final data = await _api.get(
      '/categories',
      query: {
        'select': 'id,code,name,slug,sort_order',
        'is_active': 'eq.true',
        'order': 'sort_order.asc',
      },
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> products({
    String? search,
    String? categorySlug,
    String? flag,
    int limit = 60,
  }) async {
    final query = <String, String>{
      'select': '*',
      'order': 'name.asc',
      'limit': '$limit',
    };
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim();
      query['or'] = '(name.ilike.*$q*,sku.ilike.*$q*,brand.ilike.*$q*)';
    }
    if (categorySlug != null) query['category_slug'] = 'eq.$categorySlug';
    if (flag != null) query[flag] = 'eq.true';

    final data = await _api.get('/product_catalog', query: query, schema: ApiConfig.schemaB2b);
    return (data as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DashboardSummary?> dashboard(String customerId) async {
    final data = await _api.get(
      '/customer_dashboard',
      query: {'select': '*', 'customer_id': 'eq.$customerId'},
      schema: ApiConfig.schemaB2b,
    );
    final rows = (data as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;
    return DashboardSummary.fromJson(rows.first);
  }

  Future<List<OrderRow>> orders(String customerId, {int limit = 50, String? status}) async {
    final query = <String, String>{
      'select': 'id,order_no,status,grand_total,currency_code,note,created_at',
      'customer_id': 'eq.$customerId',
      'order': 'created_at.desc',
      'limit': '$limit',
    };
    if (status != null) query['status'] = 'eq.$status';
    final data = await _api.get('/orders', query: query, schema: ApiConfig.schemaPublic);
    return (data as List).map((e) => OrderRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PaymentRow>> payments(String customerId) async {
    final data = await _api.get(
      '/payments',
      query: {
        'select': 'payment_no,status,method,amount,currency_code,provider,paid_at,created_at',
        'customer_id': 'eq.$customerId',
        'order': 'created_at.desc',
      },
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => PaymentRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StatementRow>> statement(String customerId) async {
    final data = await _api.get(
      '/account_statement',
      query: {
        'select': 'txn_date,doc_no,doc_type,description,debit,credit,running_balance',
        'customer_id': 'eq.$customerId',
        'order': 'txn_date.asc',
      },
      schema: ApiConfig.schemaB2b,
    );
    return (data as List).map((e) => StatementRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<InvoiceRow>> openInvoices(String customerId) async {
    final data = await _api.get(
      '/open_invoices',
      query: {'select': 'invoice_no,status,amount,currency_code,due_date', 'customer_id': 'eq.$customerId'},
      schema: ApiConfig.schemaB2b,
    );
    return (data as List).map((e) => InvoiceRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CheckNoteRow>> checksNotes(String customerId) async {
    final data = await _api.get(
      '/checks_notes',
      query: {'select': 'document_no,document_type,status,amount,due_date', 'customer_id': 'eq.$customerId', 'order': 'due_date.asc'},
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => CheckNoteRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DispatchRow>> unbilledDispatches(String customerId) async {
    final data = await _api.get(
      '/unbilled_dispatches',
      query: {'select': 'dispatch_no,status,amount,dispatched_at', 'customer_id': 'eq.$customerId'},
      schema: ApiConfig.schemaB2b,
    );
    return (data as List).map((e) => DispatchRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ShippingAddress>> shippingAddresses(String customerId) async {
    final data = await _api.get(
      '/shipping_addresses',
      query: {'select': 'id,title,contact_name,phone,address_line,city,is_default', 'customer_id': 'eq.$customerId', 'order': 'is_default.desc'},
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => ShippingAddress.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addShippingAddress(String customerId, {required String title, required String addressLine, String? city, String? contactName, String? phone}) async {
    await _api.post(
      '/shipping_addresses',
      {
        'customer_id': customerId,
        'title': title,
        'address_line': addressLine,
        if (city != null && city.isNotEmpty) 'city': city,
        if (contactName != null && contactName.isNotEmpty) 'contact_name': contactName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
      schema: ApiConfig.schemaPublic,
      prefer: 'return=minimal',
    );
  }

  Future<List<Product>> favoriteProducts(String customerId) async {
    final favs = await _api.get(
      '/favorites',
      query: {'select': 'product_id', 'customer_id': 'eq.$customerId'},
      schema: ApiConfig.schemaPublic,
    );
    final ids = (favs as List).map((e) => e['product_id'].toString()).toList();
    if (ids.isEmpty) return [];
    final data = await _api.get(
      '/product_catalog',
      query: {'select': '*', 'id': 'in.(${ids.join(',')})', 'order': 'name.asc'},
      schema: ApiConfig.schemaB2b,
    );
    return (data as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Creates a Stripe (or mock) checkout session via the integration server.
  /// Returns the hosted checkout URL the client should open.
  Future<String> startPayment({required String customerId, required double amount}) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.integrationUrl}/api/payments/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'customer_id': customerId, 'amount': amount}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Ödeme başlatılamadı: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['url'] as String;
  }

  /// Triggers a Logo REST → local DB sync via the integration server.
  Future<Map<String, dynamic>> syncLogo() async {
    final res = await http.post(Uri.parse('${ApiConfig.integrationUrl}/api/logo/sync'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Logo senkronu başarısız: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Current integration settings (masked secrets) from the integration server.
  Future<Map<String, dynamic>> getSettings() async {
    final res = await http.get(Uri.parse('${ApiConfig.integrationUrl}/api/settings'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Ayarlar alınamadı: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Persists Logo REST connection settings on the integration server.
  Future<Map<String, dynamic>> saveLogoSettings(Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.integrationUrl}/api/settings/logo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Ayarlar kaydedilemedi: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Tests the (effective) Logo connection. Throws with the server error on failure.
  Future<Map<String, dynamic>> testLogo() async {
    final res = await http.post(Uri.parse('${ApiConfig.integrationUrl}/api/logo/test'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(data['error']?.toString() ?? 'Logo bağlantısı başarısız (${res.statusCode})');
    }
    return data;
  }

  Future<List<Campaign>> campaigns() async {
    final data = await _api.get(
      '/campaigns',
      query: {
        'select': 'id,name,description,discount_pct',
        'is_active': 'eq.true',
        'order': 'created_at.desc',
      },
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => Campaign.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Announcement>> announcements() async {
    final data = await _api.get(
      '/announcements',
      query: {
        'select': 'id,title,body,created_at',
        'is_active': 'eq.true',
        'order': 'created_at.desc',
      },
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => Announcement.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String?> retailCustomerId() async {
    final rows = await _api.get(
      '/customers',
      query: {'select': 'id', 'code': 'eq.retail'},
      schema: ApiConfig.schemaPublic,
    );
    final list = (rows as List);
    return list.isEmpty ? null : list.first['id'].toString();
  }

  /// Creates an order header + lines and returns the generated order_no.
  Future<String> createOrder({
    required String customerId,
    required List<CartLine> lines,
    String? note,
    String channel = 'b2b',
    String? buyerName,
    String? buyerEmail,
  }) async {
    double subtotal = 0, tax = 0, grand = 0;
    for (final l in lines) {
      subtotal += l.gross;
      tax += l.tax;
      grand += l.total;
    }

    final prefix = channel == 'storefront' ? 'SHOP' : 'WEB';
    final orderNo = '$prefix-${DateTime.now().millisecondsSinceEpoch}';
    final created = await _api.post(
      '/orders',
      {
        'order_no': orderNo,
        'customer_id': customerId,
        'status': 'open',
        'channel': channel,
        'subtotal': subtotal,
        'discount_total': 0,
        'tax_total': tax,
        'grand_total': grand,
        if (note != null && note.isNotEmpty) 'note': note,
        if (buyerName != null && buyerName.isNotEmpty) 'buyer_name': buyerName,
        if (buyerEmail != null && buyerEmail.isNotEmpty) 'buyer_email': buyerEmail,
      },
      schema: ApiConfig.schemaPublic,
    );

    final orderId = (created as List).first['id'].toString();
    final lineBodies = lines
        .map((l) => {
              'order_id': orderId,
              'product_id': l.product.id,
              'sku': l.product.sku,
              'product_name': l.product.name,
              'qty': l.qty,
              'unit_price': l.product.price,
              'discount_pct': 0,
              'tax_rate': l.product.taxRate,
              'line_total': l.total,
            })
        .toList();

    await _api.post('/order_lines', lineBodies, schema: ApiConfig.schemaPublic, prefer: 'return=minimal');
    return orderNo;
  }
}
