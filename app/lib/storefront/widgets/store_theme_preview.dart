import 'package:flutter/material.dart';

import '../../core/enums/app_enums.dart';
import '../storefront_theme.dart';

/// Küçük vitrin mockup'ı — Ella demo hero görseli + tema renkleri.
class StoreThemePreview extends StatelessWidget {
  const StoreThemePreview({super.key, required this.theme, required this.data, this.height = 68});

  final StoreTheme theme;
  final StoreThemeData data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final demo = ellaDemoContent(theme);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            demo.heroImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(color: data.scaffoldBg, child: Icon(Icons.storefront, color: data.accent)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(left: 8, bottom: 8, right: 8, child: _MiniHeader(data: data)),
        ],
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  const _MiniHeader({required this.data});
  final StoreThemeData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 6, decoration: BoxDecoration(color: data.headerBg, borderRadius: BorderRadius.circular(2)), child: Row(children: [
          Container(width: 8, height: 6, color: data.accent),
          const Spacer(),
          Container(width: 16, height: 4, margin: const EdgeInsets.all(1), color: data.accent),
        ])),
        const SizedBox(height: 3),
        Text(data.label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
