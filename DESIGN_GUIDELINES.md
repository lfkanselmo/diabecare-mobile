# DiabeCare Mobile — Lineamientos de Diseño

> Objetivo: que la app se sienta **nativa** en cada plataforma (Material 3 en Android, Human Interface Guidelines en iOS) manteniendo la **identidad de marca** "Calm Health" ya establecida en `diabecare-web`. Consistencia de marca, no de widgets — el color y el tono son los mismos en las tres plataformas; la forma en que el usuario navega, confirma y desliza sigue las reglas de cada sistema operativo.

---

## 1. Principio rector: adaptativo, no genérico

Un error común al portar una app web a móvil es renderizar los mismos componentes en Android y iOS. Eso rompe la expectativa del usuario en ambas plataformas a la vez. La regla de este proyecto:

- **Color, tipografía de marca, iconografía de producto, tono de voz**: idénticos en Android e iOS (y en la web).
- **Navegación, gestos, diálogos, controles de formulario, feedback háptico**: siguen la convención nativa de cada plataforma, incluso si eso significa que un mismo flujo se ve distinto en Android vs iOS.

Flutter permite esto con widgets `.adaptive` (`Switch.adaptive`, `Slider.adaptive`, `showAdaptiveDialog`) y con un chequeo `Platform.isIOS` centralizado en un solo lugar (`shared/widgets/platform/`) — nunca disperso por las pantallas de features.

```dart
// shared/widgets/platform/platform_action_sheet.dart
Future<T?> showPlatformActionSheet<T>(BuildContext context, List<PlatformAction> actions) {
  return Platform.isIOS
      ? showCupertinoModalPopup<T>(context: context, builder: (_) => _iosActionSheet(actions))
      : showModalBottomSheet<T>(context: context, builder: (_) => _materialActionSheet(actions));
}
```

---

## 2. Tokens de marca (compartidos con `diabecare-web`)

Estos valores son la fuente de verdad ya establecida en `diabecare-web/src/styles/_palette.scss` y `_tokens.scss` — se traducen a un `ColorScheme`/`ThemeData` de Flutter, no se reinventan.

### 2.1 Color de marca

| Token | Claro | Oscuro | Uso |
|---|---|---|---|
| `primary` | `#5B4FCF` | `#9588ED`* | Acciones principales, navegación activa |
| `success` | `#22A96A` | `#4ADE98` | Glucosa en rango, metas cumplidas |
| `warning` | `#E8A020` | `#FABD4A` | Glucosa alta, variabilidad alta |
| `danger` | `#E04B4B` | `#F07070` | Hipoglucemia, errores |
| `info` | `#0EA5A0` | — | Información secundaria |

\* Valor exacto de `$color-primary-dark-mode` a confirmar contra `_palette.scss` al implementar — usar el mismo, no aproximar.

### 2.2 Estados clínicos de glucosa (críticos — no reinterpretar)

```
critically-low   #9B1D6A  (dark: #F48FB1)
low              #E04B4B  (dark: #F07070)
normal           #22A96A  (dark: #4ADE98)
high             #E8A020  (dark: #FABD4A)
critically-high  #BF360C  (dark: #FF8A65)
```

Estos 5 colores son clínicamente significativos — el mismo color debe significar lo mismo en las tres plataformas sin excepción. No aplican reglas de "adaptación por plataforma" aquí.

### 2.3 Tipografía

- Familia de marca: **Inter** (misma que la web) para texto de producto/branding.
- **Excepción deliberada**: los controles de navegación y componentes de sistema (barra de navegación, tab bar, alertas nativas) usan la tipografía del sistema de cada plataforma (San Francisco en iOS, Roboto/system font en Android) — no fuerces Inter ahí, rompe la sensación nativa y además Cupertino/Material ya asumen su propia fuente en el cálculo de line-height de esos componentes.
- Escala: reutilizar los tamaños ya definidos (`--font-size-xs` 12 → `--font-size-2xl` 28, `--font-size-metric` 36 para las métricas grandes del dashboard) como puntos de partida, ajustados a `TextTheme` de Flutter.
- **Dynamic Type (iOS) / escalado de fuente del sistema (Android)**: todo texto debe escalar con `MediaQuery.textScaler` — nunca usar tamaños de fuente hardcodeados en `px` que ignoren la preferencia de accesibilidad del usuario. Esto es un requisito de Apple para pasar revisión de App Store, no solo una buena práctica.

### 2.4 Espaciado y radios

Reusar la escala existente sin cambios: `space-1` (4px) a `space-16` (64px); `radius-sm` (6px) a `radius-full`. Un `radius-lg` (14px) para cards funciona igual de bien en Material 3 (que ya usa esquinas redondeadas generosas) como en iOS (que también ha migrado a esquinas más suaves en HIG reciente) — es una de las pocas áreas donde ambas plataformas convergen sin necesidad de adaptar nada.

---

## 3. Android — Material 3

