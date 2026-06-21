import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils/app_location.dart';
import 'account_screen.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'dashboard_screen.dart';
import 'favorites_screen.dart';
import 'finance_screens.dart';
import 'info_screens.dart';
import 'orders_screen.dart';
import 'payment_screen.dart';
import 'shipping_screen.dart';
import 'statement_screen.dart';

class NavItem {
  const NavItem(this.group, this.label, this.icon, this.builder);
  final String group;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handlePaymentReturn());
  }

  void _handlePaymentReturn() {
    final search = currentSearch();
    if (!mounted) return;
    if (search.contains('payment=success')) {
      clearQuery();
      setState(() => _index = 10); // Ödemelerim
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödemeniz alındı. "Ödemelerim" listesinde görebilirsiniz.'), backgroundColor: AppColors.accent),
      );
    } else if (search.contains('payment=cancel')) {
      clearQuery();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödeme iptal edildi.')));
    }
  }

  late final List<NavItem> _items = [
    NavItem('Mağaza', 'Ana Sayfa', Icons.home_outlined, (_) => DashboardScreen(onSeeAllProducts: () => _go(1))),
    NavItem('Mağaza', 'Ürünler', Icons.grid_view_outlined, (_) => const CatalogScreen()),
    NavItem('Mağaza', 'Favorilerim', Icons.favorite_border, (_) => const FavoritesScreen()),
    NavItem('Mağaza', 'Kampanyalar', Icons.local_offer_outlined, (_) => const CampaignsScreen()),
    NavItem('Mağaza', 'Duyurular', Icons.campaign_outlined, (_) => const AnnouncementsScreen()),
    NavItem('Mağaza', 'Sepet', Icons.shopping_cart_outlined, (_) => CartScreen(onContinueShopping: () => _go(1))),
    NavItem('Siparişler', 'Siparişlerim', Icons.receipt_long_outlined, (_) => const OrdersScreen()),
    NavItem('Siparişler', 'Bekleyen Siparişler', Icons.hourglass_bottom, (_) => const OrdersScreen(status: 'pending', emptyMessage: 'Bekleyen sipariş yok.')),
    NavItem('Siparişler', 'Önceki Siparişler', Icons.history, (_) => const OrdersScreen(status: 'completed', emptyMessage: 'Tamamlanmış sipariş yok.')),
    NavItem('Finans', 'Ödeme Yap', Icons.credit_card, (_) => const PaymentScreen()),
    NavItem('Finans', 'Ödemelerim', Icons.payments_outlined, (_) => const PaymentsListScreen()),
    NavItem('Finans', 'Cari Ekstre', Icons.account_balance_wallet_outlined, (_) => const StatementScreen()),
    NavItem('Finans', 'Ödenmemiş Faturalar', Icons.description_outlined, (_) => const InvoicesScreen()),
    NavItem('Finans', 'Çek / Senet', Icons.account_balance_outlined, (_) => const ChecksScreen()),
    NavItem('Finans', 'Faturalanmamış İrsaliyeler', Icons.local_shipping_outlined, (_) => const DispatchesScreen()),
    NavItem('Hesap', 'Sevk Adreslerim', Icons.location_on_outlined, (_) => const ShippingAddressesScreen()),
    NavItem('Hesap', 'Cari Hesap', Icons.person_outline, (_) => const AccountScreen()),
  ];

  void _go(int i) {
    setState(() => _index = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final wide = MediaQuery.of(context).size.width >= 1000;
    final nav = _NavList(items: _items, index: _index, onSelect: _go, user: app.user?.fullName ?? '');

    return Scaffold(
      key: _scaffoldKey,
      drawer: wide ? null : Drawer(child: nav),
      body: Row(
        children: [
          if (wide) SizedBox(width: 264, child: nav),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: _items[_index].label,
                  showMenu: !wide,
                  cartCount: app.cartCount,
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onCart: () => _go(5),
                  onLogout: () => context.read<AppState>().logout(),
                ),
                Expanded(child: Builder(builder: _items[_index].builder)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavList extends StatelessWidget {
  const _NavList({required this.items, required this.index, required this.onSelect, required this.user});
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final String user;

  @override
  Widget build(BuildContext context) {
    String? lastGroup;
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      if (it.group != lastGroup) {
        lastGroup = it.group;
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
          child: Text(it.group.toUpperCase(),
              style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ));
      }
      final selected = index == i;
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Material(
          color: selected ? AppColors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Icon(it.icon, color: Colors.white, size: 19),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(it.label,
                        style: TextStyle(color: Colors.white, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 13.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }

    return Container(
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
            child: Row(
              children: const [
                Icon(Icons.storefront, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text('Zen B2B/C2C', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Expanded(child: ListView(padding: EdgeInsets.zero, children: children)),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const CircleAvatar(radius: 16, backgroundColor: AppColors.brandAlt, child: Icon(Icons.person, color: Colors.white, size: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(user, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showMenu,
    required this.cartCount,
    required this.onMenu,
    required this.onCart,
    required this.onLogout,
  });
  final String title;
  final bool showMenu;
  final int cartCount;
  final VoidCallback onMenu;
  final VoidCallback onCart;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (showMenu) IconButton(onPressed: onMenu, icon: const Icon(Icons.menu)),
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
              onPressed: onCart,
              icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_cart_outlined)),
            ),
            IconButton(onPressed: onLogout, tooltip: 'Çıkış', icon: const Icon(Icons.logout)),
          ],
        ),
      ),
    );
  }
}
