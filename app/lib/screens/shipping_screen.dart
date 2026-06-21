import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  late Future<List<ShippingAddress>> _future;

  String get _cid => context.read<AppState>().user?.customerId ?? '';

  @override
  void initState() {
    super.initState();
    _future = context.read<AppState>().service.shippingAddresses(_cid);
  }

  void _reload() => setState(() => _future = context.read<AppState>().service.shippingAddresses(_cid));

  Future<void> _addDialog() async {
    final title = TextEditingController();
    final line = TextEditingController();
    final city = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Sevk Adresi'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Başlık')),
              const SizedBox(height: 10),
              TextField(controller: line, decoration: const InputDecoration(labelText: 'Adres')),
              const SizedBox(height: 10),
              TextField(controller: city, decoration: const InputDecoration(labelText: 'Şehir')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty || line.text.trim().isEmpty) return;
              await context.read<AppState>().service.addShippingAddress(
                    _cid,
                    title: title.text.trim(),
                    addressLine: line.text.trim(),
                    city: city.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (added == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDialog,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni Adres', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<ShippingAddress>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Sevk adresi bulunamadı.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final a = items[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.brand),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                if (a.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                                    child: const Text('Varsayılan', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('${a.addressLine}${a.city != null ? ' · ${a.city}' : ''}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                          ],
                        ),
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