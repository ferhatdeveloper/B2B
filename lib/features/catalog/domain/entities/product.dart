import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.currencyCode,
    required this.price,
    this.description,
    this.brand,
    this.unit = 'ADET',
    this.taxRate = 20,
    this.stockQty = 0,
    this.imageUrl,
    this.isFeatured = false,
    this.isCampaign = false,
    this.isDiscounted = false,
    this.isPersonal = false,
    this.categoryName,
    this.categorySlug,
  });

  final String id;
  final String sku;
  final String name;
  final String currencyCode;
  final double price;
  final String? description;
  final String? brand;
  final String unit;
  final double taxRate;
  final double stockQty;
  final String? imageUrl;
  final bool isFeatured;
  final bool isCampaign;
  final bool isDiscounted;
  final bool isPersonal;
  final String? categoryName;
  final String? categorySlug;

  String get priceLabel {
    final symbol = currencyCode == 'USD' ? r'$' : '₺';
    return '$symbol ${price.toStringAsFixed(2)} + Kdv';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? 'TRY',
      price: _toDouble(json['price']),
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      unit: json['unit'] as String? ?? 'ADET',
      taxRate: _toDouble(json['tax_rate']),
      stockQty: _toDouble(json['stock_qty']),
      imageUrl: json['image_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      isCampaign: json['is_campaign'] as bool? ?? false,
      isDiscounted: json['is_discounted'] as bool? ?? false,
      isPersonal: json['is_personal'] as bool? ?? false,
      categoryName: json['category_name'] as String?,
      categorySlug: json['category_slug'] as String?,
    );
  }

  static double _toDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [id, sku];
}
