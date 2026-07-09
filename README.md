# DiabeCare Mobile

Apps nativas para Android e iOS de DiabeCare — control de salud para pacientes diabéticos. Construidas con Flutter, con paridad completa de funcionalidades respecto a [`diabecare-web`](../diabecare-web) y soporte offline-first, consumiendo la misma API de [`diabecare-api`](../diabecare-api).

---

## Estado actual

**Repositorio recién creado — todavía sin código.** Este repo contiene por ahora la arquitectura, lineamientos de diseño y roadmap acordados antes de escribir la primera línea de Dart. Ver:

- **[`ARCHITECTURE.md`](./ARCHITECTURE.md)** — stack (Flutter + Riverpod + Drift + dio), arquitectura en capas, integración con el backend existente, motor de sincronización offline, cambios pendientes en `diabecare-api` para soportar el móvil.
- **[`DESIGN_GUIDELINES.md`](./DESIGN_GUIDELINES.md)** — cómo lograr que la app se sienta nativa en Android (Material 3) e iOS (Human Interface Guidelines) sin perder la identidad de marca "Calm Health" ya establecida en la web.
- **[`ROADMAP.md`](./ROADMAP.md)** — fases de construcción hacia el release con paridad completa (decisión de producto: no se publica un MVP recortado, se secuencia el trabajo en fases internas hasta que todo esté listo).

---

## Por qué un repo separado

Mismo patrón que `diabecare-api`/`diabecare-web`: cada aplicación en su propio repositorio, sin monorepo. La app móvil consume la API REST existente sin necesitar acceso al código del backend ni del frontend web.

---

## Requisitos (cuando arranque la implementación)

- Flutter 3.x (canal stable)
- Xcode (build/firma iOS — requiere macOS)
- Android Studio / Android SDK (build/firma Android)
- Una instancia de `diabecare-api` corriendo (local o desplegada) para desarrollo

---

*Ver `ARCHITECTURE.md` para el detalle técnico completo antes de empezar a escribir código.*
