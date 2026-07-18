import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';

/// Envoltorio único para loading/error/data, sea la fuente un `Future<T>`
/// crudo (`AsyncValueView.future`) o un `AsyncValue<T>` de Riverpod
/// (`AsyncValueView.value`). Existe porque varias pantallas resolvían esto a
/// mano con `FutureBuilder` y se les olvidaba el caso de error una y otra
/// vez — history: 4 bugs idénticos encontrados en la misma sesión de prueba
/// (spinner infinito ante cualquier error de red). Ver Fase 7 del ROADMAP.
class AsyncValueView<T> extends StatelessWidget {
  /// [future] es nullable a propósito: encaja directo con el patrón ya usado
  /// en varias pantallas de un campo `Future<T>? _xFuture` que arranca en
  /// `null` y se llena recién en `initState()` — mientras sea `null` se
  /// trata como "todavía cargando", no como error.
  const AsyncValueView.future({
    super.key,
    required this.future,
    required this.errorMessage,
    required this.builder,
    this.onRetry,
    this.loadingBuilder,
  }) : value = null;

  const AsyncValueView.value({
    super.key,
    required AsyncValue<T> this.value,
    required this.errorMessage,
    required this.builder,
    this.onRetry,
    this.loadingBuilder,
  }) : future = null;

  final Future<T>? future;
  final AsyncValue<T>? value;
  final String errorMessage;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final WidgetBuilder? loadingBuilder;

  Widget _loading(BuildContext context) =>
      KeyedSubtree(key: const ValueKey('loading'), child: loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator()));

  Widget _error(BuildContext context) =>
      KeyedSubtree(key: const ValueKey('error'), child: _AsyncErrorView(message: errorMessage, onRetry: onRetry));

  Widget _data(BuildContext context, T data) => KeyedSubtree(key: const ValueKey('data'), child: builder(context, data));

  @override
  Widget build(BuildContext context) {
    // Respeta la preferencia de "reducir movimiento" del sistema — sin
    // crossfade cuando el usuario la activó, no solo más corto.
    final duration = MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 200);

    final asyncValue = value;
    if (asyncValue != null) {
      return AnimatedSwitcher(
        duration: duration,
        child: asyncValue.when(
          data: (data) => _data(context, data),
          loading: () => _loading(context),
          error: (_, _) => _error(context),
        ),
      );
    }

    // El AnimatedSwitcher va DENTRO del builder del FutureBuilder — tiene
    // que envolver directo al hijo que cambia de key en cada snapshot, no al
    // FutureBuilder en sí (que es siempre la misma instancia, sin key propia,
    // así que envolverlo por fuera nunca dispara el crossfade).
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.hasError) {
          child = _error(context);
        } else if (!snapshot.hasData) {
          child = _loading(context);
        } else {
          child = _data(context, snapshot.data as T);
        }
        return AnimatedSwitcher(duration: duration, child: child);
      },
    );
  }
}

class _AsyncErrorView extends StatelessWidget {
  const _AsyncErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 32),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
            ],
          ],
        ),
      ),
    );
  }
}
