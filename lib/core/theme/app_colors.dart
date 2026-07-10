import 'package:flutter/material.dart';

/// Tokens de marca "Calm Health" — misma fuente que `diabecare-web`
/// (`src/styles/_palette.scss` / `_tokens.scss`). Ver DESIGN_GUIDELINES.md
/// sección 2. No reinventar estos valores: si cambian en la web, cambian aquí.
class AppColors {
  AppColors._();

  // ── Marca ──────────────────────────────────────────────────────────────
  static const primary = Color(0xFF5B4FCF);
  static const primaryDark = Color(0xFF9588ED);

  // ── Semánticos ─────────────────────────────────────────────────────────
  static const success = Color(0xFF22A96A);
  static const successDark = Color(0xFF4ADE98);
  static const warning = Color(0xFFE8A020);
  static const warningDark = Color(0xFFFABD4A);
  static const danger = Color(0xFFE04B4B);
  static const dangerDark = Color(0xFFF07070);
  static const info = Color(0xFF0EA5A0);

  // ── Estados clínicos de glucosa — significan lo mismo en toda la app,
  // no se adaptan por plataforma ni por tema (ver DESIGN_GUIDELINES.md 2.2).
  static const glucoseCriticallyLow = Color(0xFF9B1D6A);
  static const glucoseCriticallyLowDark = Color(0xFFF48FB1);
  static const glucoseLow = Color(0xFFE04B4B);
  static const glucoseLowDark = Color(0xFFF07070);
  static const glucoseNormal = Color(0xFF22A96A);
  static const glucoseNormalDark = Color(0xFF4ADE98);
  static const glucoseHigh = Color(0xFFE8A020);
  static const glucoseHighDark = Color(0xFFFABD4A);
  static const glucoseCriticallyHigh = Color(0xFFBF360C);
  static const glucoseCriticallyHighDark = Color(0xFFFF8A65);

  // ── Superficies ────────────────────────────────────────────────────────
  static const backgroundLight = Color(0xFFF7F6FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const backgroundDark = Color(0xFF000000);
  static const surfaceDark = Color(0xFF121214);
}
