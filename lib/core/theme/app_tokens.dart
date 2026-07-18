import 'package:flutter/material.dart';

/// Tokens de radio, tipografía y espaciado — misma fuente que `AppColors`
/// (`diabecare-web/src/styles/_tokens.scss`). No reinventar estos valores:
/// si cambian en la web, cambian aquí. Ver DESIGN_GUIDELINES.md sección 2.4.
class AppRadii {
  AppRadii._();

  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 14.0;
  static const xl = 20.0;
  static const full = 9999.0;
}

class AppSpacing {
  AppSpacing._();

  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s16 = 64.0;
}

class AppFontSizes {
  AppFontSizes._();

  static const xs = 12.0;
  static const sm = 14.0;
  static const md = 16.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xl2 = 28.0;
  static const metric = 36.0;
}

class AppFontWeights {
  AppFontWeights._();

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  // semibold y bold son ambos 500 en _tokens.scss (no es un typo de acá,
  // es así también en la web) — 600/700 quedan disponibles en la fuente
  // empaquetada pero sin un rol semántico asignado todavía.
  static const semibold = FontWeight.w500;
  static const bold = FontWeight.w500;
}
