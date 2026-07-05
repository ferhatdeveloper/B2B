import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/app_providers.dart';
import '../models/models.dart';
import '../services/b2b_service.dart';
import '../utils/format.dart';
import 'storefront_theme.dart';

/// Public e-commerce storefront (B2C/C2C). Guests can browse and place orders.
/// Layout inspired by clean B2B supply stores (e.g. zetem.co.uk): two-tier
/// header, category strip, product grid, three-column footer.
class StorefrontShell extends ConsumerStatefulWidget {
  const StorefrontShell({super.key});

  @override
  ConsumerState<StorefrontShell> createState() => _StorefrontShellState();
}

class _StorefrontShellState extends ConsumerState<StorefrontShell> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _categorySlug;
  List<Category> _categories = [];
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadCats();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<Product>> _load() => ref.read(b2bServiceProvider).products(
        search: _search.isEmpty ? null : _search,
        categorySlug: _categorySlug,
        limit: 100,
      );

  Future<void> _loadCats() async {
    try {
      final c = await ref.read(b2bServiceProvider).categories();
      if (mounted) setState(() => _categories = c);
    } catch (_) {}
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final storeTheme = ref.watch(appSettingsProvider.select((s) => s.storeTheme));
    final cartCount = ref.watch(cartCountProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final t = storeThemeData(storeTheme);
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 1280 ? 5 : width >= 1000 ? 4 : width >= 680 ? 3 : 2;

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Column(
        children: [
          _UtilityBar(t: t, isPreview: isLoggedIn),
          _MainHeader(t: t, cartCount: cartCount, searchCtrl: _searchCtrl, onSearch: (v) {
            _search = v.trim();
            _refresh();
          }, onCart: () => _openCart(context, t)),
          _CategoryBar(t: t, categories: _categories, selected: _categorySlug, onSelect: (s) {
            setState(() => _categorySlug = s);
            _refresh();
          }),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) return Center(child: Text('${snap.error}'));
                final products = snap.data ?? [];
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _Hero(t: t)),
                    if (_categories.isNotEmpty && _categorySlug == null && _search.isEmpty)
                      SliverToBoxAdapter(child: _CategoryCards(t: t, categories: _categories, onSelect: (s) {
                        setState(() => _categorySlug = s);
                        _refresh();
                      })),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
                        child: Row(
                          children: [
                            Text(_categorySlug == null && _search.isEmpty ? 'Öne Çıkan Ürünler' : 'Ürünler',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                            const Spacer(),
                            Text('${products.length} ürün', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    if (products.isEmpty)
                      const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(48), child: Center(child: Text('Ürün bulunamadı.'))))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 18,
                            childAspectRatio: 0.62,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _StoreProductCard(t: t, product: products[i], onTap: () => _quickView(context, t, products[i])),
                            childCount: products.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: _Footer(t: t, categories: _categories)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _quickView(BuildContext context, StoreThemeData t, Product p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Container(
                      color: const Color(0xFFF1F5F9),
                      child: p.imageUrl == null
                          ? const Icon(Icons.image_outlined, size: 48, color: Color(0xFFCBD5E1))
                          : Image.network(p.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFCBD5E1))),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(p.sku, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(money(p.price, p.currencyCode), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.primary)),
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: t.accent),
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(p);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} sepete eklendi'), duration: const Duration(seconds: 1)));
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Sepete Ekle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCart(BuildContext context, StoreThemeData t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CartSheet(t: t),
    );
  }
}

