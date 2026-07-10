import 'package:flutter/material.dart';

/// Input de marca con validación inline. La tipografía escala con
/// `MediaQuery.textScaler` por defecto (comportamiento estándar de
/// `TextFormField`) — requisito de accesibilidad no negociable
/// (DESIGN_GUIDELINES.md sección 2.3), siempre que no se hardcodeen tamaños
/// de fuente en píxeles en el `decoration`.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.autofillHints,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
