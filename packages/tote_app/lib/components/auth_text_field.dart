import 'package:flutter/material.dart';
import 'package:tote_app/theme/index.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isError;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isError = false,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTypography.bodyLarge,
      decoration: AppTheme.getInputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        isError: isError,
        context: context,
      ),
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
} 