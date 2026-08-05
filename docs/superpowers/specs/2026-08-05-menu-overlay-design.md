# Overlay de menú visual sobre la LCD

**Fecha:** 2026-08-05
**Estado:** Aprobado

## Contexto

`menuProvider` (Riverpod) ya modela el menú del Tamagotchi: seis opciones
(`MenuItem.food/light/play/medicine/status/game`), un `selectedIndex` y un
`isVisible`. Los botones físicos A/B/C (`home_screen.dart`) ya mutan este
estado (`toggle`, `next`, `hide`) y ejecutan la acción seleccionada. Pero
ningún widget observa `menuProvider` — la lógica existe, la vista no. El
usuario puede pulsar A/B/C y el estado interno cambia, pero nada se dibuja
en pantalla.

Además, el proyecto ya tiene infraestructura de i18n (ES/EN/JA vía ARB,
`AppLocalizations` generado y registrado en `app.dart`) que ningún widget
consume todavía. Los ARB ya incluyen las claves exactas para este menú:
`menuFood`, `menuLight`, `menuPlay`, `menuMedicine`, `menuStatus`,
`menuGame` en los tres idiomas — preparadas de antemano para esta feature.

No hay assets de iconos reales (el spritesheet de la mascota es en sí
mismo un placeholder de un solo color, hallazgo aparte). Por eso el menú
se representa con texto, no con iconos.

## Objetivo

Dibujar el menú sobre la pantalla LCD (160×144, motor Flame) reflejando
`menuProvider` en tiempo real, con texto localizado vía `AppLocalizations`,
sin introducir una nueva capa de arquitectura — extendiendo el patrón de
bridging Riverpod→Flame que `GameScreen` ya usa para
`petControllerProvider` y `flameActionProvider`.

## Decisiones de diseño

| Decisión | Elegido | Alternativa descartada |
|---|---|---|
| Dónde vive el menú | Componente Flame (`world`) | Overlay de Flutter sobre `GameWidget` |
| Representación de opciones | Texto (`TextPaint`) | Iconos geométricos dibujados a mano |
| Indicador de selección | Fondo invertido (rect sólido detrás del label activo) | Cursor `>` al lado del texto |
| Idioma del texto | `AppLocalizations` real (ES/EN/JA) | Texto fijo en español |
| Fondo del panel mientras el menú está abierto | Semitransparente (`0xCC2C2C2C`, ~80% opacidad) | Panel sólido opaco |

## Arquitectura

Se extiende el patrón de bridging Riverpod→Flame que `GameScreen` ya usa.
No hay capas nuevas: un componente Flame más, dos métodos puente más en
`TamagotchiGame`, dos hooks más en `GameScreen`.

## Componentes

### `lib/game/components/menu_overlay_component.dart` (nuevo)

`MenuOverlayComponent extends PositionComponent` con `priority: 10` (se
dibuja siempre encima de `PixelGridComponent` y `PetSpriteComponent`, sin
depender del orden de inserción en `world`).

Estado interno:
- `MenuState _menuState = const MenuState()` (default oculto).
- `List<String> _labels = MenuItem.values.map((e) => e.name).toList()`
  (fallback defensivo con los nombres del enum, sobreescrito casi de
  inmediato por el bridge de idioma tras el primer frame).

API pública:
- `void updateMenuState(MenuState state)`
- `void updateLabels(List<String> labels)`

`render(Canvas canvas)`:
1. Si `!_menuState.isVisible`, no dibuja nada (corto-circuito, igual que
   el resto de componentes del proyecto).
2. Si es visible:
   - Panel de fondo cubriendo la pantalla lógica completa (160×144),
     color `0xCC2C2C2C` (LCD oscuro, ~80% de opacidad) — deja ver
     tenuemente la rejilla de píxeles y el sprite debajo.
   - Los 6 labels de `_menuState.items` en lista vertical, vía
     `TextPaint` con fuente monoespaciada (~10-12px lógicos, para que las
     6 líneas quepan cómodas en 144px de alto con margen).
   - Para el item en `_menuState.selectedIndex`: un `Rect` de fondo
     invertido (`0xFF9BBC0F`, el verde LCD) detrás de esa línea, con el
     texto en color oscuro (`0xFF0F380F`). El resto de labels van en
     texto claro (`0xFF9BBC0F`) sin fondo.

