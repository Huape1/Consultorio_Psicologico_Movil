import 'package:flutter/material.dart';
import '../../core/constants/color.dart';

class CustomInput extends StatefulWidget {
  final String? label;
  final String placeholder;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomInput({
    super.key,
    this.label,
    required this.placeholder,
    this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.label!, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppColors.textSecondary) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}