import '../../../../core/config/app_config.dart';
import '../../../../core/network/postgrest_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._client);

  final PostgrestClient _client;

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 12}) {
    return _getProducts({'is_featured': 'eq.true', 'limit': limit});
  }

  @override
  Future<List<Product>> getCampaignProducts({int limit = 12}) {
    return _getProducts({'is_campaign': 'eq.true', 'limit': limit});
  }

  @override
  Future<List<Product>> getDiscountedProducts({int limit = 12}) {
    return _getProducts({'is_discounted': 'eq.true', 'limit': limit});
  }

  @override
  Future<List<Product>> searchProducts(String query, {int limit = 24}) {
    if (query.trim().isEmpty) return getFeaturedProducts(limit: limit);
    return _getProducts({
      'or': '(name.ilike.*${query.trim()}*,sku.ilike.*${query.trim()}*)',
      'limit': limit,
    });
  }

  Future<List<Product>> _getProducts(Map<String, Object?> query) async {
    final rows = await _client.get(
      '/product_catalog',
      schema: AppConfig.apiSchema,
      query: {
        'select': '*',
        'order': 'name.asc',
        ...query,
      },
    );
    return rows.map(Product.fromJson).toList();
  }
}
