import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_card.dart';

class ProductCarousel extends StatelessWidget {
  final List<Product> products;
  final String title;
  final VoidCallback? onSeeAllPressed;
  final Function(Product)? onProductTap;

  const ProductCarousel({
    Key? key,
    required this.products,
    required this.title,
    this.onSeeAllPressed,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllPressed != null)
                TextButton(
                  onPressed: onSeeAllPressed,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ProductCard(
                  product: products[index],
                  onTap: () {
                    if (onProductTap != null) {
                      onProductTap!(products[index]);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
