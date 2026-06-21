import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'account_screen.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'dashboard_screen.dart';
import 'orders_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Ana Sayfa', 'Ürünler', 'Sepet', 'Siparişlerim', 'Cari Hesap'];

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pages = [
      DashboardScreen(onSeeAllProducts: () => _go(1)),
      const CatalogScreen(),
      CartScreen(onContinueShopping: () => _go(1)),
      const OrdersScreen(),
      const AccountScreen(),
    ];
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          if (wide) _SideNav(index: _index, onSelect: _go, user: app.user?.fullName ?? ''),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: _titles[_index],
                  cartCount: app.cartCount,
                  onCart: () => _go(2),
                  onLogout: () => context.read<AppState>().logout(),
                ),
                Expanded(child: pages[_index]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _go,
              destinations: [
                const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
                const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Ürünler'),
                NavigationDestination(
                  icon: Badge(label: Text('${app.cartCount}'), isLabelVisible: app.cartCount > 0, child: const Icon(Icons.shopping_cart_outlined)),
                  label: 'Sepet',
                ),
                const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Sipariş'),
                const NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Cari'),
              ],
            ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.index, required this.onSelect, required this.user});
  final int index;
  final ValueChanged<int> onSelect;
  final String user;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, 'Ana Sayfa'),
      (Icons.grid_view_outlined, 'Ürünler'),
      (Icons.shopping_cart_outlined, 'Sepet'),
      (Icons.receipt_long_outlined, 'Siparişlerim'),
      (Icons.account_balance_wallet_outlined, 'Cari Hesap'),
    ];
    return Container(
      width: 248,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
            child: Row(
              children: const [
                Icon(Icons.storefront, color: Colors.white, size: 26),
                SizedBox(width: 10),
                Text('Zen B2B/C2C',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Material(
                color: index == i ? AppColors.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    child: Row(
                      children: [
                        Icon(items[i].$1, color: Colors.white, size: 20),
                        const SizedBox(width: 14),
                        Text(items[i].$2,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: index == i ? FontWeight.w700 : FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: AppColors.brandAlt, child: Icon(Icons.person, color: Colors.white, size: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(user,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
  const _TopBar({required this.title, required this.cartCount, required this.onCart, required this.onLogout});
  final String title;
  final int cartCount;
  final VoidCallback onCart;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
              onPressed: onCart,
              icon: Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(onPressed: onLogout, tooltip: 'Çıkış', icon: const Icon(Icons.logout)),
          ],
        ),
      ),
    );
  }
}
