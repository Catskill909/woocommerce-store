import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final double size;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.size = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(224, 224, 224, 0.2), // Colors.grey[200] with 0.2 opacity
                  spreadRadius: 1.0,
                  blurRadius: 3.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: category.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(size / 2),
                    child: Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.category, size: 30);
                      },
                    ),
                  )
                : Icon(
                    Icons.category,
                    size: size * 0.4,
                    color: Colors.grey[600],
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size + 20,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
