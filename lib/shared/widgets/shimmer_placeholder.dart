import 'package:flutter/material.dart';

/// Placeholder de carga tipo shimmer — sin paquete externo, un
/// `AnimationController` moviendo un `LinearGradient` sobre un bloque del
/// color de superficie. Pensado para reemplazar el spinner centrado
/// universal en las pantallas de mayor tráfico (dashboard, historiales).
class ShimmerPlaceholder extends StatefulWidget {
  const ShimmerPlaceholder({super.key, this.height = 16, this.width, this.borderRadius});

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment(-1 + 3 * t, 0),
              end: Alignment(1 + 3 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// Composición lista para usar como `loadingBuilder` de `AsyncValueView` en
/// pantallas con lista: N filas shimmer del mismo alto que un `ListTile`.
class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const ShimmerPlaceholder(height: 64, borderRadius: BorderRadius.all(Radius.circular(14))),
    );
  }
}
