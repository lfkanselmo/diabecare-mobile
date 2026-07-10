import 'dart:ui';

import 'package:dio/dio.dart';

/// Header `Accept-Language` para que el backend resuelva mensajes/etiquetas
/// en el idioma activo (mismo propósito que ya cumple en `diabecare-web`).
/// [localeCode] es inyectable para tests; por defecto usa el locale del
/// sistema operativo (no depende del árbol de widgets).
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor({String Function()? localeCode})
    : _localeCode = localeCode ?? _systemLocaleCode;

  final String Function() _localeCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _localeCode();
    handler.next(options);
  }

  static String _systemLocaleCode() => PlatformDispatcher.instance.locale.languageCode;
}
