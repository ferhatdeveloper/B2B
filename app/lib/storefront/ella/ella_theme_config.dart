import 'package:flutter/material.dart';

import '../../core/enums/app_enums.dart';

/// Ella `header-N` desenleri (`index.html` … `index-10.html`).
enum EllaHeaderStyle {
  classic, // header-default — 2 katman + nav
  multiBrand, // header-2 — siyah marka sekmeleri
  editorial, // header-3 — siyah Women/Men/Kids
  mintDark, // header-4 — koyu tam genişlik
  tripleSearch, // header-5 — lang + logo/arama + nav
  singleNav, // header-6 — tek satır logo/nav/ikon
  darkSearch, // header-7 — koyu üst + arama
  blueSearch, // header-8 — mavi üst band
  sportsWhite, // header-9 — beyaz tek satır
  navyMega, // header-10 — lacivert pill arama
}

enum EllaButtonStyle { solidDark, solidAccent, mintShadow, pillNavy, goldAccent }

/// Ana sayfa bölüm sırası — Ella demo blokları.
enum EllaHomeSection {
  announcement,
  policies,
  hero,
  dualHero,
  textBlock,
  subBanner3,
  fourBanner,
  twoBanner,
  fiveBanner,
  categoryCards,
  categoryCircles,
  productGrid,
  productCarousel,
  productTab,
  productSideBanner,
  spotlight,
  brands,
  icons,
  flashSale,
  bannerTab,
  reviews,
  about,
  blogTeaser,
}

class StoreThemeData {
  const StoreThemeData({
    required this.label,
    required this.description,
    required this.previewAsset,
    required this.primary,
    required this.accent,
    required this.secondaryAccent,
    required this.mutedText,
    required this.scaffoldBg,
    required this.headerBg,
    required this.headerFg,
    required this.navBarBg,
    required this.navBarFg,
    required this.announcementBg,
    required this.announcementFg,
    required this.announcementText,
    required this.footerBg,
    required this.footerFg,
    required this.darkHeader,
    required this.cardRadius,
    required this.buttonStyle,
    required this.headerStyle,
    required this.homeSections,
    required this.heroGradient,
    required this.heroTitle,
    required this.heroSubtitle,
    this.brandTabs = const [],
    this.segmentTabs = const [],
    this.policyColors = const [],
  });

  final String label;
  final String description;
  final String previewAsset;
  final Color primary;
  final Color accent;
  final Color secondaryAccent;
  final Color mutedText;
  final Color scaffoldBg;
  final Color headerBg;
  final Color headerFg;
  final Color navBarBg;
  final Color navBarFg;
  final Color announcementBg;
  final Color announcementFg;
  final String announcementText;
  final Color footerBg;
  final Color footerFg;
  final bool darkHeader;
  final double cardRadius;
  final EllaButtonStyle buttonStyle;
  final EllaHeaderStyle headerStyle;
  final List<EllaHomeSection> homeSections;
  final Gradient heroGradient;
  final String heroTitle;
  final String heroSubtitle;
  final List<String> brandTabs;
  final List<String> segmentTabs;
  final List<Color> policyColors;

  Color get searchFill => darkHeader ? Colors.white : const Color(0xFFF5F5F5);
}

