import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.status, this.emptyMessage = 'Henüz sipariş bulunmuyor.'});

  /// Optional status filter ("pending", "completed", ...). Null = all orders.
  final String? status;
  final String emptyMessage;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OrderRow>> _load() {
    final app = context.read<AppState>();
    return app.service.orders(app.user!.customerId ?? '', status: widget.status);
  }

  Color _statusColor(String s) => switch (s) {
        'completed' => AppColors.accent,
        'cancelled' => AppColors.danger,
        'approved' || 'shipped' => AppColors.brand,
        'pending' => AppColors.warn,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _future = _load()),
      child: FutureBuilder<List<OrderRow>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                const Center(child: Icon(Icons.receipt_long_outlined, size: 60, color: Color(0xFFCBD5E1))),
                const SizedBox(height: 12),
                Center(child: Text(widget.emptyMessage, style: const TextStyle(color: AppColors.textMuted))),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final o = orders[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.receipt_long, color: AppColors.brand),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.orderNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text(dateTimeLabel(o.createdAt),
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                            if (o.note != null && o.note!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(o.note!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(money(o.grandTotal, o.currencyCode), style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                color: _statusColor(o.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(o.status,
                                style: TextStyle(color: _statusColor(o.status), fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
