class PromotionalBanner {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final int? categoryId;

  PromotionalBanner({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.categoryId,
  });
}
