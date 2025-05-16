import 'package:flutter/material.dart';

class PromotionalBanner {
  final String id;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final int? categoryId;
  final String? buttonText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? buttonColor;
  final Color? buttonTextColor;

  PromotionalBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.categoryId,
    this.buttonText,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.buttonColor,
    this.buttonTextColor,
  });

  // Convert from JSON
  factory PromotionalBanner.fromJson(Map<String, dynamic> json) {
    return PromotionalBanner(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      categoryId: json['category_id'],
      buttonText: json['button_text'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'category_id': categoryId,
      'button_text': buttonText,
    };
  }
}
