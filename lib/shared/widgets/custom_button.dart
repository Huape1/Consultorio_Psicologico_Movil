import 'package:flutter/material.dart';
import '../../core/constants/color.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final String variant; // 'primary', 'secondary', 'outline', 'danger'
  final String size;    // 'small', 'medium', 'large'
  final bool disabled;
  final bool loading;
  final Widget? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPress,
    this.variant = 'primary',
    this.size = 'medium',
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Definir dimensiones según tamaño
    double verticalPadding;
    double fontSize;
    switch (size) {
      case 'small':
        verticalPadding = 8;
        fontSize = 14;
        break;
      case 'large':
        verticalPadding = 18;
        fontSize = 18;
        break;
      default: // medium
        verticalPadding = 14;
        fontSize = 16;
    }

    // Definir colores según variante
    Color bgColor;
    Color textColor;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case 'secondary':
        bgColor = AppColors.secondary;
        textColor = Colors.white;
        break;
      case 'outline':
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        border = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case 'danger':
        bgColor = AppColors.error;
        textColor = Colors.white;
        break;
      default: // primary
        bgColor = AppColors.primary;
        textColor = Colors.white;
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: ElevatedButton(
          onPressed: (disabled || loading) ? null : onPress,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: border,
            ),
          ).copyWith(
            // Esto asegura que el botón no cambie de color a gris feo cuando está desactivado
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return bgColor;
              return bgColor;
            }),
          ),
          child: loading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      variant == 'outline' ? AppColors.primary : Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}