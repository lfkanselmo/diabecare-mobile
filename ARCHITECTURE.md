# DiabeCare Mobile — Arquitectura

> Apps nativas para Android e iOS, construidas con Flutter, con paridad completa de funcionalidades respecto a `diabecare-web` desde el primer release, y soporte offline-first.

---

## 1. Decisiones de stack

| Decisión | Elección | Por qué |
|---|---|---|
| Framework | **Flutter 3.x** (Dart) | Un solo codebase para Android + iOS, rendimiento cercano a nativo (compila a ARM), soporte de primera clase para Material 3 y un soporte razonable de Cupertino (iOS) |
| Gestión de estado | **Riverpod 2.x** (con `riverpod_generator`) | Compile-safe, testeable sin `BuildContext`, `AsyncNotifier` encaja naturalmente con el patrón "cache local + sync" que exige offline-first |
| Navegación | **go_router** | Paquete oficial del equipo de Flutter, navegación declarativa, deep-linking, transiciones adaptativas por plataforma |
| Base de datos local | **Drift** (SQL tipado sobre SQLite) | El dominio es relacional (glucosa, comidas, medicamentos, cuidadores con FKs) — encaja mejor que una NoSQL como Isar/ObjectBox. Streams reactivos se integran directo con Riverpod. Migraciones explícitas, mismo espíritu que Flyway en el backend |
| Cliente HTTP | **dio** | Estándar de facto en Flutter, soporta interceptors — replica exactamente el patrón ya usado en `diabecare-web` (JWT, refresh automático, Accept-Language, loading state) |
| Auth storage | **flutter_secure_storage** | Keychain en iOS, EncryptedSharedPreferences/Keystore en Android |
| Biometría | **local_auth** | Face ID / Touch ID / huella — bloqueo de app adicional dado que son datos de salud sensibles (nuevo respecto al web, justificado por el contexto móvil) |
| Push notifications | **Firebase Cloud Messaging (FCM)** | Unifica APNs (iOS) y push nativo de Android bajo una sola integración de backend |
| i18n | **`intl` + ARB generados desde `es.json`/`en.json`** | Reutiliza las mismas claves que ya mantiene `diabecare-web` en vez de duplicar traducciones — ver sección 9 |
| Testing | **flutter_test + mocktail + integration_test/Patrol** | `mocktail` en vez de `mockito` porque no requiere codegen, coherente con el estilo de tests ya usado en el backend (Mockito) y frontend (mocks manuales) |
| CI/CD | **GitHub Actions + Fastlane** | Mismo patrón que `diabecare-api`/`diabecare-web` (`.github/workflows/ci.yml`), extendido con lanes de Fastlane para firma y subida a stores |

**No elegido y por qué:**
- **React Native**: se consideró por compartir TypeScript con `diabecare-web`, pero el equipo definió Flutter como preferencia explícita.
- **Nativo dual (Swift + Kotlin)**: descartado — duplicaría el esfuerzo de desarrollo permanentemente, inviable para un equipo pequeño/solo.
- **Bloc/Cubit** (en vez de Riverpod): alternativa válida, más explícita para máquinas de estado complejas (el motor de sync es un buen candidato), pero Riverpod con `AsyncNotifier` cubre el mismo caso con menos boilerplate. Si el motor de sincronización termina necesitando estados más explícitos de los que `AsyncNotifier` maneja con soltura, migrar esa pieza puntual a Bloc es una opción de fallback razonable, no un rediseño completo.

---

## 2. Arquitectura en capas

Mismo espíritu que la arquitectura hexagonal del backend (`domain` sin dependencias de framework, `application` orquesta, `infrastructure` implementa detalles) — adaptado a la forma habitual de organizar un app Flutter grande:

