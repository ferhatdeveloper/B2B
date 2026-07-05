import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import '../services/b2b_service.dart';
import '../theme.dart';
import '../utils/format.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, required this.onContinueShopping});
  final VoidCallback onContinueShopping;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _note = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    setState(() => _placing = true);
    try {
      final orderNo = await ref.read(cartProvider.notifier).checkout(note: _note.text.trim());
      if (!mounted) return;
      _note.clear();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.accent, size: 48),
          title: const Text('Siparişiniz alındı'),
          content: Text('Sipariş numarası:\n$orderNo'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş oluşturulamadı: $e')));
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final tax = ref.watch(cartTaxProvider);
    final grandTotal = ref.watch(cartGrandTotalProvider);

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 14),
            const Text('Sepetiniz boş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Ürün ekleyerek hızlıca sipariş oluşturun.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: widget.onContinueShopping,
              icon: const Icon(Icons.grid_view),
              label: const Text('Ürünlere göz at'),
            ),
          ],
        ),
      );
    }

    final list = ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CartLineTile(line: cart[i]),
    );

    final summary = _SummaryCard(
      subtotal: subtotal,
      tax: tax,
      grandTotal: grandTotal,
      note: _note,
      placing: _placing,
      onCheckout: _checkout,
    );

    final wide = MediaQuery.of(context).size.width >= 900;
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: list),
          SizedBox(width: 360, child: summary),
        ],
      );
    }

    return Column(
      children: [
        Expanded(child: list),
        Padding(padding: const EdgeInsets.all(16), child: summary),
      ],
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 56,
                height: 56,
                color: const Color(0xFFF1F5F9),
                child: line.product.imageUrl == null
                    ? const Icon(Icons.inventory_2_outlined, color: Color(0xFFCBD5E1))
                    : Image.network(line.product.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.inventory_2_outlined, color: Color(0xFFCBD5E1))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${money(line.product.price, line.product.currencyCode)} + KDV',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                ],
              ),
            ),
            _QtyStepper(
              qty: line.qty,
              onChanged: (q) => cart.setQty(line.product.id, q),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Text(money(line.total, line.product.currencyCode),
                  textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => cart.removeFromCart(line.product.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove, size: 18), onPressed: () => onChanged(qty - 1)),
          Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, size: 18), onPressed: () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
    required this.note,
    required this.placing,
    required this.onCheckout,
  });

  final double subtotal;
  final double tax;
  final double grandTotal;
  final TextEditingController note;
  final bool placing;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sipariş Özeti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _row('Ara Toplam', money(subtotal)),
            const SizedBox(height: 8),
            _row('KDV', money(tax)),
            const Divider(height: 24),
            _row('Genel Toplam', money(grandTotal), bold: true),
            const SizedBox(height: 14),
            TextField(
              controller: note,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Sipariş notu (opsiyonel)'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: placing ? null : onCheckout,
                icon: placing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(placing ? 'Gönderiliyor…' : 'Siparişi Onayla'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? null : AppColors.textMuted, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 18 : 14)),
      ],
    );
  }
}
