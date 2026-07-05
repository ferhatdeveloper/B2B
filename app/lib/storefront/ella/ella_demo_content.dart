import '../../core/enums/app_enums.dart';
import '../../models/models.dart';

/// Ella HTML Template demo içerikleri — banner görselleri, hero metinleri, ürün mock görselleri.
class EllaDemoContent {
  const EllaDemoContent({
    required this.heroImage,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroCta,
    required this.subBanners,
    required this.productImages,
    this.secondaryHeroImage,
    this.secondaryHeroTitle,
  });

  final String heroImage;
  final String heroTitle;
  final String heroSubtitle;
  final String heroCta;
  final List<EllaSubBanner> subBanners;
  final List<String> productImages;
  final String? secondaryHeroImage;
  final String? secondaryHeroTitle;
}

class EllaSubBanner {
  const EllaSubBanner({required this.image, required this.title, this.titleColor = 0xFFFFFFFF});
  final String image;
  final String title;
  final int titleColor;
}

const _products = [
  'assets/ella/products/img-1.jpg',
  'assets/ella/products/img-2.jpg',
  'assets/ella/products/img-3.jpg',
  'assets/ella/products/img-4.jpg',
  'assets/ella/products/img-5.jpg',
  'assets/ella/products/img-6.jpg',
  'assets/ella/products/img-7.jpg',
  'assets/ella/products/img-8.jpg',
  'assets/ella/products/img-9.jpg',
  'assets/ella/products/img-10.jpg',
  'assets/ella/products/img-11.jpg',
  'assets/ella/products/img-12.jpg',
  'assets/ella/products/img-13.jpg',
  'assets/ella/products/img-14.jpg',
  'assets/ella/products/img-15.jpg',
  'assets/ella/products/img-16.jpg',
];

