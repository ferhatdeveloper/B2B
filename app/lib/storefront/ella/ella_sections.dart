import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/app_enums.dart';
import '../../core/providers/app_providers.dart';
import '../../models/models.dart';
import '../../utils/format.dart';
import 'ella_button.dart';
import 'ella_demo_content.dart';
import 'ella_layout.dart';
import 'ella_theme_config.dart';

class EllaSections {
  EllaSections._();

  static Widget announcement(StoreThemeData t) => Container(
        width: double.infinity,
        color: t.announcementBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Text(
          t.announcementText,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.announcementFg, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        ),
      );

  static Widget policies(StoreThemeData t) {
    if (t.policyColors.length >= 2) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            color: t.policyColors[0],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('FREE SHIPPING OVER \$99*', textAlign: TextAlign.center, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Plus, two-day delivery on thousands of items.', textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 11)),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: t.mutedText.withValues(alpha: 0.2)),
                Expanded(
                  child: Column(
                    children: [
                      Text('AMAZING VALUE EVERY DAY', textAlign: TextAlign.center, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Items you love at prices that fit your budget.', textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: t.policyColors[1],
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _PolicyIconTile(icon: Icons.card_giftcard_outlined, label: 'FREE GIFT WRAPPING'),
                _PolicyIconTile(icon: Icons.inventory_2_outlined, label: 'EASY RETURNS'),
                _PolicyIconTile(icon: Icons.school_outlined, label: 'STUDENT DISCOUNT'),
                _PolicyIconTile(icon: Icons.verified_user_outlined, label: 'SECURE SHOPPING'),
              ],
            ),
          ),
        ],
      );
    }
    if (t.policyColors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(child: _policyTile(t, 'Ücretsiz Kargo', t.accent.withValues(alpha: 0.12))),
            const SizedBox(width: 10),
            Expanded(child: _policyTile(t, 'Kolay İade', t.secondaryAccent.withValues(alpha: 0.12))),
          ],
        ),
      );
    }
    return Column(
      children: [
        Container(width: double.infinity, color: t.policyColors[0], padding: const EdgeInsets.all(14), child: const Text('Ücretsiz kargo — ₺500 üzeri siparişlerde', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        if (t.policyColors.length > 1)
          Container(width: double.infinity, color: t.policyColors[1], padding: const EdgeInsets.all(14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [Icon(Icons.local_shipping_outlined, size: 18), Icon(Icons.refresh, size: 18), Icon(Icons.verified_user_outlined, size: 18)])),
      ],
    );
  }

  static Widget _policyTile(StoreThemeData t, String label, Color bg) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(t.cardRadius)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 12)),
      );

  static Widget hero(StoreThemeData t, StoreTheme theme, {int variant = 0}) {
    return Builder(builder: (context) {
      final demo = ellaDemoContent(theme);
      final width = MediaQuery.sizeOf(context).width;
      final wide = width >= 768;
      final image = variant == 1 && demo.secondaryHeroImage != null
          ? demo.secondaryHeroImage!
          : (wide ? demo.heroImage : (demo.mobileHeroImage ?? demo.heroImage));
      final title = variant == 1 && demo.secondaryHeroTitle != null ? demo.secondaryHeroTitle! : demo.heroTitle;
      final subtitle = variant == 0 ? demo.heroSubtitle : demo.heroSubtitle;
      final padTop = wide ? demo.heroPaddingTopPercent : demo.heroMobilePaddingTopPercent;

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: EllaRatioBox(
          paddingTopPercent: padTop,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ellaImage(image, fit: BoxFit.cover),
              if (wide)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                    ),
                  ),
                ),
              Align(
                alignment: wide ? Alignment.centerLeft : Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 2, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          textAlign: wide ? TextAlign.start : TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: wide ? TextAlign.start : TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.45),
                        ),
                        const SizedBox(height: 14),
                        EllaButton(t: t, label: demo.heroCta, compact: true),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget dualHero(StoreThemeData t, StoreTheme theme) => Column(children: [hero(t, theme), hero(t, theme, variant: 1)]);

  static Widget textBlock(StoreThemeData t) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('KOLEKSİYON HİKAYESİ', style: TextStyle(color: t.primary, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text('Ella editorial metin bloğu — markanızın hikayesini vitrinde anlatın.', textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 13, height: 1.5)),
          ],
        ),
      );

  static Widget subBanner3(StoreThemeData t, StoreTheme theme, List<Category> categories, ValueChanged<String?> onSelect) {
    final demo = ellaDemoContent(theme);
    final banners = demo.subBanners;
    if (banners.isEmpty) return const SizedBox.shrink();

    Widget tile(int i) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 5, right: i == banners.length - 1 ? 0 : 5),
          child: InkWell(
            onTap: () {
              if (categories.length > i) onSelect(categories[i].slug);
            },
            child: EllaRatioBox(
              paddingTopPercent: 54.05405405405406,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  _ellaImage(banners[i].image, fit: BoxFit.cover),
                  Text(
                    banners[i].title,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(banners[i].titleColor), fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: EllaContainer(
        child: LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 576) {
              return Column(
                children: [
                  for (var i = 0; i < banners.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          if (categories.length > i) onSelect(categories[i].slug);
                        },
                        child: EllaRatioBox(
                          paddingTopPercent: 54.05405405405406,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              _ellaImage(banners[i].image, fit: BoxFit.cover),
                              Text(banners[i].title, style: TextStyle(color: Color(banners[i].titleColor), fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            return Row(children: [for (var i = 0; i < banners.length; i++) tile(i)]);
          },
        ),
      ),
    );
  }

  static Widget bannerGrid(StoreThemeData t, StoreTheme theme, int count, List<Category> categories) {
    if (theme == StoreTheme.ella6 && count == 4) {
      return _fourBannerHome6(t, categories);
    }
    final demo = ellaDemoContent(theme);
    return EllaContainer(
      child: LayoutBuilder(
        builder: (context, c) {
          final tileW = c.maxWidth < 576 ? c.maxWidth : (c.maxWidth - (count >= 4 ? 30 : 10)) / (count >= 4 ? 4 : 2);
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < count; i++)
                SizedBox(
                  width: c.maxWidth < 576 ? c.maxWidth : tileW.clamp(140, 280),
                  child: EllaRatioBox(
                    paddingTopPercent: 60,
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Positioned.fill(child: _ellaImage(demo.subBanners[i % demo.subBanners.length].image, fit: BoxFit.cover)),
                        Container(
                          width: double.infinity,
                          color: Colors.black.withValues(alpha: 0.35),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            categories.length > i ? categories[i].name.toUpperCase() : 'BANNER ${i + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static Widget _fourBannerHome6(StoreThemeData t, List<Category> categories) {
    return EllaContainer(
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 768) {
            return Column(
              children: [
                for (final img in ['assets/ella/home6/banner-1.jpg', 'assets/ella/home6/banner-2.jpg', 'assets/ella/home6/banner-3.jpg', 'assets/ella/home6/banner-4.jpg'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EllaRatioBox(paddingTopPercent: 83.2, child: _ellaImage(img, fit: BoxFit.cover)),
                  ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: EllaRatioBox(paddingTopPercent: 83.2, child: _ellaImage('assets/ella/home6/banner-1.jpg', fit: BoxFit.cover)),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    EllaRatioBox(paddingTopPercent: 39.655172413, child: _ellaImage('assets/ella/home6/banner-2.jpg', fit: BoxFit.cover)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: EllaRatioBox(paddingTopPercent: 82.380952381, child: _ellaImage('assets/ella/home6/banner-3.jpg', fit: BoxFit.cover))),
                        const SizedBox(width: 10),
                        Expanded(child: EllaRatioBox(paddingTopPercent: 82.380952381, child: _ellaImage('assets/ella/home6/banner-4.jpg', fit: BoxFit.cover))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget categoryCards(StoreThemeData t, StoreTheme theme, List<Category> categories, ValueChanged<String?> onSelect) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final demo = ellaDemoContent(theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(t, 'Kategoriler', onSeeAll: () => onSelect(null)),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final c = categories[i];
              final banner = demo.subBanners[i % demo.subBanners.length];
              return InkWell(
                onTap: () => onSelect(c.slug),
                borderRadius: BorderRadius.circular(t.cardRadius),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(t.cardRadius),
                  child: SizedBox(
                    width: 150,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _ellaImage(banner.image, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Text(c.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget categoryCircles(StoreThemeData t, StoreTheme theme, List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final demo = ellaDemoContent(theme);
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final c = categories[i];
          final img = demo.subBanners[i % demo.subBanners.length].image;
          return Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: t.secondaryAccent.withValues(alpha: 0.15),
                backgroundImage: AssetImage(img),
                onBackgroundImageError: (_, _) {},
                child: const SizedBox.shrink(),
              ),
              const SizedBox(height: 6),
              SizedBox(width: 72, child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: t.primary, fontWeight: FontWeight.w600))),
            ],
          );
        },
      ),
    );
  }

  static Widget productGrid(
    StoreThemeData t,
    StoreTheme theme,
    List<Product> products,
    int cols,
    void Function(Product) onProduct,
  ) {
    if (products.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final columns = cols > 0 ? cols : EllaLayout.productCols(c.maxWidth);
        final aspect = EllaLayout.productAspectRatio(c.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EllaContainer(
              child: EllaSectionHeader(t: t, title: 'New Arrivals', viewAll: 'View All'),
            ),
            EllaContainer(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: aspect,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => _productCard(t, theme, i, products[i], onProduct),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget productCarousel(
    StoreThemeData t,
    StoreTheme theme,
    List<Product> products,
    void Function(Product) onProduct, {
    int variant = 1,
  }) {
    final items = products.take(8).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final titles = ['New Arrivals', 'Trending Now', 'Best Sellers', 'Featured Products'];
    final title = titles[(variant - 1) % titles.length];
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EllaContainer(child: EllaSectionHeader(t: t, title: title, viewAll: 'View All')),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: EllaLayout.hPad),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(width: 180, child: _productCard(t, theme, i, items[i], onProduct)),
          ),
        ),
      ],
    );
  }

  static Widget productTab(StoreThemeData t, StoreTheme theme, List<Product> products, void Function(Product) onProduct) {
    final tabs = ['Yeni', 'Çok Satan', 'İndirim'];
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          _sectionTitle(t, 'Koleksiyonlar'),
          TabBar(
            labelColor: t.accent,
            unselectedLabelColor: t.mutedText,
            indicatorColor: t.accent,
            tabs: [for (final tab in tabs) Tab(text: tab)],
          ),
          SizedBox(
            height: 260,
            child: TabBarView(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    itemCount: products.take(6).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, j) => SizedBox(width: 170, child: _productCard(t, theme, j, products[j], onProduct)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget productSideBanner(
    StoreThemeData t,
    StoreTheme theme,
    List<Product> products,
    void Function(Product) onProduct, {
    int variant = 1,
  }) {
    final demo = ellaDemoContent(theme);
    final items = products.take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final bannerAsset = demo.sideBannerImages.length >= variant
        ? demo.sideBannerImages[variant - 1]
        : (variant > 1 && demo.subBanners.isNotEmpty ? demo.subBanners.first.image : demo.heroImage);
    final sectionTitle = variant == 1 ? 'New Products' : 'Featured Products';
    return EllaContainer(
      child: LayoutBuilder(
        builder: (context, c) {
          final banner = AspectRatio(aspectRatio: 0.72, child: _ellaImage(bannerAsset, fit: BoxFit.cover));
          final list = Column(
            children: [
              EllaSectionHeader(t: t, title: sectionTitle, viewAll: 'View All'),
              for (var i = 0; i < items.length; i++)
                Padding(padding: const EdgeInsets.only(bottom: 8), child: _productCard(t, theme, i, items[i], onProduct, horizontal: true)),
            ],
          );
          if (c.maxWidth < 720) {
            return Column(children: [banner, const SizedBox(height: 12), list]);
          }
          if (variant > 1) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: list),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: banner),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: banner),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: list),
            ],
          );
        },
      ),
    );
  }

  static Widget spotlight(StoreThemeData t, StoreTheme theme) {
    final demo = ellaDemoContent(theme);
    final items = demo.spotlights.isNotEmpty
        ? demo.spotlights
        : [
            for (final s in ellaDemoSpotlights) EllaSpotlight(image: demo.subBanners.first.image, title: s.$1, description: s.$2),
          ];

    return EllaContainer(
      child: Column(
        children: [
          EllaSectionHeader(t: t, title: 'Featured On Ella'),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 768) {
                return Column(
                  children: [
                    for (final item in items.take(3)) _spotlightCard(t, item),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length && i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _spotlightCard(t, items[i])),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _spotlightCard(StoreThemeData t, EllaSpotlight item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          EllaRatioBox(
            paddingTopPercent: 118.91891891891893,
            child: _ellaImage(item.image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(item.title, textAlign: TextAlign.center, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          Text(item.description, textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.45)),
          const SizedBox(height: 12),
          EllaButton(t: t, label: 'SHOP NOW', compact: true),
        ],
      ),
    );
  }

  static Widget brands(StoreThemeData t, StoreTheme theme) {
    final demo = ellaDemoContent(theme);
    final images = demo.brandImages;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.mutedText.withValues(alpha: 0.15)))),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: EllaContainer(
        child: images.isNotEmpty
            ? (images.length == 1
                ? Center(child: Image.asset(images.first, height: 48, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox(height: 48)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final img in images)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Image.asset(img, height: 36, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox(height: 36)),
                          ),
                        ),
                    ],
                  ))
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final brand in ellaDemoBrands)
                    Expanded(
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(border: Border.all(color: t.mutedText.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(t.cardRadius)),
                        child: Text(brand, style: TextStyle(color: t.mutedText, fontWeight: FontWeight.w700, fontSize: 8, letterSpacing: 0.6)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  static Widget icons(StoreThemeData t) {
    const labels = ['Ücretsiz Kargo', 'Güvenli Ödeme', '7/24 Destek'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(t.cardRadius)),
                child: Column(children: [
                  Icon(Icons.check_circle_outline, color: t.accent, size: 22),
                  const SizedBox(height: 6),
                  Text(labels[i], textAlign: TextAlign.center, style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget flashSale(StoreThemeData t, StoreTheme theme, List<Product> products, void Function(Product) onProduct) {
    final items = products.take(4).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      padding: const EdgeInsets.all(16),
      color: t.secondaryAccent.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('FLASH SALE', style: TextStyle(color: t.secondaryAccent, fontWeight: FontWeight.w900, fontSize: 18)),
            const Spacer(),
            Text('02:14:33', style: TextStyle(color: t.accent, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => SizedBox(width: 150, child: _productCard(t, theme, i, items[i], onProduct)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget bannerTab(StoreThemeData t, StoreTheme theme, List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final demo = ellaDemoContent(theme);
    final tabs = categories.take(4).toList();
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          _sectionTitle(t, 'Kategoriye Göre'),
          TabBar(isScrollable: true, labelColor: t.secondaryAccent, indicatorColor: t.accent, tabs: [for (final c in tabs) Tab(text: c.name)]),
          SizedBox(
            height: 160,
            child: TabBarView(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(t.cardRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _ellaImage(demo.subBanners[i % demo.subBanners.length].image, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35)),
                          ),
                          Center(child: Text(tabs[i].name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget reviews(StoreThemeData t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MÜŞTERİ YORUMLARI', style: TextStyle(color: t.primary, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 10),
            for (final quote in ellaDemoReviews)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: t.mutedText.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(t.cardRadius)),
                child: Row(
                  children: [
                    Icon(Icons.format_quote, color: t.accent),
                    const SizedBox(width: 10),
                    Expanded(child: Text(quote, style: TextStyle(color: t.mutedText, fontSize: 12))),
                  ],
                ),
              ),
          ],
        ),
      );

  static Widget about(StoreThemeData t, StoreTheme theme) {
    final demo = ellaDemoContent(theme);
    return EllaContainer(
      child: LayoutBuilder(
        builder: (context, c) {
          final image = ClipRRect(borderRadius: BorderRadius.circular(t.cardRadius), child: AspectRatio(aspectRatio: 1.2, child: _ellaImage(demo.heroImage, fit: BoxFit.cover)));
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HAKKIMIZDA', style: TextStyle(color: t.primary, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 8),
              Text(demo.heroSubtitle, style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.45)),
            ],
          );
          if (c.maxWidth < 640) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [image, const SizedBox(height: 12), text]);
          }
          return Row(children: [Expanded(child: image), const SizedBox(width: 16), Expanded(child: text)]);
        },
      ),
    );
  }

  static Widget blogTeaser(StoreThemeData t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(t.cardRadius)),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(10),
                  child: Text('Blog ${i + 1}', style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ),
            ],
          ],
        ),
      );

  static Widget footer(StoreThemeData t, List<Category> categories) {
    final wide = categories.length > 3;
    Widget col(String title, List<String> lines) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: t.footerFg, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            for (final l in lines) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(l, style: TextStyle(color: t.footerFg.withValues(alpha: 0.6), fontSize: 12))),
          ],
        );
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
      color: t.footerBg,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: col('EXFIN B2B', ['Bayi ve toptan tedarik platformu.'])),
                Expanded(child: col('Bağlantılar', ['Ürünler', 'Hakkımızda', 'İletişim'])),
                Expanded(child: col('Kategoriler', categories.take(4).map((c) => c.name).toList())),
              ],
            )
          else
            col('EXFIN B2B', ['Bayi ve toptan tedarik platformu.']),
          Divider(color: t.footerFg.withValues(alpha: 0.12), height: 28),
          Text('© 2026 EXFIN B2B · ${t.label}', style: TextStyle(color: t.footerFg.withValues(alpha: 0.45), fontSize: 11)),
        ],
      ),
    );
  }

  static Widget _sectionTitle(StoreThemeData t, String title, {String? trailing, VoidCallback? onSeeAll}) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.primary)),
            const Spacer(),
            if (trailing != null) Text(trailing, style: TextStyle(color: t.mutedText, fontSize: 12)),
            if (onSeeAll != null) TextButton(onPressed: onSeeAll, style: TextButton.styleFrom(foregroundColor: t.accent), child: const Text('Tümünü gör →')),
          ],
        ),
      );

  static Widget _productCard(StoreThemeData t, StoreTheme theme, int index, Product product, void Function(Product) onTap, {bool horizontal = false}) {
    if (horizontal) {
      final img = _productImage(product, theme, index);
      return InkWell(
        onTap: () => onTap(product),
        child: Row(
          children: [
            SizedBox(width: 64, height: 64, child: img),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: t.primary)),
                Text(money(product.price, product.currencyCode), style: TextStyle(fontWeight: FontWeight.w800, color: t.accent, fontSize: 13)),
              ]),
            ),
          ],
        ),
      );
    }
    return _ProductCardBody(t: t, theme: theme, index: index, product: product, onTap: () => onTap(product));
  }

  static Widget _productImage(Product product, StoreTheme theme, int index) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _ellaAssetImage(ellaProductImage(theme, index)));
    }
    return _ellaAssetImage(ellaProductImage(theme, index));
  }

  static Widget _ellaAssetImage(String? asset) {
    if (asset == null) return const ColoredBox(color: Color(0xFFF1F5F9), child: Icon(Icons.image_outlined));
    return Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFF1F5F9), child: Icon(Icons.image_outlined)));
  }

  static Widget _ellaImage(String asset, {BoxFit fit = BoxFit.cover, Gradient? fallback}) {
    return Image.asset(
      asset,
      fit: fit,
      width: double.infinity,
      errorBuilder: (_, _, _) => fallback != null
          ? Container(decoration: BoxDecoration(gradient: fallback))
          : const ColoredBox(color: Color(0xFFE5E7EB), child: Center(child: Icon(Icons.image_not_supported_outlined))),
    );
  }
}

class _ProductCardBody extends ConsumerWidget {
  const _ProductCardBody({required this.t, required this.theme, required this.index, required this.product, required this.onTap});
  final StoreThemeData t;
  final StoreTheme theme;
  final int index;
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(t.cardRadius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(t.cardRadius),
          border: Border.all(color: t.mutedText.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 0.75,
              child: EllaSections._productImage(product, theme, index),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(product.brand!, style: TextStyle(color: t.mutedText, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.2, color: t.primary)),
                  const SizedBox(height: 6),
                  Text(money(product.price, product.currencyCode), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: t.primary)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: EllaButton(
                      t: t,
                      label: 'Sepete Ekle',
                      compact: true,
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} sepete eklendi'), duration: const Duration(seconds: 1)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyIconTile extends StatelessWidget {
  const _PolicyIconTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
      ],
    );
  }
}