```
lib/
├── core/                        # Transversal a toda la app
│   ├── network/                 # Dio + interceptors (auth, refresh, language, logging)
│   ├── storage/                 # SecureStorage wrapper, Drift database instance
│   ├── theme/                   # ColorScheme, tipografía, tokens compartidos con web
│   ├── router/                  # go_router config, guards de auth
│   ├── sync/                    # Motor de sincronización offline (ver sección 4)
│   └── l10n/                    # ARB generados + helpers de idioma
│
├── features/
│   │   # Un directorio por feature, cada uno con sus 3 capas internas:
│   └── glucose/
│       ├── domain/              # Entities (Dart puro, sin Flutter/Drift/dio)
│       │   ├── entities/        #   GlucoseReading, GlucoseUnit, ReadingType...
│       │   └── repositories/     #  Interfaces abstractas (GlucoseRepository)
│       ├── data/                # Implementaciones concretas
│       │   ├── local/           #   Drift DAOs + tablas
│       │   ├── remote/          #   Llamadas a la API REST (dio)
│       │   └── repository_impl/ #  Implementa la interfaz de domain/,
│       │                        #  decide local-first + encola cambios pendientes
│       └── presentation/        # UI
│           ├── providers/       #   Riverpod providers/notifiers
│           ├── screens/         #   Pantallas completas
│           └── widgets/         #   Componentes reutilizables de la feature
│
├── shared/                      # Widgets/modelos compartidos entre features
│   ├── widgets/                 # Design system: botones, cards, inputs adaptativos
│   └── models/                  # DTOs compartidos (PageResponse, ApiError, etc.)
│
└── main.dart
```

**Regla de dependencia** (igual que en el backend): `domain/` no importa nada de `data/` ni de Flutter — solo Dart puro. `presentation/` no accede a Drift ni a dio directamente, solo a través de las interfaces de `domain/repositories/` vía Riverpod. Esto se puede verificar con el paquete `flutter_lints` + una regla custom o con `import_lint`/`dart_code_metrics` en CI, replicando lo que ArchUnit hace en el backend — vale la pena configurarlo desde el día uno del proyecto, no como una limpieza posterior.

Cada feature del backend mapea 1:1 a un feature del móvil: `glucose`, `nutrition`, `vitals`, `medications`, `exercise`, `alerts`, `menstrual_cycle`, `reports`, `profile`, `caregivers`, `admin`, `auth`, `legal`.

---

## 3. Integración con el backend existente

La API REST ya construida (`diabecare-api`) se reutiliza sin cambios de contrato para la mayoría de los endpoints — mismo JWT + refresh token rotable que ya usa `diabecare-web`.

### 3.1 Cliente HTTP y auth

```dart
final dio = Dio(BaseOptions(baseUrl: Env.apiUrl))
  ..interceptors.addAll([
    AuthInterceptor(secureStorage),      // agrega Authorization: Bearer <token>
    RefreshInterceptor(authRepository),  // 401 -> refresh automático + reintento,
                                          // usa un Completer compartido para no
                                          // disparar refrescos concurrentes duplicados
                                          // (mismo problema que TokenRefreshCoordinator
                                          // ya resuelve en diabecare-web)
    LanguageInterceptor(localeProvider),  // Accept-Language
    LoggingInterceptor(),                 // solo en debug
  ]);
```

### 3.2 Autenticación biométrica (nuevo respecto al web)

El JWT/refresh token se guardan en `flutter_secure_storage` tras el login normal (mismo flujo que ya existe). Adicionalmente, la app puede configurarse para exigir Face ID/Touch ID/huella (`local_auth`) cada vez que vuelve a primer plano después de cierto tiempo en background — una capa de protección que no existe en el web y que se justifica por tratarse de datos de salud en un dispositivo que puede perderse o ser robado. Esto es una decisión de producto (¿opcional u obligatoria?) a definir antes de implementar, no una decisión puramente técnica.

### 3.3 Cambios necesarios en el backend

Estado real a la fecha (2026-07-09) — implementado en `diabecare-api`:

