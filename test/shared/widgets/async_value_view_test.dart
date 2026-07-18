import 'dart:async';

import 'package:diabecare_mobile/core/l10n/app_localizations.dart';
import 'package:diabecare_mobile/shared/widgets/async_value_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('AsyncValueView.future', () {
    testWidgets('mientras el Future no resuelve, muestra loading', (tester) async {
      final completer = Completer<String>(); // nunca se completa a propósito
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.future(
            future: completer.future,
            errorMessage: 'error',
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('future null se trata como loading, no como error', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.future(
            future: null,
            errorMessage: 'error',
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('error'), findsNothing);
    });

    testWidgets('con datos, renderiza el builder', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.future(
            future: Future.value('hola'),
            errorMessage: 'error',
            builder: (context, data) => Text(data),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('hola'), findsOneWidget);
    });

    testWidgets('ante un error, muestra el mensaje en vez de spinner infinito', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.future(
            future: Future<String>.delayed(Duration.zero, () => throw Exception('boom')),
            errorMessage: 'algo salió mal',
            builder: (context, data) => Text(data),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('algo salió mal'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('con onRetry, muestra un botón de reintentar que lo invoca', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.future(
            future: Future<String>.delayed(Duration.zero, () => throw Exception('boom')),
            errorMessage: 'algo salió mal',
            onRetry: () => retried = true,
            builder: (context, data) => Text(data),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      expect(retried, isTrue);
    });

    testWidgets('sin onRetry, no muestra botón de reintentar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.future(
            future: Future<String>.delayed(Duration.zero, () => throw Exception('boom')),
            errorMessage: 'algo salió mal',
            builder: (context, data) => Text(data),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsNothing);
    });
  });

  group('AsyncValueView.value', () {
    testWidgets('AsyncLoading muestra el spinner', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.value(
            value: const AsyncLoading<String>(),
            errorMessage: 'error',
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AsyncData renderiza el builder', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.value(
            value: const AsyncData<String>('hola'),
            errorMessage: 'error',
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.text('hola'), findsOneWidget);
    });

    testWidgets('AsyncError muestra el mensaje de error', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncValueView<String>.value(
            value: AsyncError<String>(Exception('boom'), StackTrace.empty),
            errorMessage: 'algo salió mal',
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.text('algo salió mal'), findsOneWidget);
    });
  });
}
