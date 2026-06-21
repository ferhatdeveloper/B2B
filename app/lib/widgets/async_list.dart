import 'package:flutter/material.dart';

import '../theme.dart';

/// Reusable async list with loading / error / empty / pull-to-refresh handling.
class AsyncList<T> extends StatefulWidget {
  const AsyncList({
    super.key,
    required this.loader,
    required this.itemBuilder,
    this.emptyMessage = 'Kayıt bulunamadı.',
    this.emptyIcon = Icons.inbox_outlined,
    this.header,
    this.padding = const EdgeInsets.all(20),
  });

  final Future<List<T>> Function() loader;
  final Widget Function(BuildContext, T) itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget? header;
  final EdgeInsets padding;

  @override
  State<AsyncList<T>> createState() => _AsyncListState<T>();
}

class _AsyncListState<T> extends State<AsyncList<T>> {
  late Future<List<T>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _future = widget.loader()),
      child: FutureBuilder<List<T>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _Message(icon: Icons.cloud_off, text: '${snap.error}');
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(children: [
              if (widget.header != null) widget.header!,
              const SizedBox(height: 100),
              _Message(icon: widget.emptyIcon, text: widget.emptyMessage),
            ]);
          }
          return ListView.separated(
            padding: widget.padding,
            itemCount: items.length + (widget.header != null ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (widget.header != null && i == 0) return widget.header!;
              final item = items[i - (widget.header != null ? 1 : 0)];
              return widget.itemBuilder(context, item);
            },
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Compact card used across the finance/order list screens.
class RecordCard extends StatelessWidget {
  const RecordCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingTop,
    this.trailingBottom,
    this.statusLabel,
    this.statusColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingTop;
  final Widget? trailingBottom;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (trailingTop != null)
                  Text(trailingTop!, style: const TextStyle(fontWeight: FontWeight.w800)),
                if (statusLabel != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: (statusColor ?? AppColors.textMuted).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel!,
                        style: TextStyle(color: statusColor ?? AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
                ?trailingBottom,
              ],
            ),
          ],
        ),
      ),
    );
  }
}