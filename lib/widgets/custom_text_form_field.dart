import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final void Function()? onTap;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
      keyboardType: keyboardType,
      onTap: onTap,
    );
  }
}
