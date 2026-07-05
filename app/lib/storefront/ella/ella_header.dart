import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../core/enums/app_enums.dart';
import '../../core/providers/app_providers.dart';
import 'ella_theme_config.dart';

typedef EllaSearchCallback = void Function(String query);
typedef EllaCartCallback = VoidCallback;

/// Ella `header-default` … `header-10` desenlerine göre vitrin header'ı.
class EllaHeader extends ConsumerWidget {
  const EllaHeader({
    super.key,
    required this.t,
    required this.cartCount,
    required this.searchCtrl,
    required this.onSearch,
    required this.onCart,
    required this.categories,
    required this.selectedCategory,
    required this.onCategory,
    required this.isPreview,
  });

  final StoreThemeData t;
  final int cartCount;
  final TextEditingController searchCtrl;
  final EllaSearchCallback onSearch;
  final EllaCartCallback onCart;
  final List<Category> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategory;
  final bool isPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(appSettingsProvider.notifier);
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showAnnouncementInHeader) _announcement(),
        _topBar(context, ref, settings, width),
        if (_hasNavBelow) _navBar(context),
      ],
    );
  }

  bool get _showAnnouncementInHeader =>
      t.headerStyle == EllaHeaderStyle.classic ||
      t.headerStyle == EllaHeaderStyle.mintDark ||
      t.headerStyle == EllaHeaderStyle.tripleSearch;

  bool get _hasNavBelow =>
      t.headerStyle != EllaHeaderStyle.singleNav &&
      t.headerStyle != EllaHeaderStyle.sportsWhite &&
      categories.isNotEmpty;

  Widget _announcement() => Container(
        width: double.infinity,
        color: t.announcementBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          t.announcementText,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.announcementFg, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
      );

  Widget _topBar(BuildContext context, WidgetRef ref, AppSettingsNotifier settings, double width) {
    switch (t.headerStyle) {
      case EllaHeaderStyle.multiBrand:
        return Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < t.brandTabs.length; i++) ...[
                    if (i > 0) Container(width: 1, height: 14, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 8)),
                    Text(
                      t.brandTabs[i].toUpperCase(),
                      style: TextStyle(
                        color: i == 0 ? t.accent : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _dealerBtn(settings, Colors.white70),
                ],
              ),
            ),
            _logoSearchRow(context, ref, settings, width, barColor: Colors.white, fg: Colors.black),
          ],
        );
      case EllaHeaderStyle.editorial:
        return Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  for (var i = 0; i < t.segmentTabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Text(t.segmentTabs[i].toUpperCase(), style: TextStyle(color: i == 0 ? Colors.white : Colors.white54, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                  const Spacer(),
                  _dealerBtn(settings, Colors.white70),
                ],
              ),
            ),
            _logoSearchRow(context, ref, settings, width),
          ],
        );
      case EllaHeaderStyle.mintDark:
        return _logoSearchRow(context, ref, settings, width, barColor: t.headerBg, fg: t.headerFg);
      case EllaHeaderStyle.tripleSearch:
        return Column(
          children: [
            Container(
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text('TR / TRY', style: TextStyle(color: t.mutedText, fontSize: 11)),
                  const Spacer(),
                  _dealerBtn(settings, t.primary),
                ],
              ),
            ),
            _logoSearchRow(context, ref, settings, width, centerSearch: true),
          ],
        );
      case EllaHeaderStyle.singleNav:
        return Container(
          color: t.headerBg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _logo(fg: t.headerFg),
              if (width >= 900) ...[
                const Spacer(),
                for (final c in categories.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(c.name, style: TextStyle(color: t.headerFg, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                const Spacer(),
              ] else
                const Spacer(),
              _icons(ref, settings, t.headerFg, width),
            ],
          ),
        );
      case EllaHeaderStyle.darkSearch:
      case EllaHeaderStyle.blueSearch:
      case EllaHeaderStyle.navyMega:
        return Container(
          color: t.headerBg,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              _logo(fg: t.headerFg),
              if (width >= 640) ...[
                const SizedBox(width: 20),
                Expanded(child: _searchField(onSubmitted: onSearch, fill: t.searchFill, fg: t.headerFg)),
              ],
              _icons(ref, settings, t.headerFg, width),
            ],
          ),
        );
      case EllaHeaderStyle.sportsWhite:
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _logo(fg: Colors.black),
              const Spacer(),
              if (width >= 720) ...[
                SizedBox(width: 280, child: _searchField(onSubmitted: onSearch)),
                const SizedBox(width: 12),
              ],
              _icons(ref, settings, Colors.black, width),
            ],
          ),
        );
      case EllaHeaderStyle.classic:
        return Column(
          children: [
            Container(
              color: const Color(0xFFEFF3F5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.support_agent, size: 14, color: t.mutedText),
                  const SizedBox(width: 6),
                  Text('Destek: +90 850 000 00 00', style: TextStyle(color: t.mutedText, fontSize: 11)),
                  const Spacer(),
                  _dealerBtn(settings, t.primary),
                ],
              ),
            ),
            _logoSearchRow(context, ref, settings, width),
          ],
        );
    }
  }

  Widget _logoSearchRow(
    BuildContext context,
    WidgetRef ref,
    AppSettingsNotifier settings,
    double width, {
    Color? barColor,
    Color? fg,
    bool centerSearch = false,
  }) {
    final color = barColor ?? t.headerBg;
    final text = fg ?? t.headerFg;
    return Material(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: centerSearch
            ? Column(
                children: [
                  _logo(fg: text),
                  const SizedBox(height: 10),
                  SizedBox(width: width > 520 ? 480 : width - 40, child: _searchField(onSubmitted: onSearch, fill: t.searchFill)),
                  const SizedBox(height: 8),
                  _icons(ref, settings, text, width),
                ],
              )
            : Row(
                children: [
                  _logo(fg: text),
                  if (width >= 720) ...[
                    const SizedBox(width: 24),
                    Expanded(child: SizedBox(height: 42, child: _searchField(onSubmitted: onSearch, fill: t.searchFill, fg: text))),
                  ] else
                    const Spacer(),
                  Flexible(child: _icons(ref, settings, text, width)),
                ],
              ),
      ),
    );
  }

  Widget _logo({required Color fg}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(t.cardRadius > 0 ? t.cardRadius : 4)),
            child: const Icon(Icons.bolt, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text('EXFIN', style: TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      );

  Widget _searchField({required EllaSearchCallback onSubmitted, Color? fill, Color? fg}) {
    return TextField(
      controller: searchCtrl,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Ürün, SKU veya marka ara…',
        hintStyle: TextStyle(fontSize: 13, color: t.mutedText.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.search, size: 18, color: fg ?? t.primary),
        filled: true,
        fillColor: fill ?? const Color(0xFFF5F5F5),
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.cardRadius > 0 ? t.cardRadius + 4 : 0),
          borderSide: BorderSide(color: t.accent.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.cardRadius > 0 ? t.cardRadius + 4 : 0),
          borderSide: BorderSide(color: t.mutedText.withValues(alpha: 0.15)),
        ),
      ),
    );
  }

  Widget _icons(WidgetRef ref, AppSettingsNotifier settings, Color fg, double width) {
    final compact = width < 480;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          PopupMenuButton<StoreTheme>(
            tooltip: 'Tema',
            icon: Icon(Icons.palette_outlined, color: fg, size: 20),
            onSelected: settings.setStoreTheme,
            itemBuilder: (_) => [for (final th in StoreTheme.values) PopupMenuItem(value: th, child: Text(storeThemeData(th).label))],
          ),
        if (!compact) const SizedBox(width: 4),
        FilledButton.icon(
          onPressed: onCart,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: t.buttonStyle == EllaButtonStyle.goldAccent ? t.primary : Colors.white,
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.cardRadius > 0 ? t.cardRadius : 0)),
          ),
          icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_cart_outlined, size: 18)),
          label: compact ? const SizedBox.shrink() : const Text('Sepet', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _dealerBtn(AppSettingsNotifier settings, Color fg) => TextButton.icon(
        onPressed: () => isPreview ? settings.exitStorefrontPreview() : settings.requestDealerLogin(),
        style: TextButton.styleFrom(foregroundColor: fg, padding: const EdgeInsets.symmetric(horizontal: 6)),
        icon: Icon(isPreview ? Icons.dashboard : Icons.store_mall_directory, size: 15),
        label: Text(isPreview ? 'Panele Dön' : 'Bayi Girişi', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      );

  Widget _navBar(BuildContext context) => Container(
        color: t.navBarBg,
        child: SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _navItem('Tümü', selectedCategory == null, () => onCategory(null)),
              for (final c in categories) _navItem(c.name, selectedCategory == c.slug, () => onCategory(c.slug)),
            ],
          ),
        ),
      );

  Widget _navItem(String label, bool sel, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: sel ? t.accent : Colors.transparent, width: 2)),
          ),
          child: Text(label, style: TextStyle(color: sel ? t.accent : t.navBarFg.withValues(alpha: 0.75), fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 12.5)),
        ),
      );
}
