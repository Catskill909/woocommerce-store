import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';

class ApiService {
  final String baseUrl = 'https://store.supersoul.top/wp-json/wc/v3';
  final String consumerKey =
      'ck_33186c3fb6716e0e34795fc6bdd3828ead23d4a0'; // Updated with actual consumer key
  final String consumerSecret =
      'cs_eeebcb7fdc7ab5b236ad88dae60f47de6927e62e'; // Updated with actual consumer secret

  Future<List<Product>> fetchProducts({int? categoryId, int? limit, String? orderby}) async {
    // Default to 20 products per page if not specified
    limit = limit ?? 20;
    
    String url = '$baseUrl/products?consumer_key=$consumerKey&consumer_secret=$consumerSecret&per_page=$limit';
    
    // Add category filter if provided
    if (categoryId != null) {
      url += '&category=$categoryId';
    }
    
    // Add ordering parameter if provided
    if (orderby != null) {
      url += '&orderby=$orderby';
    }
    
    print('Fetching products from: $url'); // Debug output
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
  
  Future<List<Category>> fetchCategories() async {
    final url = '$baseUrl/products/categories?consumer_key=$consumerKey&consumer_secret=$consumerSecret&per_page=100';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }
  
  // Get a single product by ID
  Future<Product> fetchProductById(int productId) async {
    final url = '$baseUrl/products/$productId?consumer_key=$consumerKey&consumer_secret=$consumerSecret';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }
}
