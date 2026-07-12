import 'dart:convert';
import 'dart:io';

/// Falla (exit 1) si `app_es.arb` y `app_en.arb` tienen claves distintas —
/// evita que una pantalla nueva quede sin traducir en un idioma porque se
/// agregó la clave a mano en uno de los dos archivos y se olvidó el otro
/// (ver ROADMAP.md Fase 4). No regenera nada — a diferencia de
/// `generate_arb.dart` (que sobreescribe ambos ARB desde los JSON de
/// diabecare-web), esto solo compara los archivos tal cual están, porque
/// desde Fase 1 se agregan claves mobile-only a mano que no existen en la web.
///
/// Uso: dart run tool/check_arb_parity.dart (desde la raíz de diabecare-mobile).
void main() {
  final esKeys = _translatableKeys('lib/core/l10n/app_es.arb');
  final enKeys = _translatableKeys('lib/core/l10n/app_en.arb');

  final onlyInEs = esKeys.difference(enKeys);
  final onlyInEn = enKeys.difference(esKeys);

  if (onlyInEs.isEmpty && onlyInEn.isEmpty) {
    stdout.writeln('OK: app_es.arb y app_en.arb tienen las mismas ${esKeys.length} claves.');
    return;
  }

  stderr.writeln('Paridad i18n rota entre app_es.arb y app_en.arb:');
  if (onlyInEs.isNotEmpty) {
    stderr.writeln('  Solo en es (${onlyInEs.length}): ${(onlyInEs.toList()..sort()).join(', ')}');
  }
  if (onlyInEn.isNotEmpty) {
    stderr.writeln('  Solo en en (${onlyInEn.length}): ${(onlyInEn.toList()..sort()).join(', ')}');
  }
  exitCode = 1;
}

Set<String> _translatableKeys(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => k != '@@locale' && !k.startsWith('@')).toSet();
}
