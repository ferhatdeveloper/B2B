import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<DashboardSummary?> _future;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _future = app.user?.customerId == null
        ? Future.value(null)
        : app.service.dashboard(app.user!.customerId!);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppState>().user!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.brand,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(user.customerTitle ?? '-', style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text('Cari kodu: ${user.customerCode ?? '-'} · Rol: ${user.roleName ?? '-'}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<DashboardSummary?>(
          future: _future,
          builder: (context, snap) {
            final s = snap.data;
            return Column(
              children: [
                _StatRow(label: 'Bakiye', value: money(s?.balance ?? user.balance), icon: Icons.account_balance_wallet, color: AppColors.brand),
                _StatRow(label: 'Kredi Limiti', value: money(s?.creditLimit ?? user.creditLimit), icon: Icons.credit_score, color: AppColors.accent),
                _StatRow(label: 'Vadesi Geçen Bakiye', value: money(s?.pastDueBalance ?? user.pastDueBalance), icon: Icons.warning_amber, color: AppColors.danger),
                _StatRow(label: 'Ortalama Vade (gün)', value: '${user.averageMaturityDays ?? '-'}', icon: Icons.timelapse, color: AppColors.warn),
                if (s != null) ...[
                  _StatRow(label: 'Açık Sipariş', value: '${s.openOrderCount}', icon: Icons.shopping_cart, color: AppColors.brand),
                  _StatRow(label: 'Tamamlanan Sipariş', value: '${s.completedOrderCount}', icon: Icons.check_circle, color: AppColors.accent),
                  _StatRow(label: 'Ödenmemiş Fatura', value: '${s.unpaidInvoiceCount}', icon: Icons.description, color: AppColors.danger),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
