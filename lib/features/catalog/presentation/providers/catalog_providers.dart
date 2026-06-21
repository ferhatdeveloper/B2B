import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(ref.watch(postgrestClientProvider));
});

final featuredProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRepositoryProvider).getFeaturedProducts();
});

final campaignProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRepositoryProvider).getCampaignProducts();
});

final discountedProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRepositoryProvider).getDiscountedProducts();
});

final productSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final productSearchProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final query = ref.watch(productSearchQueryProvider);
  return ref.watch(catalogRepositoryProvider).searchProducts(query);
});
