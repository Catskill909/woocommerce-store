import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' hide Category;
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';

class ApiService {
  final String baseUrl = 'https://store.supersoul.top/wp-json';
  
  // Constants for pagination
  static const int maxPerPage = 100;
  static const int defaultPerPage = 20;

  final String consumerKey =
      'ck_33186c3fb6716e0e34795fc6bdd3828ead23d4a0';
  final String consumerSecret =
      'cs_eeebcb7fdc7ab5b236ad88dae60f47de6927e62e';

  // Helper method to build authentication parameters
  Map<String, String> _getAuthParams() {
    return {
      'consumer_key': consumerKey,
      'consumer_secret': consumerSecret,
    };
  }

  // Helper method to build URL with authentication
  String _buildUrl(String endpoint, Map<String, dynamic>? queryParams, {bool isWoo = true}) {
    final authParams = _getAuthParams();
    final params = queryParams != null ? {...queryParams, ...authParams} : authParams;
    
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    return '${isWoo ? '$baseUrl/wc/v3' : '$baseUrl/wp/v2'}/$endpoint?$queryString';
  }

  // Helper method to handle paginated requests
  Future<List<dynamic>> _fetchPaginated(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool isWoo = true,
    int perPage = defaultPerPage,
    int maxPages = 10,
  }) async {
    List<dynamic> allItems = [];
    int currentPage = 1;
    bool hasMorePages = true;

    while (hasMorePages && currentPage <= maxPages) {
      final params = {
        'per_page': perPage,
        'page': currentPage,
        ...?queryParams,
      };

      final url = _buildUrl(endpoint, params, isWoo: isWoo);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isEmpty) {
          hasMorePages = false;
        } else {
          allItems.addAll(jsonResponse);
          currentPage++;
        }
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    }

    return allItems;
  }

  // WordPress Posts
  Future<List<dynamic>> fetchPosts({
    int? perPage,
    int? page,
    String? search,
    String? category,
    String? tag,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (perPage != null) queryParams['per_page'] = perPage;
    if (page != null) queryParams['page'] = page;
    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['categories'] = category;
    if (tag != null) queryParams['tags'] = tag;
    if (status != null) queryParams['status'] = status;

    return _fetchPaginated('posts', queryParams: queryParams, isWoo: false);
  }

  // WordPress Pages
  Future<List<dynamic>> fetchPages({
    int? perPage,
    int? page,
    String? parent,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (perPage != null) queryParams['per_page'] = perPage;
    if (page != null) queryParams['page'] = page;
    if (parent != null) queryParams['parent'] = parent;
    if (status != null) queryParams['status'] = status;

    return _fetchPaginated('pages', queryParams: queryParams, isWoo: false);
  }

  // WooCommerce Products (raw response)
  Future<List<dynamic>> fetchRawProducts({
    int? perPage,
    int? page,
    int? categoryId,
    int? brandId,
    String? search,
    bool? featured,
    bool? onSale,
    String? status,
    List<int>? include,
    List<int>? exclude,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (perPage != null) queryParams['per_page'] = perPage;
    if (page != null) queryParams['page'] = page;
    if (categoryId != null) queryParams['category'] = categoryId;
    if (brandId != null) queryParams['brand'] = brandId;
    if (search != null) queryParams['search'] = search;
    if (featured != null) queryParams['featured'] = featured;
    if (onSale != null) queryParams['on_sale'] = onSale;
    if (status != null) queryParams['status'] = status;
    
    if (include != null && include.isNotEmpty) {
      queryParams['include'] = include.join(',');
    }
    
    if (exclude != null && exclude.isNotEmpty) {
      queryParams['exclude'] = exclude.join(',');
    }

    return _fetchPaginated('products', queryParams: queryParams);
  }



  // Get a single product by ID
  Future<Product> fetchProductById(int productId) async {
    final url = _buildUrl('products/$productId', null);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  // Get a single category by ID
  Future<Category> fetchCategoryById(int categoryId) async {
    final url = _buildUrl('products/categories/$categoryId', null);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Category.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load category: ${response.statusCode}');
    }
  }

  // Get all categories
  Future<List<Category>> fetchCategories({int perPage = 100}) async {
    final url = _buildUrl('products/categories', {'per_page': perPage});
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  // Get all brands
  Future<List<Brand>> fetchBrands() async {
    final url = _buildUrl('products/brands', {'per_page': 100});
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((brand) => Brand.fromJson(brand)).toList();
    } else {
      throw Exception('Failed to load brands: ${response.statusCode}');
    }
  }

  // Get a single brand by ID
  Future<Brand> fetchBrandById(int brandId) async {
    final url = _buildUrl('products/brands/$brandId', null);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Brand.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load brand: ${response.statusCode}');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    final queryParams = <String, dynamic>{};
    queryParams['search'] = query;
    queryParams['per_page'] = limit;

    final products = await _fetchPaginated('products', queryParams: queryParams);
    return products.map((p) => Product.fromJson(p)).toList();
  }

  // Get category tree
  Future<List<Category>> fetchCategoryTree({int perPage = 100}) async {
    final categories = await fetchCategories(perPage: perPage);
    return _buildCategoryTree(categories);
  }

  // Helper method to build category tree
  List<Category> _buildCategoryTree(List<Category> categories) {
    final Map<int, Category> categoryMap = {
      for (var category in categories) category.id: category
    };

    return categories
        .where((category) => category.parent == 0)
        .map((category) => category.copyWith(
              children: _getChildren(category.id, categoryMap),
            ))
        .toList();
  }

  // Helper method to get children categories
  List<Category> _getChildren(int parentId, Map<int, Category> categoryMap) {
    return categoryMap.entries
        .where((entry) => entry.value.parent == parentId)
        .map((entry) => entry.value.copyWith(
              children: _getChildren(entry.key, categoryMap),
            ))
        .toList();
  }

  // Get featured products
  Future<List<Product>> fetchFeaturedProducts({int limit = 10}) async {
    final queryParams = <String, dynamic>{};
    queryParams['per_page'] = limit;
    queryParams['featured'] = true;

    final products = await _fetchPaginated('products', queryParams: queryParams);
    return products.map((p) => Product.fromJson(p)).toList();
  }

  // Get on sale products
  Future<List<Product>> fetchOnSaleProducts({int limit = 10}) async {
    final queryParams = <String, dynamic>{};
    queryParams['per_page'] = limit;
    queryParams['on_sale'] = true;

    final products = await _fetchPaginated('products', queryParams: queryParams);
    return products.map((p) => Product.fromJson(p)).toList();
  }

  // Get related products
  Future<List<Product>> fetchRelatedProducts(int productId, {int limit = 4}) async {
    final product = await fetchProductById(productId);
    if (product.categories.isEmpty) {
      final queryParams = <String, dynamic>{};
      queryParams['per_page'] = limit;
      
      final products = await _fetchPaginated('products', queryParams: queryParams);
      return products.map((p) => Product.fromJson(p)).toList();
    }

    final queryParams = <String, dynamic>{};
    queryParams['per_page'] = limit;
    queryParams['category'] = product.categories.first;
    queryParams['exclude'] = productId;

    final products = await _fetchPaginated('products', queryParams: queryParams);
    return products.map((p) => Product.fromJson(p)).toList();
  }

  // Get products by category
  Future<List<Product>> fetchProductsByCategory(int categoryId, {int limit = 20}) async {
    final queryParams = <String, dynamic>{};
    queryParams['per_page'] = limit;
    queryParams['category'] = categoryId;

    final products = await _fetchPaginated('products', queryParams: queryParams);
    return products.map((p) => Product.fromJson(p)).toList();
  }

  // Get products by brand
  Future<List<Product>> fetchProductsByBrand(int brandId, {int limit = 20}) async {
    final queryParams = <String, dynamic>{};
    queryParams['per_page'] = limit;
    queryParams['brand'] = brandId;

    final products = await _fetchPaginated('products', queryParams: queryParams);
    return products.map((p) => Product.fromJson(p)).toList();
  }

  // Fetch products with various filters and pagination support
  Future<List<Product>> fetchProducts({
    int? categoryId,
    int? brandId,
    int? limit = 20, // Increased default limit
    String? orderby = 'date', // Default to newest first
    String? search,
    bool? featured,
    bool? onSale,
    String? status = 'publish', // Only fetch published products by default
    List<int>? include,
    List<int>? exclude,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': limit,
      'page': page,
      'status': status,
      'orderby': orderby,
      'order': 'desc', // Newest first by default
    };
    
    // Add optional filters
    if (categoryId != null) queryParams['category'] = categoryId;
    if (brandId != null) queryParams['brand'] = brandId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (featured != null) queryParams['featured'] = featured;
    if (onSale != null) queryParams['on_sale'] = onSale;
    
    if (include != null && include.isNotEmpty) {
      queryParams['include'] = include.join(',');
    }
    
    if (exclude != null && exclude.isNotEmpty) {
      queryParams['exclude'] = exclude.join(',');
    }
    
    final url = _buildUrl('products', queryParams);
    
    if (kDebugMode) debugPrint('Fetching products from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
  
  // Fetch products with pagination support
  Future<Map<String, dynamic>> fetchProductsWithPagination({
    int? categoryId,
    int? brandId,
    int limit = 20,
    int page = 1,
    String? orderby = 'date',
    String? search,
    bool? featured,
    bool? onSale,
  }) async {
    final response = await http.get(Uri.parse(
      _buildUrl('products', {
        'per_page': limit,
        'page': page,
        if (categoryId != null) 'category': categoryId,
        if (brandId != null) 'brand': brandId,
        if (orderby != null) 'orderby': orderby,
        'order': 'desc',
        if (search != null && search.isNotEmpty) 'search': search,
        if (featured != null) 'featured': featured,
        if (onSale != null) 'on_sale': onSale,
        'status': 'publish',
      }),
    ));

    if (response.statusCode == 200) {
      final totalItems = int.tryParse(response.headers['x-wp-total'] ?? '0') ?? 0;
      final totalPages = int.tryParse(response.headers['x-wp-totalpages'] ?? '1') ?? 1;
      
      List<dynamic> jsonResponse = json.decode(response.body);
      final products = jsonResponse.map((p) => Product.fromJson(p)).toList();
      
      return {
        'products': products,
        'totalItems': totalItems,
        'totalPages': totalPages,
        'currentPage': page,
        'hasMore': page < totalPages,
      };
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
