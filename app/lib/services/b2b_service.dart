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

  Future<List<OrderRow>> orders(String customerId, {int limit = 50}) async {
    final data = await _api.get(
      '/orders',
      query: {
        'select': 'id,order_no,status,grand_total,currency_code,note,created_at',
        'customer_id': 'eq.$customerId',
        'order': 'created_at.desc',
        'limit': '$limit',
      },
      schema: ApiConfig.schemaPublic,
    );
    return (data as List).map((e) => OrderRow.fromJson(e as Map<String, dynamic>)).toList();
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

  /// Creates an order header + lines and returns the generated order_no.
  Future<String> createOrder({
    required String customerId,
    required List<CartLine> lines,
    String? note,
  }) async {
    double subtotal = 0, tax = 0, grand = 0;
    for (final l in lines) {
      subtotal += l.gross;
      tax += l.tax;
      grand += l.total;
    }

    final orderNo = 'WEB-${DateTime.now().millisecondsSinceEpoch}';
    final created = await _api.post(
      '/orders',
      {
        'order_no': orderNo,
        'customer_id': customerId,
        'status': 'open',
        'subtotal': subtotal,
        'discount_total': 0,
        'tax_total': tax,
        'grand_total': grand,
        if (note != null && note.isNotEmpty) 'note': note,
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
