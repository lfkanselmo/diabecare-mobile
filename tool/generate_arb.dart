import 'dart:convert';
import 'dart:io';

/// Genera lib/core/l10n/app_{es,en}.arb a partir de los mismos
/// public/i18n/{es,en}.json que ya mantiene diabecare-web, para no duplicar
/// traducciones en un tercer set desconectado (ver ARCHITECTURE.md sección 9).
///
/// Uso: dart run tool/generate_arb.dart (desde la raíz de diabecare-mobile).
const _locales = ['es', 'en'];
final _placeholderPattern = RegExp(r'\{\{(\w+)\}\}');

void main() {
  for (final locale in _locales) {
    _generate(locale);
  }
}

void _generate(String locale) {
  final sourcePath = '../diabecare-web/public/i18n/$locale.json';
  final source = jsonDecode(File(sourcePath).readAsStringSync()) as Map<String, dynamic>;

  final arb = <String, dynamic>{'@@locale': locale};
  _flatten(source, '', arb);

  final outDir = Directory('lib/core/l10n')..createSync(recursive: true);
  final outFile = File('${outDir.path}/app_$locale.arb');
  const encoder = JsonEncoder.withIndent('  ');
  outFile.writeAsStringSync('${encoder.convert(arb)}\n');

  final keyCount = arb.keys.where((k) => !k.startsWith('@')).length;
  stdout.writeln('Generado ${outFile.path} ($keyCount claves)');
}

void _flatten(Map<String, dynamic> node, String prefix, Map<String, dynamic> out) {
  node.forEach((key, value) {
    final flatKey = prefix.isEmpty ? key : '$prefix${_capitalize(key)}';
    if (value is Map<String, dynamic>) {
      _flatten(value, flatKey, out);
      return;
    }

    final text = value.toString();
    final placeholders = _placeholderPattern.allMatches(text).map((m) => m.group(1)!).toSet();
    out[flatKey] = placeholders.isEmpty
        ? text
        : text.replaceAllMapped(_placeholderPattern, (m) => '{${m.group(1)}}');

    if (placeholders.isNotEmpty) {
      out['@$flatKey'] = {
        'placeholders': {for (final p in placeholders) p: <String, dynamic>{}},
      };
    }
  });
}

String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