1. **IDs generados por el cliente — ✅ hecho**, para las 4 entidades creables offline: `GlucoseReading`, `MealEntry`/`MealItem`, `VitalSign`, `ExerciseLog`. Cada `create(...)` estático ahora delega a un `createWithId(id, ...)` que honra un UUID explícito; los use cases de registro aceptan un `clientXxxId` opcional en su `Command`, y los controllers lo exponen como campo opcional en el request (`readingId`, `mealId`/`mealItemId`, `vitalId`, `exerciseId`). Si no se envía, el servidor genera el ID como siempre (compatibilidad total con el frontend web, que no lo envía). Reenviar el mismo ID es idempotente por construcción (JPA `save()` sin `@GeneratedValue` hace upsert por ID).
2. **Registro de tokens FCM — ✅ hecho.** `MobilePushTokenPort`/`MobilePushTokenPersistenceAdapter`, paralelo a `PushSubscriptionPort`. Endpoints `POST`/`DELETE /api/v1/push/mobile-token`. `PushNotificationService.sendToPatient` ya itera ambos canales (Web Push + móvil), pero el envío FCM real está **deliberadamente sin implementar** — se degrada igual que `ResendEmailAdapter` sin API key (loguea cuántos dispositivos no se notificaron y sigue) porque no existe todavía un proyecto de Firebase real. Implementar el envío real (JWT firmado con la service account + FCM HTTP v1 API, mismo patrón `java.net.http` que el resto del proyecto) es la tarea pendiente concreta antes de que las notificaciones push lleguen de verdad al móvil.
3. **Endpoints de sincronización incremental — parcialmente hecho.** Se optó por un endpoint `/sync` dedicado por recurso (no reutilizar `/history`, que pagina por fecha de *medición* para la UI web — mezclarlo con un cursor de *modificación* habría sido confuso). Implementado solo para **glucosa** (`GET /api/v1/glucose/{patientId}/sync?since=<opcional>`), porque es el primer dominio de la Fase 1 del roadmap. Meals/vitals/exercise usan el mismo patrón exacto (repo query `findByPatientIdAndUpdatedAtAfterOrderByUpdatedAtAsc` + puerto + use case `SyncXxxUseCase` + controller) — replicarlo cuando la Fase 2 (nutrición, vitales, ejercicio) empiece, no antes.
4. **Idempotencia en escrituras — cubierta por el punto 1** (ID generado por el cliente + `save()` upsert). No se encontró necesidad de un mecanismo adicional de idempotencia más allá de eso.

Todos los tests nuevos pasan (1081 tests totales en `diabecare-api` a la fecha), suite completa verificada tras cada cambio.

---

## 4. Offline-first: motor de sincronización

### 4.1 Principio general

El backend (Postgres vía REST) es la fuente de verdad. La base de datos local (Drift/SQLite) es una **caché reactiva + outbox de escritura**, no una copia independiente.

### 4.2 Esquema local

Cada tabla que soporta creación offline agrega, además de las columnas propias del dominio:

```
sync_status   TEXT   -- 'synced' | 'pending_create' | 'pending_update' | 'pending_delete'
local_updated_at  DATETIME
server_updated_at DATETIME NULL   -- null hasta la primera sincronización exitosa
```

### 4.3 Flujo de escritura offline

1. El usuario registra una lectura de glucosa sin conexión.
2. Se inserta localmente con un UUID generado en el cliente, `sync_status = 'pending_create'`. La UI la muestra de inmediato (con un indicador visual sutil de "pendiente de sincronizar").
3. El `SyncService` (corre en background vía `workmanager` en Android / `BGTaskScheduler` en iOS, y también se dispara al detectar reconexión con `connectivity_plus`) recorre el outbox en orden y hace `POST`/`PATCH`/`DELETE` contra la API.
4. Al confirmar éxito, `sync_status = 'synced'` y se guarda `server_updated_at`.
5. Si falla por error de red, reintenta con backoff exponencial. Si falla por un error de validación real (4xx que no sea de red), se marca como `sync_error` y se expone en una pantalla de "elementos con problemas de sincronización" — nunca se descarta silenciosamente un dato de salud.

### 4.4 Flujo de lectura / pull

Al reconectar (o cada N minutos en foreground), el `SyncService` pide a cada endpoint `updatedSince=<último cursor>` y hace upsert local de lo que vuelva, actualizando el cursor solo si la respuesta se procesó completa.

### 4.5 Resolución de conflictos

El dominio de DiabeCare es mayormente **append-only**: una lectura de glucosa, una comida o una sesión de ejercicio casi nunca se edita después de creada, y cuando se edita es por el mismo usuario en un solo dispositivo a la vez — el escenario de conflicto real (dos dispositivos editando el mismo registro en la ventana offline) es raro pero no imposible (ej. un paciente con la app en tablet y en celular). Estrategia:

