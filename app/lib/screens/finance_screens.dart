import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/async_list.dart';

String _cid(BuildContext c) => c.read<AppState>().user?.customerId ?? '';

class PaymentsListScreen extends StatelessWidget {
  const PaymentsListScreen({super.key});

  Color _c(String s) => switch (s) {
        'approved' => AppColors.accent,
        'failed' || 'cancelled' => AppColors.danger,
        _ => AppColors.warn,
      };

  @override
  Widget build(BuildContext context) {
    final svc = context.read<AppState>().service;
    return AsyncList<PaymentRow>(
      loader: () => svc.payments(_cid(context)),
      emptyMessage: 'Ödeme kaydı bulunamadı.',
      emptyIcon: Icons.payments_outlined,
      itemBuilder: (context, p) => RecordCard(
        icon: Icons.payments,
        iconColor: AppColors.brand,
        title: p.paymentNo,
        subtitle: '${p.method} · ${p.provider} · ${dateTimeLabel(p.createdAt)}',
        trailingTop: money(p.amount, p.currencyCode),
        statusLabel: p.status,
        statusColor: _c(p.status),
      ),
    );
  }
}

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<AppState>().service;
    return AsyncList<InvoiceRow>(
      loader: () => svc.openInvoices(_cid(context)),
      emptyMessage: 'Ödenmemiş fatura bulunamadı.',
      emptyIcon: Icons.description_outlined,
      itemBuilder: (context, i) => RecordCard(
        icon: Icons.description,
        iconColor: AppColors.danger,
        title: i.invoiceNo,
        subtitle: i.dueDate == null ? 'Vade: -' : 'Vade: ${shortDate(i.dueDate!)}',
        trailingTop: money(i.amount, i.currencyCode),
        statusLabel: i.status,
        statusColor: i.status == 'partial' ? AppColors.warn : AppColors.danger,
      ),
    );
  }
}

class ChecksScreen extends StatelessWidget {
  const ChecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<AppState>().service;
    return AsyncList<CheckNoteRow>(
      loader: () => svc.checksNotes(_cid(context)),
      emptyMessage: 'Çek/senet bulunamadı.',
      emptyIcon: Icons.account_balance_outlined,
      itemBuilder: (context, c) => RecordCard(
        icon: c.documentType == 'check' ? Icons.account_balance : Icons.note_alt,
        iconColor: AppColors.brandAlt,
        title: '${c.documentType == 'check' ? 'Çek' : 'Senet'} · ${c.documentNo}',
        subtitle: c.dueDate == null ? 'Vade: -' : 'Vade: ${shortDate(c.dueDate!)}',
        trailingTop: money(c.amount),
        statusLabel: c.status,
        statusColor: AppColors.brand,
      ),
    );
  }
}

class DispatchesScreen extends StatelessWidget {
  const DispatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<AppState>().service;
    return AsyncList<DispatchRow>(
      loader: () => svc.unbilledDispatches(_cid(context)),
      emptyMessage: 'Faturalanmamış irsaliye bulunamadı.',
      emptyIcon: Icons.local_shipping_outlined,
      itemBuilder: (context, d) => RecordCard(
        icon: Icons.local_shipping,
        iconColor: AppColors.warn,
        title: d.dispatchNo,
        subtitle: d.dispatchedAt == null ? '' : 'Sevk: ${shortDate(d.dispatchedAt!)}',
        trailingTop: money(d.amount),
        statusLabel: d.status,
        statusColor: AppColors.warn,
      ),
    );
  }
}