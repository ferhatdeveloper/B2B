import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/product_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.onSeeAllProducts});
  final VoidCallback onSeeAllProducts;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  bool _syncing = false;

  Future<void> _syncLogo() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final res = await ref.read(b2bServiceProvider).syncLogo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logo senkronu tamam: ${res['products']} ürün, ${res['customers']} cari (${res['mode']})')),
        );
        setState(() => _future = _load());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logo senkronu başarısız: $e')));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<_DashboardData> _load() async {
    final svc = ref.read(b2bServiceProvider);
    final user = ref.read(authProvider)!;
    final results = await Future.wait([
      user.customerId != null ? svc.dashboard(user.customerId!) : Future.value(null),
      svc.products(flag: 'is_featured', limit: 8),
      svc.products(flag: 'is_campaign', limit: 8),
      svc.categories(),
    ]);
    return _DashboardData(
      summary: results[0] as DashboardSummary?,
      featured: results[1] as List<Product>,
      campaign: results[2] as List<Product>,
      categories: results[3] as List<Category>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider)!;
    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _ErrorView(message: '${snap.error}', onRetry: () => setState(() => _future = _load()));
        }
        final data = snap.data!;
        final s = data.summary;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroBanner(name: user.fullName, company: user.customerTitle ?? '-', onSync: () => _syncLogo()),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width >= 1100 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 2.2,
              children: [
                _MetricCard(
                    icon: Icons.account_balance_wallet,
                    color: AppColors.brand,
                    label: 'Bakiye',
                    value: money(s?.balance ?? user.balance)),
                _MetricCard(
                    icon: Icons.credit_score,
                    color: AppColors.accent,
                    label: 'Kredi Limiti',
                    value: money(s?.creditLimit ?? user.creditLimit)),
                _MetricCard(
                    icon: Icons.shopping_cart,
                    color: AppColors.warn,
                    label: 'Açık Sipariş',
                    value: '${s?.openOrderCount ?? 0}'),
                _MetricCard(
                    icon: Icons.warning_amber,
                    color: AppColors.danger,
                    label: 'Vadesi Geçen',
                    value: money(s?.pastDueBalance ?? user.pastDueBalance)),
              ],
            ),
            const SizedBox(height: 24),
            _CategoryStrip(categories: data.categories),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Öne Çıkan Ürünler', onSeeAll: widget.onSeeAllProducts),
            const SizedBox(height: 12),
            _ProductRow(products: data.featured),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Kampanyalı Ürünler', onSeeAll: widget.onSeeAllProducts),
            const SizedBox(height: 12),
            _ProductRow(products: data.campaign),
          ],
        );
      },
    );
  }
}

class _DashboardData {
  _DashboardData({required this.summary, required this.featured, required this.campaign, required this.categories});
  final DashboardSummary? summary;
  final List<Product> featured;
  final List<Product> campaign;
  final List<Category> categories;
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.name, required this.company, required this.onSync});
  final String name;
  final String company;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoş geldiniz, $name',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(company, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onSync,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text("Logo'dan Senkronla"),
                ),
              ],
            ),
          ),
          const Icon(Icons.storefront, color: Colors.white24, size: 64),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  const SizedBox(height: 3),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories});
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          const palette = [
            [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            [Color(0xFF10B981), Color(0xFF22C55E)],
            [Color(0xFFF59E0B), Color(0xFFF97316)],
            [Color(0xFFEC4899), Color(0xFFF43F5E)],
          ];
          const icons = [
            Icons.devices_other, Icons.checkroom, Icons.chair_outlined, Icons.handyman,
            Icons.toys_outlined, Icons.sports_soccer, Icons.spa_outlined, Icons.menu_book,
            Icons.local_cafe_outlined, Icons.tire_repair,
          ];
          final c = categories[i];
          final colors = palette[i % palette.length];
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors),
                  boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Icon(icons[i % icons.length], color: Colors.white, size: 26),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 72,
                child: Text(c.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        TextButton(onPressed: onSeeAll, child: const Text('Tümünü gör')),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('Ürün bulunamadı.')));
    }
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => SizedBox(
          width: 200,
          child: ProductCard(
            product: products[i],
            onAdd: () {
              ref.read(cartProvider.notifier).addToCart(products[i]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${products[i].name} sepete eklendi'), duration: const Duration(seconds: 1)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
