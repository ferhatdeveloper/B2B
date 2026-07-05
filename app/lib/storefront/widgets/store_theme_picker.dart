import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/app_enums.dart';
import '../../core/providers/app_providers.dart';
import '../../theme.dart';
import '../storefront_theme.dart';
import 'store_theme_preview.dart';

/// Resimli Ella tema seçici — yalnızca e-ticaret vitrini için (bayi paneli değil).
class StoreThemePicker extends ConsumerWidget {
  const StoreThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider.select((s) => s.storeTheme));
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width >= 1100 ? 5 : width >= 820 ? 4 : width >= 560 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: StoreTheme.values.length,
      itemBuilder: (context, index) {
        final theme = StoreTheme.values[index];
        final data = storeThemeData(theme);
        final isSelected = selected == theme;
        return _ThemeCard(
          theme: theme,
          data: data,
          isSelected: isSelected,
          onTap: () => ref.read(appSettingsProvider.notifier).setStoreTheme(theme),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final StoreTheme theme;
  final StoreThemeData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.brand : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            color: Colors.white,
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.brand.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  StoreThemePreview(theme: theme, data: data, height: 68),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 11),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: isSelected ? AppColors.brand : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      data.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10, height: 1.2),
                    ),
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
