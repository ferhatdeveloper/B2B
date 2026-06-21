import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../domain/entities/product.dart';
import '../providers/catalog_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final draft = ref.watch(orderDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Katalog'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text('${draft.lines.length} urun'),
          ),
          if (user == null)
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Giris'),
            )
          else
            TextButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              child: Text(user.customerTitle ?? user.fullName),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(campaignProductsProvider);
          ref.invalidate(discountedProductsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _AccountSummary(),
            SizedBox(height: 20),
            _ProductSection(
              title: 'One Cikan Urunler',
              providerName: _ProductProviderName.featured,
            ),
            SizedBox(height: 20),
            _ProductSection(
              title: 'Kampanyali Urunler',
              providerName: _ProductProviderName.campaign,
            ),
            SizedBox(height: 20),
            _ProductSection(
              title: 'Indirimdekiler',
              providerName: _ProductProviderName.discounted,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSummary extends ConsumerWidget {
  const _AccountSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _Metric(label: 'Musteri', value: user?.customerTitle ?? 'Misafir Kullanici'),
            _Metric(label: 'Musteri Kodu', value: user?.customerCode ?? 'guest'),
            _Metric(label: 'Bakiye', value: '₺ ${(user?.balance ?? 0).toStringAsFixed(2)}'),
            _Metric(label: 'Geciken', value: '₺ ${(user?.pastDueBalance ?? 0).toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

enum _ProductProviderName { featured, campaign, discounted }

class _ProductSection extends ConsumerWidget {
  const _ProductSection({
    required this.title,
    required this.providerName,
  });

  final String title;
  final _ProductProviderName providerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = switch (providerName) {
      _ProductProviderName.featured => ref.watch(featuredProductsProvider),
      _ProductProviderName.campaign => ref.watch(campaignProductsProvider),
      _ProductProviderName.discounted => ref.watch(discountedProductsProvider),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        products.when(
          data: (items) => _ProductGrid(products: items),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Urunler yuklenemedi: $error'),
        ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const Text('Urun bulunamadi.');
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _ProductCard(product: products[index]),
        );
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: product.imageUrl == null
                ? const ColoredBox(color: Color(0xFFE5E7EB))
                : Image.network(product.imageUrl!, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(product.priceLabel, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => ref.read(orderDraftProvider.notifier).addProduct(product),
                    child: const Text('Sepete Ekle'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
