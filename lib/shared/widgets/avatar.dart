import 'package:flutter/material.dart';
import '../../core/constants/color.dart';

class Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String size; // 'small', 'medium', 'large', 'xlarge'
  final bool showOnlineStatus;
  final bool isOnline;

  const Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 'medium',
    this.showOnlineStatus = false,
    this.isOnline = false,
  });

  // Configuración de medidas centralizada
  Map<String, double> _getSizeConfigs() {
    switch (size) {
      case 'small':
        return {'container': 32, 'text': 12, 'indicator': 10};
      case 'large':
        return {'container': 64, 'text': 20, 'indicator': 18};
      case 'xlarge':
        return {'container': 96, 'text': 32, 'indicator': 26};
      default:
        return {'container': 48, 'text': 16, 'indicator': 14}; // medium
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSizeConfigs();
    final double containerSize = config['container']!;

    return Stack(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias, // Mantiene todo circular
          child: _buildContent(config['text']!),
        ),
        if (showOnlineStatus)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: config['indicator'],
              height: config['indicator'],
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(double fontSize) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(fontSize),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        },
      );
    }
    return _buildInitials(fontSize);
  }

  Widget _buildInitials(double fontSize) {
    return Center(
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
