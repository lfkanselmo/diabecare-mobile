# DiabeCare Mobile

Apps nativas para Android e iOS de DiabeCare — control de salud para pacientes diabéticos. Construidas con Flutter, con paridad completa de funcionalidades respecto a [`diabecare-web`](../diabecare-web) y soporte offline-first, consumiendo la misma API de [`diabecare-api`](../diabecare-api).

---

## Estado actual

**Fase 0 en progreso.** Proyecto Flutter scaffoldeado (`flutter create`), estructura de carpetas por feature ya creada (ver `lib/`), dependencias base instaladas (Riverpod, go_router, Drift, dio, flutter_secure_storage, local_auth, connectivity_plus), tema Material 3 con los tokens de marca "Calm Health", CI en GitHub Actions (`flutter analyze` + `flutter test` en cada push). Ninguna pantalla real todavía — solo un placeholder en `/`.

En paralelo, la preparación necesaria ya quedó hecha en `diabecare-api`: IDs generados por el cliente, registro de tokens FCM (envío real pendiente), y el primer endpoint de sincronización incremental (`/glucose/{patientId}/sync`).

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
