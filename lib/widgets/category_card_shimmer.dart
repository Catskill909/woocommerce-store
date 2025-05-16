import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryCardShimmer extends StatelessWidget {
  final double size;
  final double borderRadius;

  const CategoryCardShimmer({
    Key? key,
    this.size = 70,
    this.borderRadius = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: size * 0.8,
            height: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
