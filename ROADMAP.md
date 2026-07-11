# DiabeCare Mobile — Roadmap

> Decisión de producto: la app se **lanza con paridad completa** respecto a `diabecare-web`, no como un MVP recortado. Eso no significa construir todo en paralelo — significa que ninguna fase queda expuesta a usuarios reales hasta que todas estén completas. Las fases existen para secuenciar el trabajo de un equipo pequeño/solo, no para publicar releases intermedios.

---

## Fase 0 — Fundaciones (sin funcionalidad visible todavía)

La fase más importante para no tener que rehacer trabajo después. Nada de esto es negociable ni se puede saltar para "llegar más rápido" a pantallas visibles.

- [x] Preparación en `diabecare-api` (ver `ARCHITECTURE.md` sección 3.3):
  - IDs generados por el cliente aceptados en creación (glucosa, comidas, signos vitales, ejercicio)
  - `MobilePushTokenPort` + adaptador FCM, en paralelo al `PushSubscriptionPort` de Web Push existente
  - Endpoint `/sync` dedicado para sincronización incremental (glucosa; el resto de dominios lo replica en su fase)
  - Idempotencia en escrituras cubierta por los IDs generados por el cliente
- [x] Setup del proyecto Flutter: estructura de carpetas (`ARCHITECTURE.md` sección 2), lint rules, CI (`flutter analyze` + `flutter test` en cada push)
- [x] Design system base: `ThemeData` claro/oscuro con los tokens de marca, widgets adaptativos fundacionales (`platform_action_sheet`, botón/input de marca, diálogo de confirmación adaptativo, date picker adaptativo)
- [x] Auth: login, registro, refresh automático (con rotación de refresh token y single-flight coordinado), logout, guardado seguro de tokens (`flutter_secure_storage`), bloqueo biométrico opcional (toggle apagado por defecto — la UI del toggle llega con la pantalla de perfil en una fase posterior)
- [x] Motor de sync offline — el mecanismo (`AppDatabase` Drift base, `SyncService`/`SyncableRepository` con reintentos/backoff exponencial), probado con un repositorio y un `Dio` fake; todavía sin dominio real conectado (glucosa lo conecta en Fase 1)
- [x] Script de generación de ARB desde `es.json`/`en.json` (591 claves, `tool/generate_arb.dart`)

**Criterio de salida de esta fase — cumplido**: login/registro funcionan contra el backend real (validado en vivo por curl: registro, login, refresh con rotación, detección de reuso, logout, forgot-password anti-enumeración — todos devuelven exactamente el contrato esperado), la sesión persiste en `flutter_secure_storage`, el tema se ve correcto en modo claro/oscuro, y el motor de sync tiene cobertura de tests unitarios (éxito, reintento con backoff, error de validación permanente, agotamiento de reintentos).

**Pendiente de verificación** (no se pudo hacer en esta máquina — sin Android SDK/emulador ni posibilidad de compilar iOS desde Windows): correr la app real en un dispositivo/emulador. `flutter analyze` y `flutter test` sí corrieron localmente y en verde (ver CI).

---

## Fase 1 — Núcleo clínico

- [x] Glucosa: registro (incl. conexión Bluetooth con glucómetro, mismo protocolo Glucose Service estándar que `diabecare-web` — parsing testeado, flujo de conexión real sin verificar por falta de hardware), historial, estadísticas TIR/HbA1c/CV, perfil AGP
- [x] Dashboard: glucosa + alertas + acceso rápido a registro (nutrición/vitales/ciclo se agregan cuando esos dominios existan, Fase 2/3 — no se construyeron accesos a pantallas que no existen todavía)
- [x] Alertas clínicas: panel conectado a `/alerts` (los 5 detectores ya implementados en el backend, sin cambios) — sin polling, igual que la web
- [ ] Push notifications conectadas — **diferido**: el backend no tiene un proyecto de Firebase real (`sendToMobileDevices` es un no-op deliberado), construir el cliente FCM ahora ni siquiera compilaría (falta `google-services.json`). Se retoma cuando exista un proyecto Firebase real.
- [x] Offline-first real para glucosa (primer dominio conectado al motor de sync de Fase 0: `GlucoseReadings` en Drift, `GlucoseRepositoryImpl` implementa `SyncableRepository`, pull incremental vía `/sync` + cursor en `SyncCursors`)

**Validado en vivo contra el backend real** (curl): registro con ID de cliente (idempotente confirmado — reenviar el mismo `readingId` no duplica), `/sync`, `/latest`, `/stats`, `/agp-profile`, `/alerts`, `DELETE` — todos los DTOs de Dart coinciden exactamente. Simplificación deliberada: el historial no muestra marcadores de comida/ejercicio (dependen de dominios que no existen en el móvil todavía, Fase 2) — la app confía enteramente en la caché local (Drift) poblada por `/sync`, nunca llama a `/history` directamente.

