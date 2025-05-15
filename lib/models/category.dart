import '../utils/html_formatter.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final String? slug;
  final String? imageUrl;
  final int count;
  final int? parent;
  final String? display; // display type: default, products, subcategories, both
  final int? menuOrder;
  final List<Category>? children; // For hierarchical categories

  Category({
    required this.id,
    required this.name,
    this.description,
    this.slug,
    this.imageUrl,
    required this.count,
    this.parent,
    this.display,
    this.menuOrder,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: HtmlFormatter.stripHtml(json['name'] ?? ''),
      description: json['description'] != null ? HtmlFormatter.stripHtml(json['description']) : null,
      slug: json['slug'],
      imageUrl: json['image'] != null ? json['image']['src'] : null,
      count: json['count'] ?? 0,
      parent: json['parent'],
      display: json['display'],
      menuOrder: json['menu_order'],
      // Children will be populated separately when needed
      children: null,
    );
  }

  // Helper method to organize categories into a hierarchical structure
  static List<Category> buildCategoryTree(List<Category> categories) {
    // Create a map of all categories by ID for quick lookup
    final Map<int, Category> categoryMap = {};
    for (var category in categories) {
      categoryMap[category.id] = category;
    }

    // Create a list to hold top-level categories
    final List<Category> rootCategories = [];

    // Organize categories into a tree structure
    for (var category in categories) {
      if (category.parent == 0 || category.parent == null) {
        // This is a top-level category
        rootCategories.add(category);
      } else {
        // This is a child category
        final parentCategory = categoryMap[category.parent];
        if (parentCategory != null) {
          // Create children list if it doesn't exist
          final children = parentCategory.children?.toList() ?? [];
          children.add(category);
          
          // Update the parent category with the new children list
          // Use non-null assertion since we've already checked parent is not null
          // and we have a valid parentCategory
          categoryMap[category.parent!] = Category(
            id: parentCategory.id,
            name: parentCategory.name,
            description: parentCategory.description,
            slug: parentCategory.slug,
            imageUrl: parentCategory.imageUrl,
            count: parentCategory.count,
            parent: parentCategory.parent,
            display: parentCategory.display,
            menuOrder: parentCategory.menuOrder,
            children: children,
          );
        }
      }
    }

    // Return only the root categories (which now have their children populated)
    return rootCategories;
  }
}