class _UtilityBar extends ConsumerWidget {
  const _UtilityBar({required this.t, required this.isPreview});
  final StoreThemeData t;
  final bool isPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(appSettingsProvider.notifier);
    final bar = t.darkHeader ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFEFF3F5);
    final fg = t.darkHeader ? Colors.white70 : const Color(0xFF4B5563);
    final narrow = MediaQuery.of(context).size.width < 620;
    return Container(
      color: bar,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.support_agent, size: 15, color: fg),
          const SizedBox(width: 6),
          if (!narrow) Text('Destek: +90 850 000 00 00', style: TextStyle(color: fg, fontSize: 12)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => isPreview ? settings.exitStorefrontPreview() : settings.requestDealerLogin(),
            style: TextButton.styleFrom(foregroundColor: t.darkHeader ? Colors.white : t.primary, padding: const EdgeInsets.symmetric(horizontal: 8)),
            icon: Icon(isPreview ? Icons.dashboard : Icons.store_mall_directory, size: 16),
            label: Text(isPreview ? 'Panele Dön' : 'Bayi Girişi', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MainHeader extends ConsumerWidget {
  const _MainHeader({required this.t, required this.cartCount, required this.searchCtrl, required this.onSearch, required this.onCart});
  final StoreThemeData t;
  final int cartCount;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(appSettingsProvider.notifier);
    final width = MediaQuery.of(context).size.width;
    final showSearch = width >= 720;
    final fg = t.headerFg;
    return Material(
      color: t.headerBg,
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text('EXFIN', style: TextStyle(color: fg, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            Text(' B2B', style: TextStyle(color: t.accent, fontSize: 22, fontWeight: FontWeight.w900)),
            if (showSearch) ...[
              const SizedBox(width: 28),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearch,
                    decoration: InputDecoration(
                      hintText: 'Ürün, SKU veya marka ara…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: t.darkHeader ? Colors.white : const Color(0xFFF1F5F9),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.accent.withValues(alpha: 0.4))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ] else
              const Spacer(),
            PopupMenuButton<StoreTheme>(
              tooltip: 'Tema seç',
              icon: Icon(Icons.palette_outlined, color: fg),
              onSelected: settings.setStoreTheme,
              itemBuilder: (_) => [
                for (final th in StoreTheme.values) PopupMenuItem(value: th, child: Text(storeThemeData(th).label)),
              ],
            ),
            const SizedBox(width: 4),
            FilledButton.icon(
              onPressed: onCart,
              style: FilledButton.styleFrom(backgroundColor: t.accent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_cart_outlined, size: 20)),
              label: const Text('Sepet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.t, required this.categories, required this.selected, required this.onSelect});
  final StoreThemeData t;
  final List<Category> categories;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Container(
      color: t.headerBg,
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _navItem(context, 'Tümü', selected == null, () => onSelect(null)),
            for (final c in categories) _navItem(context, c.name, selected == c.slug, () => onSelect(c.slug)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, bool sel, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: sel ? t.accent : Colors.transparent, width: 3)),
          ),
          child: Text(label, style: TextStyle(color: sel ? t.accent : const Color(0xFF374151), fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 13.5)),
        ),
      );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.t});
  final StoreThemeData t;

  @override
  Widget build(BuildContext context) {
    final dark = t.darkHeader;
    final titleColor = dark ? Colors.white : const Color(0xFF0F2A30);
    final wide = MediaQuery.of(context).size.width >= 800;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(gradient: t.heroGradient, borderRadius: BorderRadius.circular(t.cardRadius + 6)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(20)),
                  child: const Text('B2B • C2C • TOPTAN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 16),
                Text(t.heroTitle, style: TextStyle(color: titleColor, fontSize: 34, fontWeight: FontWeight.w900, height: 1.08)),
                const SizedBox(height: 12),
                Text(t.heroSubtitle, style: TextStyle(color: dark ? Colors.white70 : const Color(0xFF334155), fontSize: 15, height: 1.45)),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: t.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16)),
                  onPressed: () {},
                  child: const Text('Ürünleri İncele'),
                ),
              ],
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Container(
                height: 180,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.local_shipping_outlined, size: 84, color: t.primary.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCards extends StatelessWidget {
  const _CategoryCards({required this.t, required this.categories, required this.onSelect});
  final StoreThemeData t;
  final List<Category> categories;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          child: Row(
            children: [
              const Text('Kategoriler', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(onPressed: () => onSelect(null), style: TextButton.styleFrom(foregroundColor: t.accent), child: const Text('Tümünü gör →')),
            ],
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = categories[i];
              return InkWell(
                onTap: () => onSelect(c.slug),
                borderRadius: BorderRadius.circular(t.cardRadius),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(t.cardRadius)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.category_outlined, color: t.primary, size: 22),
                      Text(c.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoreProductCard extends ConsumerWidget {
  const _StoreProductCard({required this.t, required this.product, required this.onTap});
  final StoreThemeData t;
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(t.cardRadius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(t.cardRadius),
          border: Border.all(color: const Color(0xFFEAEEF2)),
          boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 12, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Container(
                color: const Color(0xFFF6F8FA),
                child: product.imageUrl == null
                    ? const Icon(Icons.image_outlined, size: 36, color: Color(0xFFCBD5E1))
                    : Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Center(child: Icon(Icons.inventory_2_outlined, size: 34, color: Color(0xFFCBD5E1)))),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.sku, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Expanded(
                      child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.25)),
                    ),
                    Text(money(product.price, product.currencyCode), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: t.primary)),
                    const Text('+ KDV', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: t.accent, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} sepete eklendi'), duration: const Duration(seconds: 1)));
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Sepete Ekle', style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.t, required this.categories});
  final StoreThemeData t;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 760;
    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('EXFIN B2B', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        SizedBox(width: 240, child: Text('Bayi ve toptan müşteriler için güvenli B2B/C2C tedarik platformu.', style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5))),
      ],
    );
    final links = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Bağlantılar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        SizedBox(height: 10),
        Text('Ürünler', style: TextStyle(color: Colors.white60, fontSize: 13)),
        SizedBox(height: 6),
        Text('Hakkımızda', style: TextStyle(color: Colors.white60, fontSize: 13)),
        SizedBox(height: 6),
        Text('İletişim', style: TextStyle(color: Colors.white60, fontSize: 13)),
        SizedBox(height: 6),
        Text('Bayi Girişi', style: TextStyle(color: Colors.white60, fontSize: 13)),
      ],
    );
    final cats = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategoriler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final c in categories.take(5))
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(c.name, style: const TextStyle(color: Colors.white60, fontSize: 13))),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
      color: const Color(0xFF0F172A),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: brand), Expanded(child: links), Expanded(child: cats)])
          else
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [brand, const SizedBox(height: 20), links, const SizedBox(height: 20), cats]),
          const Divider(color: Colors.white12, height: 36),
          const Text('© 2026 EXFIN B2B · Tüm hakları saklıdır.', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CartSheet extends ConsumerStatefulWidget {
  const _CartSheet({required this.t});
  final StoreThemeData t;

  @override
  ConsumerState<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends ConsumerState<_CartSheet> {
  bool _checkingOut = false;

  Future<void> _checkout() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sipariş Bilgileri'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 10),
              TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Siparişi Tamamla'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _checkingOut = true);
    try {
      final orderNo = await ref.read(cartProvider.notifier).checkoutGuest(name: name.text.trim(), email: email.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: Icon(Icons.check_circle, color: widget.t.accent, size: 48),
          title: const Text('Siparişiniz alındı'),
          content: Text('Sipariş numaranız:\n$orderNo'),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam'))],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _checkingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş oluşturulamadı: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final grandTotal = ref.watch(cartGrandTotalProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sepetim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (cart.isEmpty)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Sepetiniz boş.')))
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cart.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (_, i) {
                  final l = cart[i];
                  return Row(
                    children: [
                      Expanded(child: Text(l.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      _Stepper(qty: l.qty, onChanged: (q) => cartNotifier.setQty(l.product.id, q)),
                      const SizedBox(width: 10),
                      SizedBox(width: 90, child: Text(money(l.total, l.product.currencyCode), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
                      IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => cartNotifier.removeFromCart(l.product.id)),
                    ],
                  );
                },
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              const Text('Toplam', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Text(money(grandTotal), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: widget.t.accent),
              onPressed: (cart.isEmpty || _checkingOut) ? null : _checkout,
              icon: _checkingOut ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.shopping_bag),
              label: Text(_checkingOut ? 'Gönderiliyor…' : 'Siparişi Tamamla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove, size: 16), onPressed: () => onChanged(qty - 1)),
          Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, size: 16), onPressed: () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}
