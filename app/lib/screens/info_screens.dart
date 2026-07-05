import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/async_list.dart';

class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.read(b2bServiceProvider);
    return AsyncList<Campaign>(
      loader: () => svc.campaigns(),
      emptyMessage: 'Aktif kampanya bulunamadı.',
      emptyIcon: Icons.local_offer_outlined,
      itemBuilder: (context, c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text('%${c.discountPct.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (c.description != null) ...[
                      const SizedBox(height: 3),
                      Text(c.description!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.read(b2bServiceProvider);
    return AsyncList<Announcement>(
      loader: () => svc.announcements(),
      emptyMessage: 'Duyuru bulunamadı.',
      emptyIcon: Icons.campaign_outlined,
      itemBuilder: (context, a) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign, color: AppColors.brand, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text(shortDate(a.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(a.body, style: const TextStyle(color: Color(0xFF334155), height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
