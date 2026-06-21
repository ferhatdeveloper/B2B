import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String? _categorySlug;
  List<Category> _categories = [];
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadProducts();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await context.read<AppState>().service.categories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {/* ignore */}
  }

  Future<List<Product>> _loadProducts() {
    return context.read<AppState>().service.products(
          search: _search.isEmpty ? null : _search,
          categorySlug: _categorySlug,
          limit: 100,
        );
  }

  void _refresh() => setState(() => _future = _loadProducts());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 1300
        ? 5
        : width >= 1000
            ? 4
            : width >= 680
                ? 3
                : 2;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) {
                  _search = v.trim();
                  _refresh();
                },
                decoration: InputDecoration(
                  hintText: 'Ürün, SKU veya marka ara…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _search = '';
                            _refresh();
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CatChip(
                      label: 'Tümü',
                      selected: _categorySlug == null,
                      onTap: () {
                        setState(() => _categorySlug = null);
                        _refresh();
                      },
                    ),
                    for (final c in _categories)
                      _CatChip(
                        label: c.name,
                        selected: _categorySlug == c.slug,
                        onTap: () {
                          setState(() => _categorySlug = c.slug);
                          _refresh();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Hata: ${snap.error}'));
              }
              final products = snap.data ?? [];
              if (products.isEmpty) {
                return const Center(child: Text('Bu kritere uygun ürün bulunamadı.'));
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
          ),
        ),
      ],
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brand,
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        showCheckmark: false,
      ),
    );
  }
}
