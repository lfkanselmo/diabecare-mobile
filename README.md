# DiabeCare Mobile

Apps nativas para Android e iOS de DiabeCare — control de salud para pacientes diabéticos. Construidas con Flutter, con paridad completa de funcionalidades respecto a [`diabecare-web`](../diabecare-web) y soporte offline-first, consumiendo la misma API de [`diabecare-api`](../diabecare-api).

---

## Estado actual

**Fases 0 a 5 completas — todas las fases de funcionalidad y hardening del roadmap.** Auth real contra `diabecare-api` (login, registro, refresh con rotación de token, logout, recuperación de contraseña), sesión persistida en `flutter_secure_storage`, bloqueo biométrico opcional, design system base (widgets adaptativos Android/iOS), i18n generado desde los mismos `es.json`/`en.json` de la web (con un script de paridad `es`/`en` corriendo en CI). Núcleo clínico: glucosa (registro con conexión BLE a glucómetro, historial con gráfica, estadísticas TIR/HbA1c/CV, perfil AGP). Registro diario: nutrición (comidas, buscador de alimentos, escaneo de código de barras vía OpenFoodFacts), signos vitales, ejercicio, medicamentos (registro/desactivación) y calculadora de insulina con perfil configurable — estos 5 dominios están conectados al motor de sincronización offline-first (Drift + outbox + pull incremental vía `/sync`). Funcionalidades avanzadas: ciclo menstrual (con correlación glucémica), reportes médicos en PDF, cuidadores (invitar/canjear/vista de solo lectura) y gestión de cuenta (exportar datos, suspender/eliminar cuenta, sesiones activas, API keys de dispositivo) — estos 4 dominios son 100% online, sin necesidad de offline-first. Panel de administración (rol ADMIN): listar usuarios, cambiar roles, recargar configuración del sistema. Dashboard, panel de alertas, pantalla de perfil. CI en GitHub Actions (`flutter analyze` + `flutter test` + paridad i18n en cada push).

En paralelo, la preparación necesaria ya quedó hecha en `diabecare-api`: IDs generados por el cliente en los 5 dominios offline-first, endpoints `/sync` de sincronización incremental para cada uno, y registro de tokens FCM (envío real pendiente — push notifications del cliente móvil quedan diferidas hasta que exista un proyecto Firebase real). La validación en vivo de Fase 3 encontró y corrigió 2 bugs reales preexistentes en el backend (ninguno introducido por el trabajo móvil): la re-invitación de un cuidador previamente revocado fallaba con un 500, y `/auth/sessions/{userId}`/`/auth/logout-all` estaban completamente rotos (NullPointerException) por un wildcard de seguridad demasiado amplio que los eximía del filtro JWT.

**Fase 5 (hardening del motor offline) encontró y corrigió un bug real y significativo**: el motor de sync solo se disparaba en la transición de sin-conexión a con-conexión — si la app se abría ya conectada y la conexión nunca parpadeaba, los cambios de otro dispositivo nunca se jalaban. Corregido agregando sync al arrancar la app (si ya hay conexión), al volver a primer plano, y justo después de login/registro — además de un guard de reentrancia (dos sync simultáneos ya no se pisan) y un guard de autenticación (nunca se intenta sincronizar sin sesión activa). Se auditó y confirmó por test que el cursor de sync incremental nunca avanza si un lote falla a mitad de camino, así que la app puede morir en cualquier momento sin perder ni duplicar datos.

Siguiente paso: Fase 6 (beta y publicación — TestFlight/Internal Testing, Fastlane, assets de store, declaraciones de privacidad, publicación). No se pudo probar la app en un emulador/dispositivo real en esta máquina en ningún momento del proyecto (sin Android SDK; iOS no se puede compilar desde Windows) — todos los contratos (auth, glucosa, nutrición, vitales, ejercicio, medicamentos, ciclo menstrual, reportes, cuidadores, cuenta, administración) se validaron en vivo contra el backend real vía `curl`, y el motor de sync se endureció a nivel de tests unitarios (dobles de conectividad/red), no de validación de campo en dispositivos de gama baja reales.

- **[`ARCHITECTURE.md`](./ARCHITECTURE.md)** — stack (Flutter + Riverpod + Drift + dio), arquitectura en capas, integración con el backend existente, motor de sincronización offline, estado real de los cambios en `diabecare-api`.
- **[`DESIGN_GUIDELINES.md`](./DESIGN_GUIDELINES.md)** — cómo lograr que la app se sienta nativa en Android (Material 3) e iOS (Human Interface Guidelines) sin perder la identidad de marca "Calm Health" ya establecida en la web.
- **[`ROADMAP.md`](./ROADMAP.md)** — fases de construcción hacia el release con paridad completa (decisión de producto: no se publica un MVP recortado, se secuencia el trabajo en fases internas hasta que todo esté listo).

---

## Por qué un repo separado

Mismo patrón que `diabecare-api`/`diabecare-web`: cada aplicación en su propio repositorio, sin monorepo. La app móvil consume la API REST existente sin necesitar acceso al código del backend ni del frontend web.

---

## Requisitos

- Flutter 3.x (canal stable)
- Xcode (build/firma iOS — requiere macOS; no se puede compilar para iOS desde Windows/Linux)
- Android Studio / Android SDK + un emulador o dispositivo (build/correr Android)
- Una instancia de `diabecare-api` corriendo (local o desplegada) para desarrollo

## Ejecución

```bash
flutter pub get
flutter analyze
flutter test
flutter run   # requiere un emulador/dispositivo conectado
```

---

*Ver `ARCHITECTURE.md` para el detalle técnico completo antes de empezar a escribir código.*
