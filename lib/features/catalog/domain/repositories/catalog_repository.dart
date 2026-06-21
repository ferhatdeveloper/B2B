import '../entities/product.dart';

abstract interface class CatalogRepository {
  Future<List<Product>> getFeaturedProducts({int limit = 12});

  Future<List<Product>> getCampaignProducts({int limit = 12});

  Future<List<Product>> getDiscountedProducts({int limit = 12});

  Future<List<Product>> searchProducts(String query, {int limit = 24});
}
