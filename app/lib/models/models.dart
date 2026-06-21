double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

bool _toBool(dynamic v) => v == true || v == 'true';

class SessionUser {
  SessionUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.customerId,
    this.customerCode,
    this.customerTitle,
    this.roleName,
    this.balance = 0,
    this.creditLimit = 0,
    this.averageMaturityDays,
    this.pastDueBalance = 0,
  });

  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? customerId;
  final String? customerCode;
  final String? customerTitle;
  final String? roleName;
  final double balance;
  final double creditLimit;
  final int? averageMaturityDays;
  final double pastDueBalance;

  factory SessionUser.fromJson(Map<String, dynamic> j) => SessionUser(
        id: j['id'].toString(),
        username: j['username']?.toString() ?? '',
        fullName: j['full_name']?.toString() ?? '',
        email: j['email']?.toString(),
        customerId: j['customer_id']?.toString(),
        customerCode: j['customer_code']?.toString(),
        customerTitle: j['customer_title']?.toString(),
        roleName: j['role_name']?.toString(),
        balance: _toDouble(j['balance']),
        creditLimit: _toDouble(j['credit_limit']),
        averageMaturityDays:
            j['average_maturity_days'] == null ? null : _toInt(j['average_maturity_days']),
        pastDueBalance: _toDouble(j['past_due_balance']),
      );
}

class Product {
  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.taxRate,
    required this.stockQty,
    this.brand,
    this.unit = 'ADET',
    this.imageUrl,
    this.categoryName,
    this.categorySlug,
    this.isFeatured = false,
    this.isCampaign = false,
    this.isDiscounted = false,
    this.isPersonal = false,
  });

  final String id;
  final String sku;
  final String name;
  final double price;
  final String currencyCode;
  final double taxRate;
  final double stockQty;
  final String? brand;
  final String unit;
  final String? imageUrl;
  final String? categoryName;
  final String? categorySlug;
  final bool isFeatured;
  final bool isCampaign;
  final bool isDiscounted;
  final bool isPersonal;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'].toString(),
        sku: j['sku']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        price: _toDouble(j['price']),
        currencyCode: j['currency_code']?.toString() ?? 'TRY',
        taxRate: _toDouble(j['tax_rate']),
        stockQty: _toDouble(j['stock_qty']),
        brand: j['brand']?.toString(),
        unit: j['unit']?.toString() ?? 'ADET',
        imageUrl: j['image_url']?.toString(),
        categoryName: j['category_name']?.toString(),
        categorySlug: j['category_slug']?.toString(),
        isFeatured: _toBool(j['is_featured']),
        isCampaign: _toBool(j['is_campaign']),
        isDiscounted: _toBool(j['is_discounted']),
        isPersonal: _toBool(j['is_personal']),
      );
}

class Category {
  Category({required this.id, required this.code, required this.name, required this.slug, this.sortOrder = 0});

  final String id;
  final String code;
  final String name;
  final String slug;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'].toString(),
        code: j['code']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        slug: j['slug']?.toString() ?? '',
        sortOrder: _toInt(j['sort_order']),
      );
}

class DashboardSummary {
  DashboardSummary({
    this.openOrderCount = 0,
    this.completedOrderCount = 0,
    this.unpaidInvoiceCount = 0,
    this.balance = 0,
    this.creditLimit = 0,
    this.pastDueBalance = 0,
  });

  final int openOrderCount;
  final int completedOrderCount;
  final int unpaidInvoiceCount;
  final double balance;
  final double creditLimit;
  final double pastDueBalance;

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
        openOrderCount: _toInt(j['open_order_count']),
        completedOrderCount: _toInt(j['completed_order_count']),
        unpaidInvoiceCount: _toInt(j['unpaid_invoice_count']),
        balance: _toDouble(j['balance']),
        creditLimit: _toDouble(j['credit_limit']),
        pastDueBalance: _toDouble(j['past_due_balance']),
      );
}

class OrderRow {
  OrderRow({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.grandTotal,
    required this.currencyCode,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String orderNo;
  final String status;
  final double grandTotal;
  final String currencyCode;
  final DateTime createdAt;
  final String? note;

  factory OrderRow.fromJson(Map<String, dynamic> j) => OrderRow(
        id: j['id'].toString(),
        orderNo: j['order_no']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        grandTotal: _toDouble(j['grand_total']),
        currencyCode: j['currency_code']?.toString() ?? 'TRY',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
        note: j['note']?.toString(),
      );
}

class Campaign {
  Campaign({required this.id, required this.name, required this.discountPct, this.description});

  final String id;
  final String name;
  final double discountPct;
  final String? description;

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
        id: j['id'].toString(),
        name: j['name']?.toString() ?? '',
        discountPct: _toDouble(j['discount_pct']),
        description: j['description']?.toString(),
      );
}

class Announcement {
  Announcement({required this.id, required this.title, required this.body, required this.createdAt});

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: j['id'].toString(),
        title: j['title']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
}
