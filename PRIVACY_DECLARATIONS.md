# Declaraciones de privacidad para las tiendas (Fase 6)

Referencia para completar **App Privacy** (App Store Connect) y **Data Safety**
(Google Play Console) — ninguna de las dos se puede llenar por API, son
formularios web dentro de cada consola de desarrollador. Este documento deja
las respuestas ya redactadas a partir de una auditoría real del código (no de
memoria ni de suposiciones), para que llenar esos formularios sea una tarea de
transcripción, no de investigación.

**Metodología**: se revisó `pubspec.yaml` (qué SDKs/paquetes hablan con
servidores externos), cada `*_api_client.dart` (qué endpoints de
`diabecare-api` llama el cliente), y el lado del backend para las pocas
llamadas que salen a un tercero real (Open Food Facts). Última revisión:
2026-07-12, contra el estado del repo tras Fase 0-5.

---

## 1. Hallazgo central: no hay SDKs de analítica, publicidad ni rastreo

`pubspec.yaml` no tiene Firebase Analytics, Crashlytics, Sentry, Mixpanel,
Amplitude, ni ningún SDK de publicidad. Todas las dependencias son: UI/estado
(Riverpod, go_router, fl_chart), almacenamiento local (Drift/sqlite3,
flutter_secure_storage, path_provider), red (dio, connectivity_plus), hardware
(flutter_blue_plus para el glucómetro BLE, mobile_scanner para códigos de
barra, local_auth para biometría), y utilidades (uuid, share_plus,
cupertino_icons). Esto simplifica mucho las 2 declaraciones: **no hay
rastreo para ningún propósito** (ni analítica de producto, ni publicidad).

## 2. Biometría — no se recolecta, no se transmite

`local_auth` delega el desbloqueo a Face ID/Touch ID/huella del sistema
operativo. La app nunca ve ni almacena datos biométricos crudos — solo recibe
un booleano ("autenticación exitosa/fallida") de la API del SO. En ambos
formularios esto se declara como **biometría no recolectada por la app**
(la app usa la biometría del dispositivo, no la suya propia).

## 3. Datos que sí recolecta y transmite la app (a `diabecare-api`, primera parte)

| Categoría (nomenclatura Apple/Google) | Datos concretos | Vinculado a la identidad | Con qué propósito |
|---|---|---|---|
| Contact Info / Datos de contacto | Email, nombre completo | Sí | Cuenta de usuario, autenticación |
| Health & Fitness / Salud y forma física | Glucosa, comidas/macros, signos vitales, ejercicio, medicamentos, ciclo menstrual, perfil de insulina | Sí | Funcionalidad principal de la app |
| User Content / Contenido de usuario | Campos de notas en los registros de salud | Sí | Funcionalidad principal de la app |
| Identifiers / Identificadores | ID de usuario, ID de paciente | Sí | Cuenta de usuario, autorización |
| Other Data / Otros datos | API keys de dispositivo (para bridges externos tipo Nightscout, generadas por el propio usuario) | Sí | Integración opcional con hardware externo, a pedido del usuario |

**No se recolecta**: ubicación, contactos, historial de navegación,
identificadores publicitarios, datos financieros/de pago, fotos/videos
(el escaneo de código de barras procesa el frame de cámara en el dispositivo
y solo extrae el código — no se sube ninguna imagen a ningún servidor).

## 4. Compartir con terceros

**No hay ningún SDK de tercero con acceso a datos del usuario.** La única
llamada de red que sale de la infraestructura propia (`diabecare-api`) es la
búsqueda de alimentos por código de barras contra **Open Food Facts** (API
pública y gratuita) — y esa llamada la hace el *backend*, no la app móvil
(`OpenFoodFactsAdapter.java`), enviando solo el código de barras/término de
búsqueda, sin ningún identificador de usuario ni dato de salud. Desde la
perspectiva de los formularios de las tiendas, esto **no cuenta como
"compartir datos del usuario con terceros"** porque ningún dato vinculado a
la identidad del usuario viaja a Open Food Facts.

## 5. Compartir con cuidadores (feature del producto, no un tercero externo)

Un paciente puede invitar a otra persona (cuidador) a ver, de forma
exclusivamente de solo lectura, su información básica, estadísticas de
glucosa y alertas — nunca el resto de los dominios de salud. Es una decisión
explícita del usuario (código de invitación), revocable en cualquier momento.
Esto se declara como **compartir controlado por el usuario dentro de la app**,
no como "compartido con terceros" en el sentido que exigen las tiendas (que
apunta a SDKs/empresas externas, no a otro usuario de la misma app).

## 6. Eliminación de cuenta y datos

Ambas tiendas exigen explicar cómo un usuario elimina su cuenta y datos desde
dentro de la app — ya implementado: `Cuenta → Eliminar cuenta`
(`AccountScreen`) desactiva el acceso de inmediato y elimina los datos de
salud de forma permanente 30 días después (con ventana de recuperación si el
usuario inicia sesión antes de ese plazo). Esto ya está descrito en la
política de privacidad (`legalPrivacyS6Body`, sección "Conservación y
eliminación de datos").

## 7. Notas para completar cada formulario

- **Apple (App Privacy, App Store Connect → App Information → App Privacy)**:
  marcar "Health & Fitness" y "Contact Info" como recolectados y vinculados a
  la identidad; "Diagnostics"/"Usage Data"/"Identifiers para publicidad" como
  **no recolectados**. Declarar la eliminación de cuenta in-app (obligatorio
  desde 2022).
- **Google (Data Safety, Play Console → App content → Data safety)**: mismo
  contenido, adaptado a las categorías de Google ("Health and fitness",
  "Personal info", "App activity" → ninguno). Google pide explícitamente
  declarar si los datos de salud se cifran en tránsito (sí, HTTPS/TLS) y en
  reposo (revisar con el equipo de backend qué usa Postgres/RDS en
  producción — este documento no cubre infraestructura de producción, que
  todavía no existe).
- **Ambos**: la política de privacidad pública ya existe en la app
  (`/legal/privacy`, ver Fase 5-6) y debe enlazarse desde la ficha de la
  tienda — pero **sigue marcada como borrador sin revisión legal**
  (`legalPrivacyDraftNotice`). Antes de publicar, alguien con criterio legal
  real debe revisarla; este documento no reemplaza esa revisión.
