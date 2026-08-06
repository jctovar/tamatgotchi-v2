# Localización de avisos de notificación

**Fecha:** 2026-08-06
**Estado:** Aprobado

## Problema

`NotificationService.scheduleWarnings` (lib/services/notification_service.dart:58-75)
usa cadenas hardcodeadas en español con errores de acentuación:

- `'Tu mascota tiene hambre!'`
- `'Tu mascota esta enferma!'` → falta la tilde en «está».

No están localizadas y no respetan los idiomas soportados (en/es/ja).

## Reto de diseño

`NotificationService` es un servicio estático y sin `BuildContext`. Su único
llamador es `LifecycleObserver` (lib/lifecycle_observer.dart:54), que tampoco
posee `BuildContext`, por lo que no puede resolver `AppLocalizations.of(context)`
directamente.

## Enfoque elegido: A — pasar `AppLocalizations` como parámetro

- `NotificationService.scheduleWarnings(PetState state, AppLocalizations l10n)`
  recibe la instancia localizada. El servicio queda desacoplado de Flutter context.
- `LifecycleObserver` guarda la última `AppLocalizations` (método `updateL10n`) y
  se la pasa al pausar. `HomeScreen` la actualiza en `didChangeDependencies`,
  el mismo patrón puente `Flutter → x` que ya usa `GameScreen` con
  `onLocaleChanged`. Reactivo a cambios de idioma.
- Tests: pueden construir `AppLocalizationsEs()` sin árbol de widgets.

## Claves l10n nuevas (título reutiliza `appTitle` = "Tamagotchi")

| Clave | en | es | ja |
|---|---|---|---|
| `notificationHungerBody` | Your pet is hungry! | Tu mascota tiene hambre! | ペットはお腹がすいています! |
| `notificationSickBody` | Your pet is sick! | Tu mascota está enferma! | ペットが病気です! |

## Cambios

1. `lib/l10n/app_{en,es,ja}.arb`: añadir las 2 claves + `@description` en la plantilla.
2. `flutter gen-l10n`.
3. `lib/services/notification_service.dart`: `scheduleWarnings` firma + uso de `l10n`.
4. `lib/lifecycle_observer.dart`: campo `_l10n`, `updateL10n`, pasarlo en `paused`.
5. `lib/ui/screens/home_screen.dart`: `updateL10n` en `didChangeDependencies`.
6. `test/services/notification_service_test.dart`: pasar `AppLocalizationsEs()` y
   ajustar la aserción del cuerpo de la notificación de enfermedad.