- **Color dinámico (Material You)**: en Android 12+, ofrecer la opción de derivar la paleta del wallpaper del usuario (`dynamic_color` package) como alternativa opcional al índigo de marca — nunca como default. El default siempre es la marca DiabeCare; el color dinámico es un ajuste de accesibilidad/personalización que el usuario activa explícitamente en Configuración, igual que hoy existe el toggle de modo oscuro.
- **Superficies tonales**: Material 3 reemplaza sombras duras por variaciones tonales de superficie para indicar elevación. Usar `surfaceContainerLow/Medium/High` en vez de replicar `--shadow-sm/md/lg` literalmente — son conceptos distintos, no una traducción 1:1.
- **Navegación**: `NavigationBar` (Material 3, no el `BottomNavigationBar` antiguo) para las 3-5 secciones principales (Dashboard, Glucosa, Comidas, Más). Transición estándar Material (`FadeThroughTransition`/shared-axis) entre tabs.
- **Botón de acción flotante (FAB)**: candidato natural para "Registrar glucosa" desde el Dashboard — patrón muy reconocible en Android, sin equivalente directo en iOS (ver sección 4).
- **Back gesture**: respetar el gesto de "atrás" del sistema (swipe desde el borde o botón físico/virtual) en cada pantalla — go_router lo maneja automáticamente si la jerarquía de rutas está bien declarada, pero vale la pena probarlo explícitamente en cada flujo modal.

---

## 4. iOS — Human Interface Guidelines

- **Sin FAB.** La convención de iOS no tiene un equivalente directo al FAB de Material — la acción "Registrar glucosa" en iOS va como un botón `+` en la barra de navegación (`CupertinoNavigationBar.trailing`) o como el primer elemento de una tab bar de acción rápida, nunca como un botón flotante superpuesto (se ve "prestado de Android" y los revisores de App Store lo notan).
- **Navegación**: `CupertinoTabBar` para las secciones principales (no `NavigationBar` de Material). Transiciones de push/pop con el deslizamiento característico de iOS (swipe-back desde el borde izquierdo) — go_router con `CupertinoPage` lo da automáticamente.
- **SF Symbols** para iconografía de sistema (no Material Icons) — usar `cupertino_icons` o el paquete `flutter_sfsymbols` para acceso a la librería completa. Los íconos de *producto* (ej. el ícono de "gota de sangre" para glucosa) sí pueden ser custom/compartidos con Android, son iconografía de marca, no de sistema.
- **Diálogos y action sheets**: `CupertinoAlertDialog`/`CupertinoActionSheet`, nunca `AlertDialog` de Material en una pantalla que por lo demás es Cupertino — la mezcla es la señal más rápida de que una app "no es nativa".
- **Safe areas**: respetar el notch/Dynamic Island y el home indicator con `SafeArea`/`CupertinoPageScaffold` en cada pantalla — especialmente crítico en pantallas con contenido pegado a los bordes (gráficas de glucosa a pantalla completa, por ejemplo).
- **Haptics**: iOS tiene convenciones de haptic feedback muy específicas por tipo de acción (`HapticFeedback.lightImpact` en selección, `.mediumImpact` en confirmación, `.heavyImpact` reservado para errores/alertas críticas de glucosa) — usarlas consistentemente es parte de sentirse nativo, no un detalle cosmético opcional.
- **Modo oscuro**: iOS distingue "Dark" de "light" a nivel de sistema con transiciones automáticas — usar `CupertinoThemeData.brightness` ligado a `MediaQuery.platformBrightnessOf`, igual filosofía que ya tiene el toggle de tema en la web pero respetando además la preferencia de "Automático" del sistema operativo si el usuario no fijó una explícita.

---

## 5. Componentes específicos de DiabeCare — reglas de adaptación

| Componente | Android (Material 3) | iOS (HIG) |
|---|---|---|
| Selector de fecha/hora (registro de glucosa) | `showDatePicker`/`showTimePicker` Material | `CupertinoDatePicker` (el rueda giratoria característica) |
| Confirmación de acción destructiva (eliminar cuenta, revocar API key) | `AlertDialog` Material con botones de texto | `CupertinoActionSheet` con botón rojo `isDestructiveAction: true` |
| Gráfica de glucosa (historial) | Mismo widget de gráficas en ambas — es contenido de datos, no chrome de plataforma; usar `fl_chart` o `syncfusion_flutter_charts`, con colores de estado según la tabla 2.2 | Igual que Android |
| Selector de unidad (mg/dL vs mmol/L) | `SegmentedButton` Material 3 | `CupertinoSlidingSegmentedControl` |
| Pull-to-refresh en historial | `RefreshIndicator` Material | `CupertinoSliverRefreshControl` |
| Switches (recordatorios, notificaciones) | `Switch.adaptive` — Flutter ya resuelve la apariencia correcta por plataforma automáticamente | (mismo widget) |

---

## 6. Accesibilidad (no negociable en ninguna plataforma)

- Contraste mínimo AA (WCAG 2.1) en todos los textos sobre superficie — mismo estándar que ya se sigue en `diabecare-web`.
- Todo ícono interactivo sin texto visible necesita `Semantics(label: ...)` — equivalente a los `aria-label` ya usados en el frontend web.
- Tamaño mínimo de zona táctil: 48x48dp en Android (guía Material), 44x44pt en iOS (guía HIG) — son casi el mismo valor físico, pero respetar el mínimo de *cada* plataforma en vez de un número único.
- VoiceOver (iOS) y TalkBack (Android) deben poder recorrer cada pantalla en un orden lógico — probar con el lector de pantalla activado como parte del checklist de QA de cada feature, no como una auditoría al final del proyecto.

---

## 7. Íconos y assets de producto

- Ícono de la app: una sola fuente de diseño (Figma/similar), exportada a los tamaños específicos que exige cada store (App Store usa un único 1024x1024 sin canal alpha; Android exige un set de densidades + el ícono adaptativo con capas foreground/background para Android 8+).
- Splash screen: usar `flutter_native_splash` — configurar con el color `--color-background` de marca, sin logo animado complejo (ambas plataformas penalizan splash screens largos en revisión y en percepción de performance).

---

*DiabeCare Mobile Design Guidelines v1.0 — documento vivo, actualizar conforme el proyecto avance*
