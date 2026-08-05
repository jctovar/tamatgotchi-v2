/// Acciones que el usuario puede realizar sobre la mascota.
///
/// Este archivo define [PetAction], el enum que enumera todas las interacciones
/// posibles con el Tamagotchi. Cumple un triple papel dentro de la arquitectura
/// unidireccional:
///
/// 1. Identifica la operación que el controlador (`PetController`) aplica al
///    estado (por ejemplo, `feed` aumenta el hambre).
/// 2. Sirve como "evento" que se emite hacia el motor Flame a través de
///    `FlameActionNotifier` para reproducir la animación correspondiente.
/// 3. Actúa como clave del mapa de animaciones en `PetSpriteComponent` y como
///    selector del efecto de sonido en `AudioService`.
library;

/// Interacciones disponibles con la mascota.
///
/// * [feed] Alimentar: +20 de saciedad y +0.5 de peso.
/// * [play] Jugar: +15 de felicidad, −5 de saciedad y −0.2 de peso.
/// * [clean] Limpiar: +5 de salud.
/// * [medicine] Medicina: +30 de salud.
/// * [toggleLight] Encender/apagar la luz de la pantalla.
/// * [sleep] Dormir a la mascota (pausa el decaimiento de estadísticas).
enum PetAction { feed, play, clean, medicine, toggleLight, sleep }
