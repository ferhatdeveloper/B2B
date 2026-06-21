import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(orderDraftProvider);
    final submitState = ref.watch(submitOrderProvider);

    ref.listen(submitOrderProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Siparis olustu: ${next.value}')),
        );
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sepet / Siparis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (draft.lines.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Sepet bos.'),
              ),
            )
          else
            ...draft.lines.map(
              (line) => Card(
                child: ListTile(
                  title: Text(line.product.name),
                  subtitle: Text('${line.quantity.toStringAsFixed(0)} ${line.product.unit}'),
                  trailing: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('₺ ${line.grandTotal.toStringAsFixed(2)}'),
                      IconButton(
                        onPressed: () {
                          ref.read(orderDraftProvider.notifier).removeProduct(line.product);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TotalRow(label: 'Ara Toplam', value: draft.subtotal),
                  _TotalRow(label: 'Kdv', value: draft.taxTotal),
                  const Divider(),
                  _TotalRow(label: 'Genel Toplam', value: draft.grandTotal, strong: true),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: draft.lines.isEmpty || submitState.isLoading
                        ? null
                        : () => ref.read(submitOrderProvider.notifier).submit(),
                    child: submitState.isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Siparisi Gonder'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final double value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₺ ${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
