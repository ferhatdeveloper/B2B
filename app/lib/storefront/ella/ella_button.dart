import 'package:flutter/material.dart';

import 'ella_theme_config.dart';

/// Ella skin CSS `button-1/2/3` stillerine karşılık gelen CTA.
class EllaButton extends StatelessWidget {
  const EllaButton({
    super.key,
    required this.t,
    required this.label,
    this.onPressed,
    this.compact = false,
    this.outlined = false,
  });

  final StoreThemeData t;
  final String label;
  final VoidCallback? onPressed;
  final bool compact;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final pad = compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 22, vertical: 14);
    final radius = switch (t.buttonStyle) {
      EllaButtonStyle.pillNavy => BorderRadius.circular(30),
      _ => BorderRadius.circular(t.cardRadius > 0 ? t.cardRadius : 0),
    };

    switch (t.buttonStyle) {
      case EllaButtonStyle.mintShadow:
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: t.accent, offset: const Offset(4, 4))],
            borderRadius: radius,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: outlined ? Colors.white : t.primary,
              foregroundColor: outlined ? t.primary : Colors.white,
              padding: pad,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: t.primary)),
            ),
            onPressed: onPressed,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
        );
      case EllaButtonStyle.solidAccent:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: outlined ? Colors.white : t.accent,
            foregroundColor: outlined ? t.accent : Colors.white,
            padding: pad,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: outlined ? t.accent : t.accent),
            ),
          ),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        );
      case EllaButtonStyle.goldAccent:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: outlined ? Colors.white : t.accent,
            foregroundColor: outlined ? t.primary : t.primary,
            padding: pad,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: t.accent)),
          ),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        );
      default:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: outlined ? Colors.white : t.primary,
            foregroundColor: outlined ? t.primary : Colors.white,
            padding: pad,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: t.primary),
            ),
          ),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        );
    }
  }
}
