class Brand {
  final int id;
  final String name;
  final String? description;
  final String? slug;
  final String? imageUrl;
  final int count;
  final int? parent;
  final int? menuOrder;

  Brand({
    required this.id,
    required this.name,
    this.description,
    this.slug,
    this.imageUrl,
    required this.count,
    this.parent,
    this.menuOrder,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'],
      imageUrl: json['image'] != null ? json['image']['src'] : null,
      count: json['count'] ?? 0,
      parent: json['parent'],
      menuOrder: json['menu_order'],
    );
  }
}
