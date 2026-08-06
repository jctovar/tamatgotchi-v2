# 🥚 Tamagotchi

Una mascota virtual retro construida con **Flutter** y **Flame**, con estética de pantalla LCD
estilo Game Boy. Alimenta, juega, limpia y cuida a tu mascota mientras evoluciona a través de
distintas etapas — pero descúidala y su salud se resentirá, incluso mientras la app está cerrada.

> **Manual de usuario:** consulta [`manual.md`](manual.md) para aprender a jugar.

---

## ✨ Características

- 🖥️ **Pantalla LCD retro** renderizada con Flame a resolución fija 160×144 (proporción Game Boy),
  con efecto de rejilla de píxeles y animaciones de sprites.
- 🧠 **Estado en tiempo real** gestionado por Riverpod como única fuente de verdad.
- ⏳ **Decaimiento offline (delta-time):** las estadísticas decaen según el tiempo transcurrido,
  incluso con la app cerrada (con un tope de 24 horas).
- 🐣 **Evolución por etapas:** huevo → bebé → niño → adolescente → adulto, según la edad.
- 🎮 **Interfaz de dispositivo físico:** carcasa con pantalla y tres botones (A / B / C) con
  respuesta háptica y navegación por menú LCD.
- 🔔 **Notificaciones locales:** avisos programados cuando la mascota tiene hambre o está enferma.
- 🔊 **Efectos de sonido retro** en cada acción.
- 🌍 **Multiidioma:** Español, Inglés y Japonés (ES / EN / JA).
- 💾 **Persistencia automática** del estado en `SharedPreferences`.

---

## 🏛️ Arquitectura

El diseño sigue una **comunicación unidireccional** estricta. Riverpod es la única fuente de
verdad; Flame es una vista reactiva que nunca muta el estado por sí misma.

```
        ┌──────────────┐   acciones (botones)   ┌─────────────────┐
        │      UI      │ ─────────────────────▶ │     Riverpod     │
        │ (Flutter)    │                        │ (única verdad)   │
        └──────────────┘                        └────────┬─────────┘
                                                         │ cambios de estado
                                                         ▼
        ┌──────────────┐   eventos de animación  ┌─────────────────┐
        │     Flame    │ ◀────────────────────── │  PetController   │
        │ (LCD 160×144)│                          │  + FlameAction   │
        └──────────────┘                          └─────────────────┘
```

- **UI → Riverpod:** las acciones del usuario (botones A/B/C) invocan métodos del controlador.
- **Riverpod → Flame:** los cambios de estado se propagan al juego para actualizar animaciones.
- **Flame → Riverpod:** el juego solo emite eventos (p. ej. "la animación de comer terminó").
- **TimeEngine** calcula el decaimiento de estadísticas al reanudar la app (delta-time, tope 24 h).

### Reglas de oro

1. **Riverpod es la única fuente de verdad:** Flame nunca modifica el estado directamente.
2. **Flame es una vista reactiva:** escucha cambios de Riverpod y actualiza animaciones.
3. **Comunicación unidireccional** entre las tres capas.
4. **Toda mutación de estado se persiste** inmediatamente en `SharedPreferences`.

---

## 🧰 Stack tecnológico

| Paquete | Propósito |
|---|---|
| `flutter_riverpod` | Gestión de estado (única fuente de verdad). |
| `flame` | Motor 2D para la pantalla LCD (sprites, cámara, viewport). |
| `freezed` / `freezed_annotation` | Modelos inmutables con `copyWith` y serialización. |
| `json_serializable` / `json_annotation` | Generación de `toJson` / `fromJson`. |
| `shared_preferences` | Persistencia local del estado. |
| `flutter_local_notifications` | Notificaciones locales programadas. |
| `audioplayers` | Efectos de sonido retro. |
| `package_info_plus` | Versión y build en la pantalla "Acerca de". |
| `flutter_localizations` + ARB | Internacionalización (ES/EN/JA). |
| `timezone` | Soporte de zonas horarias para `zonedSchedule`. |
| `timeago` / `logger` | Utilidades. |

