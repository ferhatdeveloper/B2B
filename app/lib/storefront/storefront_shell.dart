import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/app_providers.dart';
import '../models/models.dart';
import '../utils/format.dart';
import 'ella/ella_layout.dart';
import 'ella/ella_header.dart';
import 'ella/ella_home_layout.dart';
import 'storefront_theme.dart';

/// Ella HTML Template home layouts (`index.html` … `index-10.html`) + demo görselleri.
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
    final width = MediaQuery.sizeOf(context).width;
    final cols = EllaLayout.productCols(width);
    final filtered = _categorySlug != null || _search.isNotEmpty;

    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'Spartan'),
        primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Spartan'),
      ),
      child: Scaffold(
        backgroundColor: t.scaffoldBg,
        body: Column(
          children: [
            EllaHeader(
              t: t,
              cartCount: cartCount,
              searchCtrl: _searchCtrl,
              onSearch: (v) {
                _search = v.trim();
                _refresh();
              },
              onCart: () => _openCart(context, t),
              categories: _categories,
              selectedCategory: _categorySlug,
              onCategory: (s) {
                setState(() => _categorySlug = s);
                _refresh();
              },
              isPreview: isLoggedIn,
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) return Center(child: Text('${snap.error}'));
                  final products = (snap.data ?? []).asMap().entries.map((e) => enrichProductWithEllaDemo(e.value, e.key)).toList();
                  final sections = EllaHomeLayout.buildBody(
                    theme: storeTheme,
                    t: t,
                    products: products,
                    categories: _categories,
                    gridCols: cols,
                    onCategory: (s) {
                      setState(() => _categorySlug = s);
                      _refresh();
                    },
                    onProduct: (p) => _quickView(context, storeTheme, t, p),
                    filtered: filtered,
                  );
                  return ListView(
                    physics: const ClampingScrollPhysics(),
                    children: sections,
                  );
                },
              ),
            ),
        ],
      ),
      ),
    );
  }

  void _quickView(BuildContext context, StoreTheme theme, StoreThemeData t, Product p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.cardRadius + 8)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(t.cardRadius + 4),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                        ? Image.network(p.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Image.asset(ellaProductImage(theme, 0)!, fit: BoxFit.cover))
                        : Image.asset(ellaProductImage(theme, 0)!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.inventory_2_outlined, size: 48)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(p.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.primary)),
                const SizedBox(height: 4),
                Text(p.sku, style: TextStyle(color: t.mutedText, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(money(p.price, p.currencyCode), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: t.primary)),
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: t.accent, foregroundColor: t.buttonStyle == EllaButtonStyle.goldAccent ? t.primary : Colors.white),
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
      backgroundColor: t.scaffoldBg,
      builder: (_) => _CartSheet(t: t),
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
          FilledButton(onPressed: () { if (name.text.trim().isNotEmpty) Navigator.pop(ctx, true); }, child: const Text('Siparişi Tamamla')),
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
          Text('Sepetim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: widget.t.primary)),
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
              Text('Toplam', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: widget.t.primary)),
              const Spacer(),
              Text(money(grandTotal), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: widget.t.primary)),
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
