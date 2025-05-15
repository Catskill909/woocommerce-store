import '../utils/html_formatter.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final String shortDescription;
  final String permalink;
  final String sku;
  final String status; // publish, draft, etc.
  final bool featured;
  final String catalogVisibility; // visible, catalog, search, hidden
  final List<String> categories;
  final List<String> tags;
  final List<String> images;
  final String imageUrl; // Main image for convenience
  final double price;
  final double regularPrice;
  final double? salePrice;
  final String? dateOnSaleFrom;
  final String? dateOnSaleTo;
  final bool onSale;
  final bool purchasable;
  final int totalSales;
  final bool virtual;
  final bool downloadable;
  final List<Map<String, dynamic>>? downloads;
  final int downloadLimit;
  final int downloadExpiry;
  final String taxStatus; // taxable, shipping, none
  final String taxClass;
  final bool manageStock;
  final int? stockQuantity;
  final String stockStatus; // instock, outofstock, onbackorder
  final List<Map<String, dynamic>>? attributes;
  final int? brandId; // Added for brand support
  final String? brandName; // Added for brand support
  final double averageRating;
  final int ratingCount;
  final List<int>? relatedIds;
  final List<int>? variations;
  final String? weight;
  final Map<String, String>? dimensions;
  final String? purchaseNote;

  Product({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription = '',
    this.permalink = '',
    this.sku = '',
    this.status = 'publish',
    this.featured = false,
    this.catalogVisibility = 'visible',
    this.categories = const [],
    this.tags = const [],
    this.images = const [],
    required this.imageUrl,
    required this.price,
    this.regularPrice = 0.0,
    this.salePrice,
    this.dateOnSaleFrom,
    this.dateOnSaleTo,
    this.onSale = false,
    this.purchasable = true,
    this.totalSales = 0,
    this.virtual = false,
    this.downloadable = false,
    this.downloads,
    this.downloadLimit = -1,
    this.downloadExpiry = -1,
    this.taxStatus = 'taxable',
    this.taxClass = '',
    this.manageStock = false,
    this.stockQuantity,
    this.stockStatus = 'instock',
    this.attributes,
    this.brandId,
    this.brandName,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.relatedIds,
    this.variations,
    this.weight,
    this.dimensions,
    this.purchaseNote,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Extract categories
    List<String> categoryNames = [];
    if (json['categories'] != null) {
      categoryNames = List<String>.from(
          json['categories'].map((category) => category['name']));
    }

    // Extract tags
    List<String> tagNames = [];
    if (json['tags'] != null) {
      tagNames = List<String>.from(json['tags'].map((tag) => tag['name']));
    }

    // Extract images
    List<String> imageUrls = [];
    if (json['images'] != null && json['images'].isNotEmpty) {
      imageUrls = List<String>.from(json['images'].map((img) => img['src']));
    }

    // Extract brand information if available
    int? brandId;
    String? brandName;
    if (json['brands'] != null && json['brands'].isNotEmpty) {
      brandId = json['brands'][0]['id'];
      brandName = json['brands'][0]['name'];
    }

    return Product(
      id: json['id'],
      name: HtmlFormatter.stripHtml(json['name'] ?? ''),
      description: HtmlFormatter.stripHtml(json['description'] ?? ''),
      shortDescription: HtmlFormatter.stripHtml(json['short_description'] ?? ''),
      permalink: json['permalink'] ?? '',
      sku: json['sku'] ?? '',
      status: json['status'] ?? 'publish',
      featured: json['featured'] ?? false,
      catalogVisibility: json['catalog_visibility'] ?? 'visible',
      categories: categoryNames,
      tags: tagNames,
      images: imageUrls,
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['src']
          : '',
      price: double.tryParse(json['price'] ?? '0') ?? 0.0,
      regularPrice: double.tryParse(json['regular_price'] ?? '0') ?? 0.0,
      salePrice: json['sale_price'] != null && json['sale_price'] != ''
          ? double.tryParse(json['sale_price'])
          : null,
      dateOnSaleFrom: json['date_on_sale_from'],
      dateOnSaleTo: json['date_on_sale_to'],
      onSale: json['on_sale'] ?? false,
      purchasable: json['purchasable'] ?? true,
      totalSales: json['total_sales'] ?? 0,
      virtual: json['virtual'] ?? false,
      downloadable: json['downloadable'] ?? false,
      downloads: json['downloads'] != null
          ? List<Map<String, dynamic>>.from(json['downloads'])
          : null,
      downloadLimit: json['download_limit'] ?? -1,
      downloadExpiry: json['download_expiry'] ?? -1,
      taxStatus: json['tax_status'] ?? 'taxable',
      taxClass: json['tax_class'] ?? '',
      manageStock: json['manage_stock'] ?? false,
      stockQuantity: json['stock_quantity'],
      stockStatus: json['stock_status'] ?? 'instock',
      attributes: json['attributes'] != null
          ? List<Map<String, dynamic>>.from(json['attributes'])
          : null,
      brandId: brandId,
      brandName: brandName,
      averageRating: double.tryParse(json['average_rating'] ?? '0') ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      relatedIds: json['related_ids'] != null
          ? List<int>.from(json['related_ids'])
          : null,
      variations: json['variations'] != null
          ? List<int>.from(json['variations'])
          : null,
      weight: json['weight'],
      dimensions: json['dimensions'] != null
          ? Map<String, String>.from({
              'length': json['dimensions']['length'] ?? '',
              'width': json['dimensions']['width'] ?? '',
              'height': json['dimensions']['height'] ?? '',
            })
          : null,
      purchaseNote: json['purchase_note'],
    );
  }
}
