import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final bool? featured;
  final bool? onSale;
  final String? searchQuery;

  const ProductListingScreen({
    Key? key,
    this.categoryId,
    this.categoryName,
    this.featured,
    this.onSale,
    this.searchQuery,
  }) : super(key: key);

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final ApiService _apiService = ApiService();
  static const _pageSize = 20;
  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final result = await _apiService.fetchProductsWithPagination(
        categoryId: widget.categoryId,
        page: pageKey,
        limit: _pageSize,
        featured: widget.featured,
        onSale: widget.onSale,
        search: widget.searchQuery,
      );

      final isLastPage = result['hasMore'] == false;
      final items = (result['products'] as List<Product>);

      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? 
          (widget.searchQuery != null ? 'Search: ${widget.searchQuery}' :
          (widget.featured == true ? 'Featured Products' :
          (widget.onSale == true ? 'On Sale' : 'All Products'))),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedGridView<int, Product>(
          pagingController: _pagingController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 280,
          ),
          padding: const EdgeInsets.all(8.0),
          builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, product, index) => _ProductCard(product: product),
            firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (context) => const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )),
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load products'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _pagingController.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('No products found'),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  // Sale badge if on sale
                  if (product.salePrice != null && product.salePrice! < product.price)
                    Text(
                      '\$${product.regularPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
