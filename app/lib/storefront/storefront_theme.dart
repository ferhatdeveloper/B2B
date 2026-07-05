import 'package:flutter/material.dart';

import '../core/enums/app_enums.dart';

/// Visual configuration for a storefront theme. The three variants are
/// inspired by popular ecommerce templates: a clean Minimal (Kalles/Minimog),
/// a colorful Modern marketplace (Flatsome/WoodMart), and a Bold dark theme
/// (Porto/Ella).
class StoreThemeData {
  const StoreThemeData({
    required this.label,
    required this.primary,
    required this.accent,
    required this.scaffoldBg,
    required this.headerBg,
    required this.headerFg,
    required this.darkHeader,
    required this.cardRadius,
    required this.heroGradient,
    required this.heroTitle,
    required this.heroSubtitle,
  });

  final String label;
  final Color primary;
  final Color accent;
  final Color scaffoldBg;
  final Color headerBg;
  final Color headerFg;
  final bool darkHeader;
  final double cardRadius;
  final Gradient heroGradient;
  final String heroTitle;
  final String heroSubtitle;
}

StoreThemeData storeThemeData(StoreTheme t) {
  switch (t) {
    case StoreTheme.zetem:
      // Clean corporate B2B look inspired by zetem.co.uk: cyan accent,
      // white surfaces, light-cyan category cards, generous spacing.
      return const StoreThemeData(
        label: 'Zetem',
        primary: Color(0xFF00363F),
        accent: Color(0xFF00BCD4),
        scaffoldBg: Color(0xFFF7FAFB),
        headerBg: Colors.white,
        headerFg: Color(0xFF0F2A30),
        darkHeader: false,
        cardRadius: 14,
        heroGradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFFE0F7FA), Color(0xFFD7EFD3)]),
        heroTitle: 'Toptan tedarik, tek noktadan',
        heroSubtitle: 'Endüstriyel ve işletme ürünlerinde güvenilir B2B tedarik. Üye olun, özel fiyatları görün.',
      );
    case StoreTheme.minimal:
      return const StoreThemeData(
        label: 'Minimal',
        primary: Color(0xFF111827),
        accent: Color(0xFF111827),
        scaffoldBg: Colors.white,
        headerBg: Colors.white,
        headerFg: Color(0xFF111827),
        darkHeader: false,
        cardRadius: 6,
        heroGradient: LinearGradient(colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)]),
        heroTitle: 'Sade. Hızlı. Şık.',
        heroSubtitle: 'Özenle seçilmiş ürünler, gereksiz her şeyden arınmış bir alışveriş deneyimi.',
      );
    case StoreTheme.modern:
      return const StoreThemeData(
        label: 'Modern',
        primary: Color(0xFF4F46E5),
        accent: Color(0xFF10B981),
        scaffoldBg: Color(0xFFF8FAFC),
        headerBg: Color(0xFF4F46E5),
        headerFg: Colors.white,
        darkHeader: true,
        cardRadius: 18,
        heroGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
        heroTitle: 'Her şey, tek mağazada',
        heroSubtitle: 'Binlerce ürün, kampanyalar ve hızlı teslimat. Hemen keşfetmeye başla.',
      );
    case StoreTheme.bold:
      return const StoreThemeData(
        label: 'Bold',
        primary: Color(0xFF0B0B0F),
        accent: Color(0xFFF97316),
        scaffoldBg: Color(0xFFF7F7F8),
        headerBg: Color(0xFF0B0B0F),
        headerFg: Colors.white,
        darkHeader: true,
        cardRadius: 12,
        heroGradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF0B0B0F), Color(0xFF272316)]),
        heroTitle: 'CESUR SEÇİMLER',
        heroSubtitle: 'Öne çıkan ürünler ve büyük fırsatlar — tarzını konuştur.',
      );
  }
}
