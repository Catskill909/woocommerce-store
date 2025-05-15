class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int count;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image'] != null ? json['image']['src'] : null,
      count: json['count'],
    );
  }
}
