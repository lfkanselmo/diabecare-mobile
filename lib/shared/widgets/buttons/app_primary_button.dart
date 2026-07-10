import 'package:flutter/material.dart';

/// Botón de acción principal de marca — Material `FilledButton` en ambas
/// plataformas (no está en la tabla de adaptación de DESIGN_GUIDELINES.md
/// sección 5; HIG no exige una forma distinta para esto).
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({super.key, required this.label, required this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );
  }
}