**Criterio de salida**: un paciente puede vivir en la app solo con este subconjunto sin sentir que le falta algo crítico — es intencionalmente el corazón funcional de la app.

---

## Fase 2 — Registro diario

- [x] Nutrición: registro de comidas, buscador de alimentos, escaneo de código de barras (OpenFoodFacts)
- [x] Signos vitales y ejercicio
- [x] Medicamentos: registro/desactivación, recordatorios automáticos por frecuencia (100% push server-side, sin CRUD de horarios en el cliente)
- [x] Calculadora de insulina + perfil de insulina
- [x] Offline-first extendido a estos dominios (`MealEntries`/`VitalSigns`/`ExerciseLogs`/`Medications` en Drift, los 4 repositorios implementan `SyncableRepository`, pull incremental vía `/sync` + cursor en `SyncCursors`)

**Preparación de backend**: se replicó el patrón `/sync` de glucosa (Fase 1) en los 4 dominios nuevos — ninguno lo tenía. `Medication` ganó `createWithId` (no existía soporte de ID generado por el cliente). Se detectó y corrigió un gap real: `MealEntry`/`VitalSign`/`ExerciseLog` nunca exponían `updatedAt` en sus domain models/responses (a diferencia de glucosa/medicamentos) — necesario para que `pullChanges()` pueble `serverUpdatedAt` localmente.

**Validado en vivo contra el backend real** (curl): registro con ID de cliente (idempotente), `/sync` con `updatedAt`, desactivación de medicamentos (incluida en `/sync`, no solo en el listado de activos), perfil de insulina (`PATCH /patients/{id}/insulin-profile`), calculadora (`POST /insulin/{id}/calculate`, incluye el caso "perfil no configurado"), búsqueda de alimentos y lookup por código de barras — todos los DTOs de Dart coinciden exactamente.

**Simplificación deliberada** (consistente con Fase 1): catálogos de metadata (tipos de comida/ejercicio/medicamento, unidades de dosis, frecuencias) son enums Dart estáticos con `wireValue`, no el `MetadataService` completo de la web (15 endpoints) — las etiquetas siguen siendo el `wireValue` crudo, no una traducción.

---

## Fase 3 — Funcionalidades clínicas y sociales avanzadas

- [x] Ciclo menstrual (registro día a día, fases, correlación glucémica)
- [x] Reportes PDF
- [x] Cuidadores (invitar, canjear código, vista de solo lectura)
- [x] Recuperación de contraseña — **ya estaba completa desde Fase 0** (`ForgotPasswordScreen`/`ResetPasswordScreen`), este ítem quedó marcado por error al planear la fase
- [x] Gestión de cuenta: exportar datos, suspender/eliminar, sesiones activas, API keys de dispositivo (pantalla de perfil nueva con tab "Dispositivos")

Ninguno de estos dominios necesita offline-first — a diferencia de Fase 1/2, acá todo se calcula server-side y se consulta en vivo (mismo patrón que stats/AGP de glucosa): no hay tablas Drift nuevas, no hay `SyncableRepository`.

**Bugs reales encontrados y corregidos durante la validación en vivo** (ninguno introducido por este trabajo, ambos preexistentes en `diabecare-api`):
1. Re-invitar a un cuidador previamente revocado fallaba con un error 500 (violación de la restricción de unicidad `(patientId, caregiverUserId)`) — `RedeemCaregiverInviteUseCaseImpl` intentaba crear un vínculo nuevo en vez de reactivar el existente.
2. `GET /auth/sessions/{userId}` y `POST /auth/logout-all` estaban rotos para cualquier cliente real (siempre tiraban NullPointerException) — el wildcard `/api/v1/auth/**` en `PublicEndpoints` eximía a estos 2 endpoints autenticados del filtro JWT. Se reemplazó por la lista explícita de los 6 endpoints realmente públicos. Confirmado que la web también los usa (nunca funcionaron ahí tampoco).

**Validado en vivo contra el backend real** (curl): ciclo completo (registrar período, registrar día con síntomas, finalizar período, calendario de fases, todo con `Accept-Language: es` confirmando labels traducidos), reporte PDF (contenido válido verificado), invitar/canjear/revocar/re-invitar cuidador, vista de solo lectura del cuidador sobre el paciente (info + stats de glucosa + alertas), exportar datos, sesiones activas, logout-all (con verificación de que el refresh token queda invalidado), generar/listar API keys de dispositivo.

**Simplificación deliberada**: la vista de solo lectura del cuidador reutiliza directamente `GlucoseApiClient`/`Alert.fromJson`/`AlertsPanel`/`GlucoseStatsCard` ya existentes (llamando a los endpoints con un `patientId` explícito en vez del de la sesión propia) en lugar de duplicar esa lógica — mismo alcance que `caregiver-view.component.ts` de la web (no es un espejo completo de la app, ni en la web).

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
