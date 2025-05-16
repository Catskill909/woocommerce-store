import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../models/banner.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';

import '../widgets/banner_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';
import '../widgets/category_card_shimmer.dart';
import '../widgets/section_header.dart';
import '../widgets/product_card_shimmer.dart';
import '../widgets/product_search_delegate.dart';
import 'product_listing_screen.dart';
import 'product_detail_screen.dart';
import 'category_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _featuredProductsFuture;
  late Future<List<Product>> _newProductsFuture;
  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _onSaleProductsFuture;
  
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Sample banner data - in a real app, this would come from an API
  final List<PromotionalBanner> _banners = [
    PromotionalBanner(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      title: 'Summer Collection',
      subtitle: 'Up to 50% off',
      categoryId: null,
    ),
    PromotionalBanner(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      title: 'New Arrivals',
      subtitle: 'Check out our latest products',
      categoryId: null,
    ),
    PromotionalBanner(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      title: 'Exclusive Deals',
      subtitle: 'Limited time offers',
      categoryId: null,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _loadData() {
    // Fetch data for different sections
    _newProductsFuture = _apiService.fetchProducts(
      orderby: 'date',
      limit: 10,
    );
    
    _featuredProductsFuture = _apiService.fetchProducts(
      featured: true,
      limit: 8,
    );
    
    _onSaleProductsFuture = _apiService.fetchProducts(
      onSale: true,
      limit: 8,
    );
    
    _categoriesFuture = _apiService.fetchCategories(perPage: 8);
  }
  
  void _navigateToCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingScreen(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    );
  }
  
  void _navigateToAllCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryListingScreen(),
      ),
    );
  }

  void _navigateToAllProducts({String? title, bool? featured, bool? onSale}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingScreen(
          categoryName: title,
          featured: featured,
          onSale: onSale,
        ),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  // Build categories section
  Widget _buildCategoriesSection() {
    return Column(
      children: [
        SectionHeader(
          title: 'Categories',
          onViewAll: _navigateToAllCategories,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: CategoryCardShimmer(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories found'));
              }

              final categories = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CategoryCard(
                      category: category,
                      onTap: () => _navigateToCategory(category),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Build product carousel
  Widget _buildProductCarousel(String title, List<Product> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListingScreen(
                  categoryId: null,
                  categoryName: title,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 160,
                  child: ProductCard(
                    product: product,
                    onTap: () => _navigateToProductDetail(product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WooCommerce Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(_apiService),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: const Text(
                '0',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cart functionality coming soon')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Banner Carousel
            SliverToBoxAdapter(
              child: BannerCarousel(
                banners: _banners,
                onBannerTap: (index) {
                  final banner = _banners[index];
                  if (banner.categoryId != null) {
                    _navigateToCategory(Category(
                      id: banner.categoryId!,
                      name: banner.title,
                      slug: banner.title.toLowerCase().replaceAll(' ', '-'),
                      count: 0, // Add default count
                    ));
                  } else {
                    _navigateToAllProducts(title: banner.title);
                  }
                },
              ),
            ),
            
            // Main content
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildCategoriesSection(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Featured Products
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FutureBuilder<List<Product>>(
                      future: _featuredProductsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ProductCardShimmer();
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No featured products found'));
                        }
                        return _buildProductCarousel('Featured Products', snapshot.data!);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // New Arrivals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FutureBuilder<List<Product>>(
                      future: _newProductsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ProductCardShimmer();
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No new products found'));
                        }
                        return _buildProductCarousel('New Arrivals', snapshot.data!);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // On Sale
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FutureBuilder<List<Product>>(
                      future: _onSaleProductsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ProductCardShimmer();
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No products on sale'));
                        }
                        return _buildProductCarousel('On Sale', snapshot.data!);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
