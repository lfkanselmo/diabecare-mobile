import 'dart:async';

import 'package:flutter/material.dart';

/// Entrada sutil (fade + slide vertical corto) para las tarjetas del
/// dashboard al montar la pantalla — con [delay] escalonado entre tarjetas
/// se lee como una secuencia deliberada, no como todo apareciendo de golpe.
/// Respeta la preferencia de "reducir movimiento" del sistema (sin animar).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<double> _curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;

    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curved.value,
        child: Transform.translate(offset: Offset(0, (1 - _curved.value) * 10), child: child),
      ),
    );
  }
}