- **Creates**: no hay conflicto posible (IDs generados por el cliente, únicos).
- **Updates/deletes**: last-write-wins por `server_updated_at`, con una excepción — si el servidor detecta que el registro cambió desde la última vez que el cliente lo vio (comparando el timestamp que el cliente cree que es el vigente contra el real), se resuelve a favor del servidor y se notifica al usuario que su edición offline no se aplicó, en vez de sobreescribir silenciosamente.

### 4.6 Qué NO es offline-first en el v1

Funcionalidades que dependen intrínsecamente de estar online no tienen sentido offline y no se fuerzan: generación de reportes PDF, exportación de datos de cuenta, invitaciones de cuidador, panel de administración, autenticación inicial. El offline-first aplica al **registro de datos clínicos** (glucosa, comidas, signos vitales, ejercicio, medicamentos tomados) y su **lectura** (dashboard, historial), que es donde realmente importa que un paciente sin señal pueda seguir usando la app.

---

## 5. Notificaciones push

- **Backend**: FCM Admin SDK, nuevo `MobilePushTokenPort` (ver sección 3.3).
- **Cliente**: `firebase_messaging` — registra el token FCM al iniciar sesión, lo re-registra si Firebase lo rota, maneja notificaciones en foreground/background/terminated.
- **Contenido**: mismas notificaciones que ya existen (resumen semanal, alertas, recordatorios de glucosa/medicamentos) — el backend ya tiene toda la lógica de "cuándo notificar", solo se le agrega un segundo canal de entrega.

---

## 6. Testing

| Nivel | Herramienta | Qué cubre |
|---|---|---|
| Unitario | `flutter_test` + `mocktail` | Entities, use cases, repositorios (mockeando data sources) |
| Widget | `flutter_test` (`WidgetTester`) | Componentes de UI aislados, incluida la variante Android vs iOS de widgets adaptativos |
| Integración | `integration_test` + Patrol | Flujos completos (login → registrar glucosa → ver en historial), en simulador/emulador |
| Sync offline | Unitario, con un fake `Dio` (`DioAdapter` de `http_mock_adapter`) | Casos de conflicto, reintentos, backoff — es la parte más propensa a bugs sutiles, merece la cobertura más alta del proyecto |

---

## 7. CI/CD

Nuevo `.github/workflows/ci.yml` en este repo, mismo patrón que los otros dos:

```yaml
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      - run: flutter test --coverage
```

Build y firma de release (APK/AAB firmado, IPA) van en un workflow separado, disparado por tags (`v*`), usando Fastlane (`fastlane/Fastfile` con lanes `android_release`/`ios_release`) — separar CI (rápido, en cada push) de release (lento, requiere secretos de firma) es intencional, mismo principio que ya se sigue en `diabecare-api` (el build de imagen Docker corre en cada push porque es barato; un despliegue real no).

---

## 8. Seguridad específica de móvil

- Biometría como capa adicional de bloqueo de app (sección 3.2).
- `flutter_secure_storage` para tokens — nunca `shared_preferences` plano.
- Certificate pinning opcional para las llamadas a la API (evaluar costo/beneficio — protege contra MITM en redes públicas, pero complica la rotación de certificados del backend).
- Detección básica de root/jailbreak (`flutter_jailbreak_detection` o similar) — decisión de producto pendiente: ¿bloquear el uso en dispositivos rooteados, o solo advertir? Dado que es una app de salud, no de pagos, un bloqueo duro puede ser excesivo; una advertencia suave es probablemente suficiente.
- Igual que el backend ya hace rate limiting por IP para login/registro, considerar rate limiting local (cooldown visual) en el intento de biometría fallida repetida.

---

## 9. Internacionalización

`diabecare-web` mantiene `es.json`/`en.json` con paridad estricta verificada en cada cambio (591 claves a la fecha). En vez de mantener un tercer set de traducciones desconectado, se genera el `.arb` de Flutter a partir de esos mismos JSON como paso de build (script simple: JSON anidado → claves planas `feature_subfeature_key` que es la convención de ARB). Esto significa que una traducción nueva se escribe una sola vez y se propaga a los tres frontends (web ya existente, Android, iOS) — vale la pena escribir ese script de conversión como una de las primeras tareas del proyecto, antes de que las traducciones diverjan entre plataformas.

---

*DiabeCare Mobile Architecture v1.0 — documento vivo, actualizar conforme el proyecto avance*
