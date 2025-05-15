import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../screens/product_detail_screen.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final ApiService _apiService;
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  ProductSearchDelegate(this._apiService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _searchResults = [];
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Center(
        child: Text(
          'Search term must be at least 3 characters long',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (query != _lastQuery) {
      _performSearch();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No products found for "$query"',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ListTile(
          leading: product.imageUrl.isNotEmpty
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                )
              : const Icon(Icons.image_not_supported),
          title: Text(product.name),
          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Enter at least 3 characters to search',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return buildResults(context);
  }

  Future<void> _performSearch() async {
    _isLoading = true;
    _lastQuery = query;

    try {
      // In a real app, you would have a dedicated search endpoint
      // For now, we'll just fetch all products and filter them
      final products = await _apiService.fetchProducts();
      _searchResults = products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      _searchResults = [];
    } finally {
      _isLoading = false;
    }
  }
}