EllaDemoContent ellaDemoContent(StoreTheme theme) {
  switch (theme) {
    case StoreTheme.ella1:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home1/banner-fullwith-t.jpg',
        heroTitle: 'COSMOPOLIS',
        heroSubtitle: 'Quisquemos sodales suscipit tortor ditaemcos condimentum de cosmo lacus meleifend menean diverra loremous.',
        heroCta: 'SHOP NOW',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home1/sub-banner-1-compressor-p.jpg', title: "EDITOR'S PICK"),
          EllaSubBanner(image: 'assets/ella/home1/sub-banner-2-compressor-p.jpg', title: "EDITOR'S PICK"),
          EllaSubBanner(image: 'assets/ella/home1/sub-banner-3-compressor-p.jpg', title: "EDITOR'S PICK"),
        ],
        productImages: _products,
      );
    case StoreTheme.ella2:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home2/banner-belle-dolls.gif',
        heroTitle: 'GENTLEMAN COLLECTION',
        heroSubtitle: 'Extra 10% off on first order — multi-brand fashion storefront.',
        heroCta: 'DISCOVER',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home2/banner-header-product-2.jpg', title: 'BELLE DOLLS'),
          EllaSubBanner(image: 'assets/ella/home2/banner-header-product-3.jpg', title: 'AMBER'),
          EllaSubBanner(image: 'assets/ella/home2/banner-header-product-4.jpg', title: 'GLASSY'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella3:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home3/background-banner-2.jpg',
        heroTitle: 'NEW SEASON',
        heroSubtitle: 'Editorial magazine layout — banner stacks and minimal typography.',
        heroCta: 'EXPLORE',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home3/background-banner-3.jpg', title: 'WOMEN'),
          EllaSubBanner(image: 'assets/ella/home3/background-banner-4.jpg', title: 'MEN'),
          EllaSubBanner(image: 'assets/ella/home3/background-banner-5.jpg', title: 'KIDS'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella4:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home4/banner-1.jpg',
        heroTitle: 'MINT COLLECTION',
        heroSubtitle: 'Pop-art shadow buttons and Playfair headings — Ella Home 4.',
        heroCta: 'SHOP MINT',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home4/banner-2.jpg', title: 'NEW IN'),
          EllaSubBanner(image: 'assets/ella/home4/banner-3.jpg', title: 'TRENDING'),
          EllaSubBanner(image: 'assets/ella/home4/banner-4.jpg', title: 'SALE'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella5:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home5/halo-block-banner-style-1.jpg',
        secondaryHeroImage: 'assets/ella/home5/banner-1.jpg',
        secondaryHeroTitle: 'SPRING EDIT',
        heroTitle: 'DUAL HERO',
        heroSubtitle: 'Two stacked fullwidth heroes with blush announcement bar.',
        heroCta: 'VIEW LOOKBOOK',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home5/banner-2.jpg', title: 'STYLE 01'),
          EllaSubBanner(image: 'assets/ella/home5/banner-3.jpg', title: 'STYLE 02'),
          EllaSubBanner(image: 'assets/ella/home5/banner-4.jpg', title: 'STYLE 03'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella6:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home6/banner-1.jpg',
        heroTitle: 'SUMMER SALE',
        heroSubtitle: 'Navy Inter typography with pill buttons and banner grid.',
        heroCta: 'SHOP SALE',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home6/banner-2.jpg', title: 'DEAL 1'),
          EllaSubBanner(image: 'assets/ella/home6/banner-3.jpg', title: 'DEAL 2'),
          EllaSubBanner(image: 'assets/ella/home6/banner-4.jpg', title: 'DEAL 3'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella7:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home7/banner-1.jpg',
        heroTitle: 'NEW ARRIVALS',
        heroSubtitle: 'Static hero with dark search header and red accent CTA.',
        heroCta: 'BUY NOW',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home7/banner-2.jpg', title: 'FEATURED'),
          EllaSubBanner(image: 'assets/ella/home7/banner-3.jpg', title: 'BESTSELLER'),
          EllaSubBanner(image: 'assets/ella/home7/banner-blog-1.jpg', title: 'BLOG'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella8:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home8/banner-1.png',
        heroTitle: 'KIDS & BABY',
        heroSubtitle: 'Blue header band with orange CTAs and tabbed category shop.',
        heroCta: 'SHOP KIDS',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home8/banner-10.jpg', title: 'BOYS'),
          EllaSubBanner(image: 'assets/ella/home8/banner-11.jpg', title: 'GIRLS'),
          EllaSubBanner(image: 'assets/ella/home8/banner-12.jpg', title: 'BABY'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella9:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home9/banner-1.jpg',
        heroTitle: 'RIDE FURTHER',
        heroSubtitle: 'Cycling gear with gold accent and customer review blocks.',
        heroCta: 'SHOP BIKES',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home9/banner-2.jpg', title: 'ROAD'),
          EllaSubBanner(image: 'assets/ella/home9/banner-10.jpg', title: 'MTB'),
          EllaSubBanner(image: 'assets/ella/home9/banner-11.png', title: 'GEAR'),
        ],
        productImages: _products,
      );
    case StoreTheme.ella10:
      return const EllaDemoContent(
        heroImage: 'assets/ella/home10/banner-1.jpg',
        heroTitle: 'MEGA SALE',
        heroSubtitle: 'Flash deals, five-banner grid and navy mega-shop header.',
        heroCta: 'FLASH DEALS',
        subBanners: [
          EllaSubBanner(image: 'assets/ella/home10/banner-10.png', title: 'TECH'),
          EllaSubBanner(image: 'assets/ella/home10/banner-11.png', title: 'HOME'),
          EllaSubBanner(image: 'assets/ella/home10/banner-12.png', title: 'SPORT'),
        ],
        productImages: _products,
      );
  }
}

/// API ürününde görsel yoksa Ella demo görseli döner.
String? ellaProductImage(StoreTheme theme, int index) {
  final imgs = ellaDemoContent(theme).productImages;
  if (imgs.isEmpty) return null;
  return imgs[index % imgs.length];
}

/// Ella HTML kart ürün metinleri (Home 1 demo katalogu).
class EllaProductDisplay {
  const EllaProductDisplay({
    required this.vendor,
    required this.name,
    required this.price,
    this.currencyCode = 'TRY',
  });

  final String vendor;
  final String name;
  final double price;
  final String currencyCode;
}

const _ellaCatalog = [
  EllaProductDisplay(vendor: 'Sodling', name: 'Naminos Dementus A Milance', price: 2499),
  EllaProductDisplay(vendor: 'Anna', name: 'Dinterdum Pretium Condimento', price: 3999),
  EllaProductDisplay(vendor: 'Burberry', name: 'Magnis Darturien Meros Laciniado', price: 2899),
  EllaProductDisplay(vendor: 'Cosmopolis', name: 'Quisquemos Sodales Suscipit', price: 1599),
  EllaProductDisplay(vendor: 'Ella', name: 'Loremous Comodous Tincidunt', price: 2199),
  EllaProductDisplay(vendor: 'Milance', name: 'Pellentesque De Fermentum', price: 1799),
  EllaProductDisplay(vendor: 'Belle', name: 'Metus Vestibulum Exposuerat', price: 3299),
  EllaProductDisplay(vendor: 'Amber', name: 'Ullamcorper Mattis Fermentum', price: 1999),
  EllaProductDisplay(vendor: 'Glassy', name: 'Parturient Montes Nascetur', price: 2699),
  EllaProductDisplay(vendor: 'Vera', name: 'Ridiculus Mus Donec Quam', price: 1499),
  EllaProductDisplay(vendor: 'Halo', name: 'Felis Consectetur Adipiscing', price: 3499),
  EllaProductDisplay(vendor: 'Mint', name: 'Elit Pellentesque Ornare', price: 2299),
  EllaProductDisplay(vendor: 'Navy', name: 'Semper Faucibus Turpis', price: 1899),
  EllaProductDisplay(vendor: 'Sport', name: 'Vulputate Ut Pharetra Sit', price: 2799),
  EllaProductDisplay(vendor: 'Kids', name: 'Amet Mattis Vulputate Enim', price: 1299),
  EllaProductDisplay(vendor: 'Editor', name: 'Nulla Porttitor Accumsan', price: 3099),
];

EllaProductDisplay ellaProductDisplay(int index) => _ellaCatalog[index % _ellaCatalog.length];

const ellaDemoBrands = ['BELLE', 'AMBER', 'GLASSY', 'SODLING', 'BURBERRY'];

const ellaDemoReviews = [
  'Harika kalite ve hızlı kargo — kesinlikle tavsiye ederim.',
  'Ürün fotoğraflarındaki gibi geldi, müşteri hizmetleri çok ilgili.',
];

const ellaDemoSpotlights = [
  ('Yeni Sezon', 'Trend parçaları keşfedin'),
  ('Editör Seçimi', 'Haftanın favori kombinleri'),
  ('Outlet', 'Sezon sonu fırsatları'),
];

/// Seed/mock ürünlerde görsel yoksa Ella demo metinleriyle zenginleştirir (id/sku korunur).
Product enrichProductWithEllaDemo(Product product, int index) {
  if (product.imageUrl != null && product.imageUrl!.isNotEmpty) return product;
  final d = ellaProductDisplay(index);
  return Product(
    id: product.id,
    sku: product.sku,
    name: d.name,
    price: d.price,
    currencyCode: d.currencyCode,
    taxRate: product.taxRate,
    stockQty: product.stockQty,
    brand: d.vendor,
    unit: product.unit,
    imageUrl: product.imageUrl,
    categoryName: product.categoryName,
    categorySlug: product.categorySlug,
    isFeatured: product.isFeatured,
    isCampaign: product.isCampaign,
    isDiscounted: product.isDiscounted,
    isPersonal: product.isPersonal,
  );
}
