import 'package:flutter/material.dart';
import '../../core/constants/color.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? marginBottom;
  final String variant; // 'default', 'elevated', 'outlined'

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.marginBottom,
    this.variant = 'default',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom ?? 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: variant == 'outlined' 
            ? Border.all(color: AppColors.border) 
            : null,
        boxShadow: variant == 'outlined' ? null : [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: variant == 'elevated' ? 8 : 4,
            offset: Offset(0, variant == 'elevated' ? 4 : 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}