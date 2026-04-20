import 'package:flutter/material.dart';
import '../../core/constants/color.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({super.key, required this.status, this.isSmall = false});

  Map<String, Color> _getColors() {
    switch (status.toLowerCase()) {
      case 'confirmada':
      case 'completada':
      case 'activo':
        return {'bg': AppColors.successLight, 'text': AppColors.success};
      case 'pendiente':
      case 'programada':
        return {'bg': AppColors.warningLight, 'text': AppColors.warning};
      case 'cancelada':
      case 'inactivo':
        return {'bg': AppColors.errorLight, 'text': AppColors.error};
      default:
        return {'bg': AppColors.backgroundLight, 'text': AppColors.textSecondary};
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors['text'],
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}