import 'package:flutter/material.dart';

import '../../core/enums/app_enums.dart';
import '../../models/models.dart';
import 'ella_sections.dart';
import 'ella_theme_config.dart';

/// Ella demo ana sayfa bölüm sırasını (`index.html` … `index-10.html`) uygular.
class EllaHomeLayout {
  EllaHomeLayout._();

  static List<Widget> buildBody({
    required StoreTheme theme,
    required StoreThemeData t,
    required List<Product> products,
    required List<Category> categories,
    required int gridCols,
    required ValueChanged<String?> onCategory,
    required void Function(Product) onProduct,
    bool filtered = false,
  }) {
    if (filtered) {
      return [
        EllaSections.productGrid(t, theme, products, gridCols, onProduct),
        EllaSections.footer(t, categories),
      ];
    }

    final widgets = <Widget>[];
    var heroCount = 0;

    for (final section in t.homeSections) {
      switch (section) {
        case EllaHomeSection.announcement:
          if (!_announcementInHeader(t)) widgets.add(EllaSections.announcement(t));
        case EllaHomeSection.policies:
          widgets.add(EllaSections.policies(t));
        case EllaHomeSection.hero:
          heroCount++;
          widgets.add(EllaSections.hero(t, theme, variant: heroCount > 1 ? 1 : 0));
        case EllaHomeSection.dualHero:
          widgets.add(EllaSections.dualHero(t, theme));
        case EllaHomeSection.textBlock:
          widgets.add(EllaSections.textBlock(t));
        case EllaHomeSection.subBanner3:
          widgets.add(EllaSections.subBanner3(t, theme, categories, onCategory));
        case EllaHomeSection.fourBanner:
          widgets.add(EllaSections.bannerGrid(t, theme, 4, categories));
        case EllaHomeSection.twoBanner:
          widgets.add(EllaSections.bannerGrid(t, theme, 2, categories));
        case EllaHomeSection.fiveBanner:
          widgets.add(EllaSections.bannerGrid(t, theme, 5, categories));
        case EllaHomeSection.categoryCards:
          widgets.add(EllaSections.categoryCards(t, theme, categories, onCategory));
        case EllaHomeSection.categoryCircles:
          widgets.add(EllaSections.categoryCircles(t, theme, categories));
        case EllaHomeSection.productGrid:
          widgets.add(EllaSections.productGrid(t, theme, products, gridCols, onProduct));
        case EllaHomeSection.productCarousel:
          widgets.add(EllaSections.productCarousel(t, theme, products, onProduct));
        case EllaHomeSection.productTab:
          widgets.add(EllaSections.productTab(t, theme, products, onProduct));
        case EllaHomeSection.productSideBanner:
          widgets.add(EllaSections.productSideBanner(t, theme, products, onProduct));
        case EllaHomeSection.spotlight:
          widgets.add(EllaSections.spotlight(t, theme));
        case EllaHomeSection.brands:
          widgets.add(EllaSections.brands(t));
        case EllaHomeSection.icons:
          widgets.add(EllaSections.icons(t));
        case EllaHomeSection.flashSale:
          widgets.add(EllaSections.flashSale(t, theme, products, onProduct));
        case EllaHomeSection.bannerTab:
          widgets.add(EllaSections.bannerTab(t, theme, categories));
        case EllaHomeSection.reviews:
          widgets.add(EllaSections.reviews(t));
        case EllaHomeSection.about:
          widgets.add(EllaSections.about(t, theme));
        case EllaHomeSection.blogTeaser:
          widgets.add(EllaSections.blogTeaser(t));
      }
    }

    widgets.add(EllaSections.footer(t, categories));
    return widgets;
  }

  static bool _announcementInHeader(StoreThemeData t) =>
      t.headerStyle == EllaHeaderStyle.classic ||
      t.headerStyle == EllaHeaderStyle.mintDark ||
      t.headerStyle == EllaHeaderStyle.tripleSearch;
}