### `lib/game/tamagotchi_game.dart` (modificado)

- El constructor recibe también `required MenuState initialMenuState`.
- `onLoad()` agrega `_menuOverlay = MenuOverlayComponent()` a `world`
  (el `priority` ya garantiza el z-order; el orden de inserción no
  importa).
- Dos métodos puente nuevos:
  - `onMenuChanged(MenuState newState)` → `_menuOverlay.updateMenuState(newState)`
  - `onLocaleChanged(List<String> labels)` → `_menuOverlay.updateLabels(labels)`

### `lib/game/widgets/game_screen.dart` (modificado)

- `initState()`: además del estado inicial de la mascota, lee
  `ref.read(menuProvider)` y lo pasa como `initialMenuState` al
  constructor de `TamagotchiGame`.
- `didChangeDependencies()` (nuevo override): resuelve
  `AppLocalizations.of(context)!` y llama a
  `_game.onLocaleChanged([l10n.menuFood, l10n.menuLight, l10n.menuPlay, l10n.menuMedicine, l10n.menuStatus, l10n.menuGame])`
  — en el mismo orden que `MenuItem.values`. Se ejecuta una vez al
  montar y de nuevo si cambia el locale del sistema en caliente (hook
  correcto de Flutter para dependencias de `BuildContext`; no se hace en
  `build()` para no re-ejecutarlo en cada rebuild no relacionado).
- `build()`: agrega `ref.listen(menuProvider, (prev, next) => _game.onMenuChanged(next));`,
  igual que los dos listeners ya existentes (`petControllerProvider`,
  `flameActionProvider`).

## Flujo de datos

```
Usuario pulsa A/B/C → home_screen.dart muta menuProvider (Riverpod)
                                    │
                    ref.listen en GameScreen.build()
                                    ▼
                    TamagotchiGame.onMenuChanged(MenuState)
                                    ▼
                    MenuOverlayComponent.updateMenuState(...)
                                    ▼
                         próximo render() lo refleja
```

En paralelo, un flujo independiente para el idioma:
`didChangeDependencies → onLocaleChanged → updateLabels`, desacoplado del
flujo de interacción del usuario.

## Manejo de errores

No hay entradas externas que puedan fallar (sin red, parsing ni I/O):
`MenuState` siempre tiene 6 items válidos por construcción
(`MenuItem.values`), y `AppLocalizations.of(context)!` es seguro porque el
delegate ya está registrado en `app.dart` para los tres locales
soportados. No se añade manejo de errores adicional — coherente con el
resto del código Flame existente (`PixelGridComponent`,
`PetSpriteComponent`), que tampoco lo tiene.

## Testing

Sigue el patrón ya establecido en `test/game/tamagotchi_game_test.dart`
(`flame_test`'s `testWithGame`):

- `MenuOverlayComponent`: oculto por defecto no dibuja; tras
  `updateMenuState` con `isVisible: true`, el componente refleja el
  nuevo estado; `updateLabels` reemplaza los labels.
- `TamagotchiGame`: agrega el nuevo componente en `onLoad` (ajustar el
  `expect(game.children.length, greaterThanOrEqualTo(2))` existente a
  `3`); `onMenuChanged`/`onLocaleChanged` delegan correctamente al
  componente.
- No se agregan tests de `game_screen.dart`: no tiene test hoy y el
  resto del bridging existente en ese archivo (los otros dos
  `ref.listen`) tampoco está testeado directamente — fuera de alcance de
  este cambio.

## Fuera de alcance

- Reemplazar el spritesheet placeholder (hallazgo aparte, se aborda por
  separado).
- Un selector de idioma dentro de la app (el locale sigue viniendo del
  sistema operativo).
- Iconos reales para las opciones del menú.
- Implementar las acciones `status` y `game` del menú (ya son no-ops en
  `home_screen.dart`, fuera del alcance de este cambio).
