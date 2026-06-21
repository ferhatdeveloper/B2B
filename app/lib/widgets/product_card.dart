import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';
import '../utils/format.dart';

class ProductBadge {
  const ProductBadge(this.label, this.color);
  final String label;
  final Color color;
}

List<ProductBadge> badgesFor(Product p) {
  final list = <ProductBadge>[];
  if (p.isFeatured) list.add(const ProductBadge('Öne Çıkan', AppColors.brand));
  if (p.isCampaign) list.add(const ProductBadge('Kampanya', AppColors.danger));
  if (p.isDiscounted) list.add(const ProductBadge('İndirim', AppColors.warn));
  if (p.isPersonal) list.add(const ProductBadge('Sana Özel', AppColors.accent));
  return list;
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final badges = badgesFor(product);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.35,
                child: Container(
                  color: const Color(0xFFF1F5F9),
                  child: product.imageUrl == null
                      ? const Icon(Icons.image_outlined, size: 40, color: Color(0xFFCBD5E1))
                      : Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFFCBD5E1)),
                          ),
                        ),
                ),
              ),
              if (badges.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: badges
                        .take(2)
                        .map((b) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: b.color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(b.label,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.25)),
                const SizedBox(height: 2),
                Text(product.sku,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 13,
                        color: product.stockQty > 0 ? AppColors.accent : AppColors.danger),
                    const SizedBox(width: 3),
                    Text('${product.stockQty.toStringAsFixed(0)} ${product.unit}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(money(product.price, product.currencyCode),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                          const Text('+ KDV', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onAdd,
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