StoreThemeData storeThemeData(StoreTheme t) {
  switch (t) {
    case StoreTheme.ella1:
      return const StoreThemeData(
        label: 'Ella Home 1',
        description: 'Classic — announcement, hero, sub-banner, grid',
        previewAsset: 'assets/storefront_themes/ella1.jpg',
        primary: Color(0xFF232323),
        accent: Color(0xFF232323),
        secondaryAccent: Color(0xFF727272),
        mutedText: Color(0xFF323232),
        scaffoldBg: Color(0xFFFFFFFF),
        headerBg: Color(0xFFFFFFFF),
        headerFg: Color(0xFF232323),
        navBarBg: Color(0xFFFFFFFF),
        navBarFg: Color(0xFF232323),
        announcementBg: Color(0xFF232323),
        announcementFg: Color(0xFFFFFFFF),
        announcementText: 'SEZON İNDİRİMİ %70\'E VARAN — HEMEN ALIŞVERİŞ YAP',
        footerBg: Color(0xFF232323),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: false,
        cardRadius: 0,
        buttonStyle: EllaButtonStyle.solidDark,
        headerStyle: EllaHeaderStyle.classic,
        homeSections: [
          EllaHomeSection.hero,
          EllaHomeSection.subBanner3,
          EllaHomeSection.productGrid,
          EllaHomeSection.hero,
          EllaHomeSection.productCarousel,
          EllaHomeSection.spotlight,
          EllaHomeSection.brands,
        ],
        heroGradient: LinearGradient(colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)]),
        heroTitle: 'YENİ SEZON KOLEKSİYONU',
        heroSubtitle: 'Ella Home 1 — tam genişlik banner ve klasik ürün grid düzeni.',
      );
    case StoreTheme.ella2:
      return StoreThemeData(
        label: 'Ella Home 2',
        description: 'Multi-brand — siyah marka bar, policies, tab kategori',
        previewAsset: 'assets/storefront_themes/ella2.jpg',
        primary: const Color(0xFF000000),
        accent: const Color(0xFF4F8B7B),
        secondaryAccent: const Color(0xFF4F8B7B),
        mutedText: const Color(0xFF646464),
        scaffoldBg: Colors.white,
        headerBg: Colors.white,
        headerFg: const Color(0xFF000000),
        navBarBg: Colors.white,
        navBarFg: const Color(0xFF000000),
        announcementBg: const Color(0xFF000000),
        announcementFg: Colors.white,
        announcementText: 'EXTRA 10% OFF ON FIRST ORDER',
        footerBg: const Color(0xFF000000),
        footerFg: Colors.white,
        darkHeader: false,
        cardRadius: 0,
        buttonStyle: EllaButtonStyle.solidAccent,
        headerStyle: EllaHeaderStyle.multiBrand,
        brandTabs: const ['EXFIN', 'Gentleman', 'Bell Doll', 'Amber', 'Glassy'],
        homeSections: const [
          EllaHomeSection.policies,
          EllaHomeSection.hero,
          EllaHomeSection.textBlock,
          EllaHomeSection.categoryCards,
          EllaHomeSection.fourBanner,
          EllaHomeSection.productTab,
          EllaHomeSection.spotlight,
          EllaHomeSection.productCarousel,
        ],
        heroGradient: const LinearGradient(colors: [Color(0xFFEAF4F1), Color(0xFFD8EBE5)]),
        heroTitle: 'TARZINI KEŞFET',
        heroSubtitle: 'Ella Home 2 — çok markalı header ve editorial vitrin.',
        policyColors: const [Color(0xFFF9EDE1), Color(0xFFF2F2F2)],
      );
    case StoreTheme.ella3:
      return StoreThemeData(
        label: 'Ella Home 3',
        description: 'Editorial — magazine banner dizilimi',
        previewAsset: 'assets/storefront_themes/ella3.jpg',
        primary: const Color(0xFF000000),
        accent: const Color(0xFF000000),
        secondaryAccent: const Color(0xFF505050),
        mutedText: const Color(0xFF505050),
        scaffoldBg: Colors.white,
        headerBg: Colors.white,
        headerFg: const Color(0xFF000000),
        navBarBg: Colors.white,
        navBarFg: const Color(0xFF000000),
        announcementBg: const Color(0xFF000000),
        announcementFg: Colors.white,
        announcementText: 'FREE SHIPPING ON ORDERS OVER ₺500',
        footerBg: const Color(0xFF000000),
        footerFg: Colors.white,
        darkHeader: false,
        cardRadius: 0,
        buttonStyle: EllaButtonStyle.solidDark,
        headerStyle: EllaHeaderStyle.editorial,
        segmentTabs: const ['Women', 'Men', 'Kids'],
        homeSections: const [
          EllaHomeSection.hero,
          EllaHomeSection.textBlock,
          EllaHomeSection.hero,
          EllaHomeSection.productSideBanner,
          EllaHomeSection.productGrid,
          EllaHomeSection.subBanner3,
          EllaHomeSection.about,
        ],
        heroGradient: const LinearGradient(colors: [Color(0xFFF0F0F0), Color(0xFFE0E0E0)]),
        heroTitle: 'SADE VE GÜÇLÜ',
        heroSubtitle: 'Ella Home 3 — editorial banner + metin blokları.',
      );
    case StoreTheme.ella4:
      return const StoreThemeData(
        label: 'Ella Home 4',
        description: 'Mint Chic — koyu header, mint announcement',
        previewAsset: 'assets/storefront_themes/ella4.jpg',
        primary: Color(0xFF232323),
        accent: Color(0xFFA1DECD),
        secondaryAccent: Color(0xFFA1DECD),
        mutedText: Color(0xFF3C3C3C),
        scaffoldBg: Color(0xFFF8F8F8),
        headerBg: Color(0xFF232323),
        headerFg: Color(0xFFFFFFFF),
        navBarBg: Color(0xFF232323),
        navBarFg: Color(0xFFFFFFFF),
        announcementBg: Color(0xFFA1DECD),
        announcementFg: Color(0xFF232323),
        announcementText: 'NEW ARRIVALS — SHOP THE MINT COLLECTION',
        footerBg: Color(0xFF232323),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: true,
        cardRadius: 0,
        buttonStyle: EllaButtonStyle.mintShadow,
        headerStyle: EllaHeaderStyle.mintDark,
        homeSections: [
          EllaHomeSection.announcement,
          EllaHomeSection.hero,
          EllaHomeSection.subBanner3,
          EllaHomeSection.productCarousel,
          EllaHomeSection.hero,
          EllaHomeSection.textBlock,
          EllaHomeSection.productTab,
          EllaHomeSection.spotlight,
          EllaHomeSection.icons,
        ],
        heroGradient: LinearGradient(colors: [Color(0xFFE8F8F3), Color(0xFFA1DECD)]),
        heroTitle: 'TAZE VE CESUR',
        heroSubtitle: 'Ella Home 4 — mint offset-shadow butonlar.',
      );
    case StoreTheme.ella5:
      return const StoreThemeData(
        label: 'Ella Home 5',
        description: 'Dual Hero — 3 katman header, çift hero',
        previewAsset: 'assets/storefront_themes/ella5.jpg',
        primary: Color(0xFF232323),
        accent: Color(0xFF000000),
        secondaryAccent: Color(0xFF8B714A),
        mutedText: Color(0xFF3C3C3C),
        scaffoldBg: Color(0xFFFFFFFF),
        headerBg: Color(0xFFFFFFFF),
        headerFg: Color(0xFF232323),
        navBarBg: Color(0xFFFAFAFA),
        navBarFg: Color(0xFF232323),
        announcementBg: Color(0xFFF7E3DC),
        announcementFg: Color(0xFF232323),
        announcementText: 'SPRING SALE — UP TO 50% OFF SELECTED STYLES',
        footerBg: Color(0xFF232323),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: false,
        cardRadius: 8,
        buttonStyle: EllaButtonStyle.solidDark,
        headerStyle: EllaHeaderStyle.tripleSearch,
        homeSections: [
          EllaHomeSection.dualHero,
          EllaHomeSection.brands,
          EllaHomeSection.productCarousel,
          EllaHomeSection.subBanner3,
          EllaHomeSection.productCarousel,
          EllaHomeSection.policies,
        ],
        heroGradient: LinearGradient(colors: [Color(0xFFF7E3DC), Color(0xFFEDE0D8)]),
        heroTitle: 'HER GÜN STİLİN',
        heroSubtitle: 'Ella Home 5 — üst üste iki fullwidth hero.',
      );
    case StoreTheme.ella6:
      return const StoreThemeData(
        label: 'Ella Home 6',
        description: 'Slideshow Grid — navy tipografi, 4\'lü banner',
        previewAsset: 'assets/storefront_themes/ella6.jpg',
        primary: Color(0xFF00163A),
        accent: Color(0xFF00163A),
        secondaryAccent: Color(0xFFE73E45),
        mutedText: Color(0xFF202020),
        scaffoldBg: Color(0xFFF5F5F5),
        headerBg: Color(0xFFFFFFFF),
        headerFg: Color(0xFF00163A),
        navBarBg: Color(0xFFFFFFFF),
        navBarFg: Color(0xFF00163A),
        announcementBg: Color(0xFFF2F2F2),
        announcementFg: Color(0xFFE73E45),
        announcementText: 'FREE DELIVERY — LIMITED TIME OFFER',
        footerBg: Color(0xFF00163A),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: false,
        cardRadius: 30,
        buttonStyle: EllaButtonStyle.pillNavy,
        headerStyle: EllaHeaderStyle.singleNav,
        homeSections: [
          EllaHomeSection.announcement,
          EllaHomeSection.hero,
          EllaHomeSection.fourBanner,
          EllaHomeSection.productGrid,
          EllaHomeSection.productCarousel,
        ],
        heroGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF00163A), Color(0xFF003875)]),
        heroTitle: 'GÜVENİLİR TEDARİK',
        heroSubtitle: 'Ella Home 6 — Inter font, pill butonlar, banner grid.',
      );
    case StoreTheme.ella7:
      return const StoreThemeData(
        label: 'Ella Home 7',
        description: 'Banner First — koyu arama header, blog feed',
        previewAsset: 'assets/storefront_themes/ella7.jpg',
        primary: Color(0xFF232323),
        accent: Color(0xFFF84248),
        secondaryAccent: Color(0xFFF84248),
        mutedText: Color(0xFF232323),
        scaffoldBg: Color(0xFFFAFAFA),
        headerBg: Color(0xFF232830),
        headerFg: Color(0xFFFFFFFF),
        navBarBg: Color(0xFFFFFFFF),
        navBarFg: Color(0xFF232323),
        announcementBg: Color(0xFF232830),
        announcementFg: Color(0xFFFFFFFF),
        announcementText: 'WELCOME TO ELLA HOME 7 — SHOP NEW ARRIVALS',
        footerBg: Color(0xFF232830),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: true,
        cardRadius: 4,
        buttonStyle: EllaButtonStyle.solidDark,
        headerStyle: EllaHeaderStyle.darkSearch,
        homeSections: [
          EllaHomeSection.hero,
          EllaHomeSection.brands,
          EllaHomeSection.productSideBanner,
          EllaHomeSection.subBanner3,
          EllaHomeSection.productSideBanner,
          EllaHomeSection.productTab,
          EllaHomeSection.blogTeaser,
          EllaHomeSection.brands,
        ],
        heroGradient: LinearGradient(colors: [Color(0xFFFFF0F0), Color(0xFFFFD6D8)]),
        heroTitle: 'FIRSATLARI KAÇIRMA',
        heroSubtitle: 'Ella Home 7 — statik hero, kırmızı CTA vurgusu.',
      );
    case StoreTheme.ella8:
      return const StoreThemeData(
        label: 'Ella Home 8',
        description: 'Tabbed Shop — mavi header, sekmeli vitrin',
        previewAsset: 'assets/storefront_themes/ella8.png',
        primary: Color(0xFF051C42),
        accent: Color(0xFFE1732C),
        secondaryAccent: Color(0xFF234BBB),
        mutedText: Color(0xFF051C42),
        scaffoldBg: Color(0xFFFFFFFF),
        headerBg: Color(0xFF234BBB),
        headerFg: Color(0xFFFFFFFF),
        navBarBg: Color(0xFFFFFFFF),
        navBarFg: Color(0xFF051C42),
        announcementBg: Color(0xFF234BBB),
        announcementFg: Color(0xFFFFFFFF),
        announcementText: 'KIDS & BABY — NEW COLLECTION OUT NOW',
        footerBg: Color(0xFF051C42),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: true,
        cardRadius: 6,
        buttonStyle: EllaButtonStyle.solidAccent,
        headerStyle: EllaHeaderStyle.blueSearch,
        homeSections: [
          EllaHomeSection.hero,
          EllaHomeSection.categoryCircles,
          EllaHomeSection.bannerTab,
          EllaHomeSection.subBanner3,
          EllaHomeSection.productCarousel,
          EllaHomeSection.icons,
          EllaHomeSection.productCarousel,
          EllaHomeSection.brands,
        ],
        heroGradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF051C42), Color(0xFF234BBB)]),
        heroTitle: 'HER KATEGORİ, TEK VİTRİN',
        heroSubtitle: 'Ella Home 8 — turuncu CTA, mavi header bandı.',
      );
    case StoreTheme.ella9:
      return const StoreThemeData(
        label: 'Ella Home 9',
        description: 'Sports — altın accent, müşteri yorumları',
        previewAsset: 'assets/storefront_themes/ella9.jpg',
        primary: Color(0xFF000000),
        accent: Color(0xFFF7C662),
        secondaryAccent: Color(0xFFF7C662),
        mutedText: Color(0xFF464646),
        scaffoldBg: Color(0xFFFFFFFF),
        headerBg: Color(0xFFFFFFFF),
        headerFg: Color(0xFF000000),
        navBarBg: Color(0xFFFFFFFF),
        navBarFg: Color(0xFF000000),
        announcementBg: Color(0xFFF7C662),
        announcementFg: Color(0xFF000000),
        announcementText: 'RIDE FURTHER — CYCLING GEAR SALE UP TO 40% OFF',
        footerBg: Color(0xFF000000),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: false,
        cardRadius: 3,
        buttonStyle: EllaButtonStyle.goldAccent,
        headerStyle: EllaHeaderStyle.sportsWhite,
        homeSections: [
          EllaHomeSection.announcement,
          EllaHomeSection.hero,
          EllaHomeSection.icons,
          EllaHomeSection.hero,
          EllaHomeSection.productGrid,
          EllaHomeSection.icons,
          EllaHomeSection.reviews,
          EllaHomeSection.productCarousel,
          EllaHomeSection.brands,
        ],
        heroGradient: LinearGradient(colors: [Color(0xFFFFF8E7), Color(0xFFF7C662)]),
        heroTitle: 'SEÇKİN KOLEKSİYON',
        heroSubtitle: 'Ella Home 9 — altın tonları, spor nişi bloklar.',
      );
    case StoreTheme.ella10:
      return const StoreThemeData(
        label: 'Ella Home 10',
        description: 'Mega Shop — flash sale, 5-banner, kategori grid',
        previewAsset: 'assets/storefront_themes/ella10.jpg',
        primary: Color(0xFF202020),
        accent: Color(0xFF0A6CDC),
        secondaryAccent: Color(0xFF161880),
        mutedText: Color(0xFF505050),
        scaffoldBg: Color(0xFFF5F5F5),
        headerBg: Color(0xFF161880),
        headerFg: Color(0xFFFFFFFF),
        navBarBg: Color(0xFF161880),
        navBarFg: Color(0xFFFFFFFF),
        announcementBg: Color(0xFFF6B924),
        announcementFg: Color(0xFF202020),
        announcementText: 'MEGA SALE — FLASH DEALS EVERY HOUR',
        footerBg: Color(0xFF161880),
        footerFg: Color(0xFFFFFFFF),
        darkHeader: true,
        cardRadius: 6,
        buttonStyle: EllaButtonStyle.solidAccent,
        headerStyle: EllaHeaderStyle.navyMega,
        homeSections: [
          EllaHomeSection.announcement,
          EllaHomeSection.hero,
          EllaHomeSection.icons,
          EllaHomeSection.flashSale,
          EllaHomeSection.fiveBanner,
          EllaHomeSection.categoryCards,
          EllaHomeSection.productSideBanner,
          EllaHomeSection.productCarousel,
          EllaHomeSection.brands,
        ],
        heroGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF161880), Color(0xFF0A6CDC)]),
        heroTitle: 'TEKNOLOJİ & YAŞAM',
        heroSubtitle: 'Ella Home 10 — en zengin blok dizilimi.',
      );
  }
}
