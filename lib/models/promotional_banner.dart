import 'package:flutter/material.dart';

class PromotionalBanner {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? buttonColor;
  final Color? buttonTextColor;

  PromotionalBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.buttonColor,
    this.buttonTextColor,
  });
}
