import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import 'storefront_theme.dart';

/// Public e-commerce storefront (B2C/C2C). Guests can browse and place orders.
/// A "Bayi Girişi" action in the header switches to the dealer panel login.
class StorefrontShell extends StatefulWidget {
  const StorefrontShell({super.key});

  @override
  State<StorefrontShell> createState() => _StorefrontShellState();
}

class _StorefrontShellState extends State<StorefrontShell> {
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

  Future<List<Product>> _load() => context.read<AppState>().service.products(
        search: _search.isEmpty ? null : _search,
        categorySlug: _categorySlug,
        limit: 100,
      );

  Future<void> _loadCats() async {
    try {
      final c = await context.read<AppState>().service.categories();
      if (mounted) setState(() => _categories = c);
    } catch (_) {}
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = storeThemeData(app.storeTheme);
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 1300 ? 5 : width >= 1000 ? 4 : width >= 680 ? 3 : 2;

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Column(
        children: [
          _StoreHeader(
            t: t,
            cartCount: app.cartCount,
            searchCtrl: _searchCtrl,
            onSearch: (v) {
              _search = v.trim();
              _refresh();
            },
            onCart: () => _openCart(context, t),
            isPreview: app.isLoggedIn,
          ),
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
                    SliverToBoxAdapter(child: _CategoryBar(t: t, categories: _categories, selected: _categorySlug, onSelect: (s) {
                      setState(() => _categorySlug = s);
                      _refresh();
                    })),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                        child: Text(_categorySlug == null && _search.isEmpty ? 'Tüm Ürünler' : 'Sonuçlar',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (products.isEmpty)
                      const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Ürün bulunamadı.'))))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.64,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _StoreProductCard(t: t, product: products[i], onTap: () => _quickView(context, t, products[i])),
                            childCount: products.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: _Footer(t: t)),
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
                        context.read<AppState>().addToCart(p);
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

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.t, required this.cartCount, required this.searchCtrl, required this.onSearch, required this.onCart, required this.isPreview});
  final StoreThemeData t;
  final int cartCount;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final VoidCallback onCart;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final wide = MediaQuery.of(context).size.width >= 760;
    final fg = t.headerFg;
    return Material(
      color: t.headerBg,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.shopping_bag, color: t.darkHeader ? t.headerFg : t.accent),
            const SizedBox(width: 8),
            Text('ZenShop', style: TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(width: 20),
            if (wide)
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearch,
                    decoration: InputDecoration(
                      hintText: 'Ürün ara…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: t.darkHeader ? Colors.white : const Color(0xFFF1F5F9),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            const SizedBox(width: 12),
            // Theme switcher (quick demo of multiple designs).
            PopupMenuButton<StoreTheme>(
              tooltip: 'Tema',
              icon: Icon(Icons.palette_outlined, color: fg),
              onSelected: app.setStoreTheme,
              itemBuilder: (_) => [
                for (final th in StoreTheme.values)
                  PopupMenuItem(value: th, child: Text(storeThemeData(th).label)),
              ],
            ),
            IconButton(
              onPressed: onCart,
              icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: Icon(Icons.shopping_cart_outlined, color: fg)),
            ),
            const SizedBox(width: 4),
            if (isPreview)
              OutlinedButton.icon(
                onPressed: () => app.exitStorefrontPreview(),
                style: OutlinedButton.styleFrom(foregroundColor: fg, side: BorderSide(color: fg.withValues(alpha: 0.5))),
                icon: const Icon(Icons.dashboard, size: 18),
                label: const Text('Panele Dön'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => app.requestDealerLogin(),
                style: OutlinedButton.styleFrom(foregroundColor: fg, side: BorderSide(color: fg.withValues(alpha: 0.5))),
                icon: const Icon(Icons.store_mall_directory, size: 18),
                label: const Text('Bayi Girişi'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.t});
  final StoreThemeData t;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(gradient: t.heroGradient, borderRadius: BorderRadius.circular(t.cardRadius + 6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.heroTitle, style: TextStyle(color: t.darkHeader ? Colors.white : const Color(0xFF111827), fontSize: 34, fontWeight: FontWeight.w900, height: 1.05)),
                const SizedBox(height: 12),
                Text(t.heroSubtitle, style: TextStyle(color: t.darkHeader ? Colors.white70 : const Color(0xFF374151), fontSize: 15, height: 1.4)),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: t.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                  onPressed: () {},
                  child: const Text('Alışverişe Başla'),
                ),
              ],
            ),
          ),
        ],
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
    if (categories.isEmpty) return const SizedBox(height: 8);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _chip(context, 'Tümü', selected == null, () => onSelect(null)),
          for (final c in categories) _chip(context, c.name, selected == c.slug, () => onSelect(c.slug)),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool sel, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: sel,
          onSelected: (_) => onTap(),
          selectedColor: t.primary,
          labelStyle: TextStyle(color: sel ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.w600),
          showCheckmark: false,
        ),
      );
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard({required this.t, required this.product, required this.onTap});
  final StoreThemeData t;
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(t.cardRadius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(t.cardRadius),
          border: Border.all(color: const Color(0xFFEEF2F7)),
          boxShadow: const [BoxShadow(color: Color(0x10101828), blurRadius: 10, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Container(
                color: const Color(0xFFF6F7F9),
                child: product.imageUrl == null
                    ? const Icon(Icons.image_outlined, size: 36, color: Color(0xFFCBD5E1))
                    : Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Center(child: Icon(Icons.inventory_2_outlined, size: 34, color: Color(0xFFCBD5E1)))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.2)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text(money(product.price, product.currencyCode), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: t.primary))),
                      Material(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            context.read<AppState>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} sepete eklendi'), duration: const Duration(seconds: 1)));
                          },
                          child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.t});
  final StoreThemeData t;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(28),
      color: const Color(0xFF111827),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('ZenShop', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('Zensoft B2B/C2C · Güvenli ödeme · Hızlı teslimat', style: TextStyle(color: Colors.white60, fontSize: 13)),
          SizedBox(height: 6),
          Text('© 2026 Zensoft Yazılım A.Ş.', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CartSheet extends StatefulWidget {
  const _CartSheet({required this.t});
  final StoreThemeData t;

  @override
  State<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<_CartSheet> {
  bool _checkingOut = false;

  Future<void> _checkout(AppState app) async {
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
      final orderNo = await app.checkoutGuest(name: name.text.trim(), email: email.text.trim());
      if (!mounted) return;
      Navigator.pop(context); // close cart sheet
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
    final app = context.watch<AppState>();
    final cart = app.cart;
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
                      _Stepper(qty: l.qty, onChanged: (q) => app.setQty(l.product.id, q)),
                      const SizedBox(width: 10),
                      SizedBox(width: 90, child: Text(money(l.total, l.product.currencyCode), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
                      IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => app.removeFromCart(l.product.id)),
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
              Text(money(app.cartGrandTotal), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: widget.t.accent),
              onPressed: (cart.isEmpty || _checkingOut) ? null : () => _checkout(app),
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
