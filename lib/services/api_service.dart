import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' hide Category;
import '../models/product.dart';
import '../models/category.dart';
import '../models/brand.dart';

class ApiService {
  final String baseUrl = 'https://store.supersoul.top/wp-json/wc/v3';
  final String consumerKey =
      'ck_33186c3fb6716e0e34795fc6bdd3828ead23d4a0'; // Updated with actual consumer key
  final String consumerSecret =
      'cs_eeebcb7fdc7ab5b236ad88dae60f47de6927e62e'; // Updated with actual consumer secret

  // Helper method to build authentication parameters
  Map<String, String> _getAuthParams() {
    return {
      'consumer_key': consumerKey,
      'consumer_secret': consumerSecret,
    };
  }

  // Helper method to build URL with authentication
  String _buildUrl(String endpoint, Map<String, dynamic>? queryParams) {
    final authParams = _getAuthParams();
    final params = queryParams != null ? {...queryParams, ...authParams} : authParams;
    
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    return '$baseUrl/$endpoint?$queryString';
  }

  // PRODUCTS
  Future<List<Product>> fetchProducts({
    int? categoryId,
    int? brandId,
    int? limit,
    String? orderby,
    String? search,
    bool? featured,
    bool? onSale,
    String? status,
    List<int>? include,
    List<int>? exclude,
    int page = 1,
  }) async {
    // Default to 20 products per page if not specified
    limit = limit ?? 20;
    
    final queryParams = <String, dynamic>{
      'per_page': limit,
      'page': page,
    };
    
    // Add optional filters
    if (categoryId != null) queryParams['category'] = categoryId;
    if (brandId != null) queryParams['brand'] = brandId;
    if (orderby != null) queryParams['orderby'] = orderby;
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
    
    final url = _buildUrl('products', queryParams);
    
    // Use debugPrint instead of print for better logging in production
    if (kDebugMode) debugPrint('Fetching products from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
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

  // CATEGORIES
  Future<List<Category>> fetchCategories({
    int? parent,
    bool hideEmpty = false,
    String? orderby,
    String? order,
    int? perPage,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'hide_empty': hideEmpty,
      'page': page,
    };
    
    if (parent != null) queryParams['parent'] = parent;
    if (orderby != null) queryParams['orderby'] = orderby;
    if (order != null) queryParams['order'] = order;
    if (perPage != null) queryParams['per_page'] = perPage;
    
    final url = _buildUrl('products/categories', queryParams);
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      final categories = jsonResponse.map((category) => Category.fromJson(category)).toList();
      
      // Return as a flat list or organize into a tree structure
      return categories;
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }
  
  // Get a category by ID
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

  // BRANDS
  Future<List<Brand>> fetchBrands({
    int? parent,
    bool hideEmpty = false,
    String? orderby,
    String? order,
    int? perPage,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'hide_empty': hideEmpty,
      'page': page,
    };
    
    if (parent != null) queryParams['parent'] = parent;
    if (orderby != null) queryParams['orderby'] = orderby;
    if (order != null) queryParams['order'] = order;
    if (perPage != null) queryParams['per_page'] = perPage;
    
    final url = _buildUrl('products/brands', queryParams);
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((brand) => Brand.fromJson(brand)).toList();
    } else {
      throw Exception('Failed to load brands: ${response.statusCode}');
    }
  }
  
  // Get a brand by ID
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
  
  // SEARCH
  Future<List<Product>> searchProducts(String query, {int limit = 20, int page = 1}) async {
    final queryParams = <String, dynamic>{
      'search': query,
      'per_page': limit,
      'page': page,
    };
    
    final url = _buildUrl('products', queryParams);
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to search products: ${response.statusCode}');
    }
  }
  
  // Get hierarchical categories
  Future<List<Category>> fetchCategoryTree() async {
    final categories = await fetchCategories(perPage: 100);
    return Category.buildCategoryTree(categories);
  }
  
  // Get featured products
  Future<List<Product>> fetchFeaturedProducts({int limit = 10}) async {
    return fetchProducts(featured: true, limit: limit);
  }
  
  // Get on-sale products
  Future<List<Product>> fetchOnSaleProducts({int limit = 10}) async {
    return fetchProducts(onSale: true, limit: limit);
  }
  
  // Get related products
  Future<List<Product>> fetchRelatedProducts(int productId, {int limit = 10}) async {
    final product = await fetchProductById(productId);
    
    if (product.relatedIds != null && product.relatedIds!.isNotEmpty) {
      // relatedIds is now directly a List<int>, so we can use it directly
      final relatedIds = product.relatedIds!;
      return fetchProducts(include: relatedIds, limit: limit);
    }
    
    // If no related IDs, fetch products from the same category
    if (product.categories.isNotEmpty) {
      return fetchProducts(
        categoryId: int.tryParse(product.categories.first) ?? 0,
        exclude: [productId],
        limit: limit,
      );
    }
    
    return [];
  }
}
