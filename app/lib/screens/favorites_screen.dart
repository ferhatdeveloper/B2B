import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _future = app.service.favoriteProducts(app.user?.customerId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 1300 ? 5 : width >= 1000 ? 4 : width >= 680 ? 3 : 2;
    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        final products = snap.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text('Henüz favori ürününüz yok.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.66,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(
            product: products[i],
            onAdd: () {
              context.read<AppState>().addToCart(products[i]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${products[i].name} sepete eklendi'), duration: const Duration(seconds: 1)),
              );
            },
          ),
        );
      },
    );
  }
}