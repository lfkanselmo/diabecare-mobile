# Checklist de Fase 6 — Beta y publicación

`ROADMAP.md` describe Fase 6 como TestFlight/Internal Testing, Fastlane,
assets de store, declaraciones de privacidad y publicación. La mayoría de
esos ítems **no son tareas de código**: necesitan cuentas reales de
desarrollador (Apple/Google), un dispositivo o Mac reales, y decisiones de
negocio (fecha de lanzamiento, precio, mercados). Esta máquina no tiene
Android SDK/emulador ni Mac para compilar iOS — la misma limitación
documentada desde Fase 0. Este documento separa lo que ya quedó listo de lo
que depende de que alguien con esas cuentas/dispositivos lo continúe.

## Ya hecho (este repo)

- [x] Pantalla de política de privacidad pública en la app (`/legal/privacy`,
      `PrivacyPolicyScreen`) — mismo contenido que la web, enlazada de forma
      tappable desde el checkbox de términos en el registro y desde el perfil.
- [x] Declaraciones de privacidad redactadas para copiar en los formularios
      de las tiendas — ver `PRIVACY_DECLARATIONS.md` (auditoría real de qué
      datos recolecta/transmite la app, no una plantilla genérica).
- [x] Scaffold de Fastlane (`android/fastlane/`, `ios/fastlane/`) — lanes de
      build + subida a Internal Testing/TestFlight, sintaxis real y
      funcional, pendiente de credenciales reales (ver abajo).
- [x] `.gitignore` actualizado para nunca commitear credenciales de Fastlane
      (cuenta de servicio de Play, certificados de firma, API keys).
- [x] Motor de sync endurecido (Fase 5) y validado en vivo contra el backend
      real para los 10 dominios de la app (Fases 1-4) — la app está
      funcionalmente completa y probada de la única forma posible sin
      dispositivo real (`curl` contra `diabecare-api`).

## Pendiente — requiere cuentas/decisiones reales que esta sesión no tiene

### Cuentas de desarrollador
- [ ] Cuenta de Apple Developer Program (US$99/año) — necesaria para
      `ios/fastlane/Appfile` (`apple_id`, `team_id`) y para firmar/subir a
      TestFlight.
- [ ] Cuenta de Google Play Console (pago único de $25) — necesaria para
      `android/fastlane/Appfile` (cuenta de servicio JSON) y para publicar
      en Internal Testing.

### Firma de las apps
- [ ] **Android**: generar un keystore de release real (`android/key.properties`
      + `.jks`, ambos ya en `.gitignore`) — sin esto, `flutter build appbundle
      --release` no produce un artefacto instalable en Play Store.
- [ ] **iOS**: certificados de distribución + provisioning profile — vía
      Xcode manual o `fastlane match` (recomendado si más de una persona va a
      firmar builds). Requiere una Mac — no se puede configurar ni probar
      desde Windows.

### Assets de store
- [ ] Screenshots por tamaño de dispositivo requerido (iPhone 6.7"/6.5"/5.5",
      iPad si aplica; teléfono/tablet Android) — requieren un
      emulador/dispositivo real corriendo la app, que esta máquina no puede
      proveer (sin Android SDK, sin Mac para simulador iOS).
- [ ] Ícono de la app en todas las resoluciones (`flutter_launcher_icons` ya
      podría generar esto desde un solo PNG maestro — pendiente de que el
      equipo de diseño entregue el ícono final, "Calm Health" ya establecido
      en la web).
- [ ] Descripción larga/corta, palabras clave (App Store), categoría, tags —
      decisión de producto/marketing, no técnica.
- [ ] Confirmar que la política de privacidad (`/legal/privacy`) pase de
      **borrador sin revisión legal** (`legalPrivacyDraftNotice`) a versión
      final antes de publicar — bloqueante real para ambas tiendas, ninguna
      acepta una política marcada explícitamente como borrador.

### Antes de la primera subida
- [ ] Decidir el grupo reducido de testers para TestFlight/Internal Testing
      (según ROADMAP.md) — típicamente el propio equipo + algunos pacientes
      voluntarios.
- [ ] Completar los formularios reales de **App Privacy** (App Store Connect)
      y **Data Safety** (Play Console) usando `PRIVACY_DECLARATIONS.md` como
      fuente — son formularios web, no se pueden rellenar por API/CLI.
- [ ] Revisar con cuidado particular las políticas de datos de salud de cada
      tienda (HealthKit guidelines de Apple si en algún momento se integra
      Health app; Google's "Health apps" policy) — DiabeCare no usa HealthKit
      ni Google Fit todavía, pero cualquier integración futura reabre esta
      revisión.

## Cómo continuar

Cuando exista acceso real a las cuentas de desarrollador: completar los
`Appfile` de `android/fastlane/`/`ios/fastlane/` con los valores reales
(vía variables de entorno, nunca hardcodeados), generar las credenciales de
firma, y correr `fastlane android internal` / `fastlane ios beta` desde una
máquina con Android SDK (Android) o macOS con Xcode (iOS).
