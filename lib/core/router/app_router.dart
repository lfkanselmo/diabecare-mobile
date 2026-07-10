import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Esqueleto de navegación — cada feature agrega sus propias rutas conforme
/// se construye (ver ROADMAP.md). Placeholder único mientras Fase 0 no tiene
/// pantallas reales todavía.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _PlaceholderHome(),
    ),
  ],
);

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'DiabeCare Mobile\n(Fase 0 — sin pantallas todavía)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
