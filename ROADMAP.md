# DiabeCare Mobile — Roadmap

> Decisión de producto: la app se **lanza con paridad completa** respecto a `diabecare-web`, no como un MVP recortado. Eso no significa construir todo en paralelo — significa que ninguna fase queda expuesta a usuarios reales hasta que todas estén completas. Las fases existen para secuenciar el trabajo de un equipo pequeño/solo, no para publicar releases intermedios.

---

## Fase 0 — Fundaciones (sin funcionalidad visible todavía)

La fase más importante para no tener que rehacer trabajo después. Nada de esto es negociable ni se puede saltar para "llegar más rápido" a pantallas visibles.

- [ ] Preparación en `diabecare-api` (ver `ARCHITECTURE.md` sección 3.3):
  - IDs generados por el cliente aceptados en creación (glucosa, comidas, signos vitales, ejercicio)
  - `MobilePushTokenPort` + adaptador FCM, en paralelo al `PushSubscriptionPort` de Web Push existente
  - Parámetro `updatedSince` en endpoints de listado para sincronización incremental
  - Revisión de idempotencia en endpoints de escritura
- [ ] Setup del proyecto Flutter: estructura de carpetas (`ARCHITECTURE.md` sección 2), lint rules, CI (`flutter analyze` + `flutter test` en cada push)
- [ ] Design system base: `ThemeData` claro/oscuro con los tokens de marca, widgets adaptativos fundacionales (`platform_action_sheet`, botones, inputs, diálogos de confirmación)
- [ ] Auth: login, registro, refresh automático, logout, guardado seguro de tokens (`flutter_secure_storage`), bloqueo biométrico opcional
- [ ] Motor de sync offline — el mecanismo (outbox, esquema Drift base, `SyncService` con reintentos/backoff), todavía sin datos de dominio reales conectados
- [ ] Script de generación de ARB desde `es.json`/`en.json`

**Criterio de salida de esta fase**: se puede hacer login, la app mantiene sesión, el tema se ve correcto en modo claro/oscuro en ambas plataformas, y existe un mecanismo de sync que se puede probar con datos dummy.

---

## Fase 1 — Núcleo clínico

- [ ] Glucosa: registro (incl. conexión Bluetooth con glucómetro, reutilizando el mismo Glucose Service estándar ya implementado en `diabecare-web`), historial, estadísticas TIR/HbA1c/CV, perfil AGP
- [ ] Dashboard: métricas, alertas, accesos rápidos
- [ ] Alertas clínicas completas (7 tipos + patrones + ciclo)
- [ ] Push notifications conectadas (FCM ya preparado en Fase 0)
- [ ] Offline-first real para glucosa (primer dominio conectado al motor de sync)

**Criterio de salida**: un paciente puede vivir en la app solo con este subconjunto sin sentir que le falta algo crítico — es intencionalmente el corazón funcional de la app.

---

## Fase 2 — Registro diario

- [ ] Nutrición: registro de comidas, buscador de alimentos, escaneo de código de barras (OpenFoodFacts)
- [ ] Signos vitales y ejercicio
- [ ] Medicamentos: CRUD, recordatorios automáticos por frecuencia
- [ ] Calculadora de insulina
- [ ] Offline-first extendido a estos dominios

---

## Fase 3 — Funcionalidades clínicas y sociales avanzadas

- [ ] Ciclo menstrual (registro día a día, fases, correlación glucémica)
- [ ] Reportes PDF
- [ ] Cuidadores (invitar, canjear código, vista de solo lectura)
- [ ] Recuperación de contraseña
- [ ] Gestión de cuenta: exportar datos, suspender/eliminar, sesiones activas, API keys de dispositivo (tab "Dispositivos")

---

## Fase 4 — Administración, i18n y accesibilidad

- [ ] Panel de administración (rol ADMIN)
- [ ] Auditoría de paridad i18n (script de Fase 0 corriendo en CI, falla el build si es/en divergen)
- [ ] Auditoría de accesibilidad completa (VoiceOver + TalkBack en cada pantalla, Dynamic Type, contraste)

---

## Fase 5 — Hardening del motor offline

Fase dedicada porque es la parte con más superficie de bugs sutiles y la más cara de arreglar después del lanzamiento (bugs de sincronización = datos de salud perdidos o duplicados, el peor tipo de bug posible en esta app).

- [ ] Pruebas exhaustivas de conflictos (edición concurrente multi-dispositivo)
- [ ] Pruebas con conectividad intermitente real (no solo "online" vs "avión") — `connectivity_plus` + escenarios de red lenta/inestable
- [ ] Pruebas en dispositivos de gama baja (Android especialmente — fragmentación de hardware mucho mayor que iOS)
- [ ] Auditoría de qué pasa si la app se cierra a la mitad de una sincronización

---

## Fase 6 — Beta y publicación

- [ ] TestFlight (iOS) + Internal/Closed Testing (Google Play) con un grupo reducido de usuarios reales
- [ ] Fastlane: lanes de build + firma + subida automatizada
- [ ] Assets de store: screenshots (por tamaño de dispositivo requerido en cada store), descripción, política de privacidad pública
- [ ] **App Privacy details (Apple)** y **Data Safety form (Google Play)** — declaraciones obligatorias de qué datos se recolectan y para qué; dado que es una app de salud, revisar esto con cuidado particular, son de los primeros puntos que un revisor de cualquiera de las dos stores va a escrutar
- [ ] Publicación

---

## Fuera de alcance (explícitamente, por ahora)

- Integración directa con Dexcom API / Terra / cualquier fabricante específico de CGM — sigue dependiendo de la decisión de negocio ya documentada en la investigación previa del proyecto, no de la app móvil en sí.
- Apple Watch / Wear OS companion apps.
- Widgets de pantalla de inicio (home screen widgets) — candidato natural para una versión posterior, no bloqueante para el release inicial.
