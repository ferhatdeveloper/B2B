import 'package:flutter/material.dart';

import 'ella_theme_config.dart';

/// Ella `container-1170` / `container-full` ölçüleri.
abstract final class EllaLayout {
  static const double contentMax = 1170;
  static const double hPad = 15;
  static const double sectionGap = 30;

  static int productCols(double width) {
    if (width >= 992) return 4;
    if (width >= 768) return 3;
    return 2;
  }

  static double productAspectRatio(double width) {
    return width >= 992 ? 0.50 : width >= 768 ? 0.52 : 0.54;
  }
}

/// İçerik bölümleri için ortalanmış 1170px kutu.
class EllaContainer extends StatelessWidget {
  const EllaContainer({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: EllaLayout.contentMax),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: EllaLayout.hPad),
          child: child,
        ),
      ),
    );
  }
}

/// Ella `halo-block-header` başlık satırı.
class EllaSectionHeader extends StatelessWidget {
  const EllaSectionHeader({
    super.key,
    required this.t,
    required this.title,
    this.viewAll,
    this.centered = true,
  });

  final StoreThemeData t;
  final String title;
  final String? viewAll;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: t.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          if (viewAll != null) ...[
            const SizedBox(height: 4),
            Text(
              viewAll!,
              style: TextStyle(color: t.mutedText, fontSize: 12, decoration: TextDecoration.underline),
            ),
          ],
        ],
      ),
    );
  }
}

/// CSS `padding-top: X%` → `aspectRatio = 100 / X`.
class EllaRatioBox extends StatelessWidget {
  const EllaRatioBox({
    super.key,
    required this.paddingTopPercent,
    required this.child,
    this.width,
  });

  final double paddingTopPercent;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ratio = 100 / paddingTopPercent;
    final box = AspectRatio(aspectRatio: ratio, child: child);
    if (width != null) return SizedBox(width: width, child: box);
    return box;
  }
}