**Versiones clave:** Flutter 3.x · Dart 3.x (null safety) · Flame 1.38 · Riverpod 2.6 · Freezed 3.x.

---

## 📁 Estructura del proyecto

```
lib/
├── main.dart                     # Punto de entrada, ProviderScope, init de notificaciones.
├── app.dart                      # MaterialApp, tema, localización.
├── lifecycle_observer.dart       # Observador de ciclo de vida (pause/resume).
├── models/
│   ├── pet_state.dart            # Estado inmutable de la mascota (freezed).
│   ├── pet_stage.dart            # Enum de etapas: egg, baby, child, teen, adult.
│   └── pet_action.dart           # Enum de acciones: feed, play, clean, medicine, ...
├── services/
│   ├── time_engine.dart          # Decaimiento delta-time (tope 24 h) + muerte.
│   ├── persistence_service.dart  # Lectura/escritura en SharedPreferences.
│   ├── notification_service.dart # Notificaciones locales programadas.
│   └── audio_service.dart        # Efectos de sonido (best-effort).
├── providers/
│   ├── pet_controller.dart       # Notifier<PetState> con todas las acciones.
│   ├── flame_action_provider.dart# Canal lateral de animaciones one-shot.
│   └── menu_provider.dart        # Navegación del menú LCD.
├── game/
│   ├── tamagotchi_game.dart      # FlameGame, cámara y viewport 160×144.
│   ├── components/               # PetSprite, rejilla de píxeles, overlay del menú.
│   └── widgets/game_screen.dart  # Puente Riverpod ↔ Flame.
├── ui/
│   ├── screens/                  # HomeScreen, AboutScreen.
│   └── widgets/                  # Carcasa, pantalla LCD, botones físicos.
├── l10n/                         # Archivos ARB + localizaciones generadas.
└── utils/constants.dart          # Tasas de decaimiento, umbrales, duraciones.

assets/
├── images/tamagotchi_spritesheet.png  # Hoja de sprites (6 filas × 6 cols de 32×32).
└── audio/{beep,eat,cry}.wav           # Efectos de sonido retro.
```

---

## 🚀 Puesta en marcha

### Requisitos

- Flutter 3.x (SDK estable) con Dart 3.x.
- Un dispositivo/emulador **Android** o **iOS**.

### Instalación y ejecución

```bash
# 1. Instalar dependencias
flutter pub get

# 2. (Solo si cambias los ARB) regenerar localizaciones
flutter gen-l10n

# 3. (Solo si cambias modelos freezed) regenerar código
dart run build_runner build --delete-conflicting-outputs

# 4. Ejecutar la app
flutter run
```

### Tests y análisis

```bash
flutter test        # Suite completa (modelos, servicios, providers, juego, widget).
flutter analyze     # Análisis estático (sin issues).
```

---

## 🌍 Localización

El proyecto soporta **Español, Inglés y Japonés**. Las cadenas viven en `lib/l10n/app_*.arb`
(siendo `app_en.arb` la plantilla). Tras editar un ARB, ejecuta `flutter gen-l10n`.

> Nota: en Flutter 3.44 el paquete sintético `flutter_gen` fue eliminado; las localizaciones se
> generan en `lib/l10n/` y se importan como `package:tamagotchi/l10n/app_localizations.dart`.

---

## 🗺️ Notas y limitaciones conocidas

- La **pantalla "Acerca de"** (`AboutScreen`) está implementada pero aún **no es alcanzable**
  desde la navegación (el plan no especificó cómo cablearla al menú).
- El sprite usa una **hoja de sprites placeholder** (un blob simple generado por script,
  no arte final); el arte definitivo es una mejora pendiente.
- El sonido es **best-effort**: se silencia en entornos sin plataforma de audio (p. ej. tests).

---

## 📄 Licencia

Proyecto de demostración. Consulta el plan original en [`PLAN.md`](PLAN.md).
