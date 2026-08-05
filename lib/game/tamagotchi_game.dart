/// Motor de juego Flame: la pantalla LCD retro de la mascota.
///
/// Este archivo define [TamagotchiGame], la instancia de `FlameGame` que dibuja
/// la pantalla estilo Game Boy (160×144) donde vive la mascota. En la arquitectura
/// unidireccional, el motor es una vista reactiva de solo lectura: recibe el
/// estado desde Riverpod (vía [onStateChanged]) y eventos de acción (vía
/// [onAction]), pero nunca muta el estado por sí mismo.
///
/// La cámara usa una resolución fija de 160×144 para que el contenido se dibuje
/// en coordenadas "lógicas" de píxel y Flame lo escale automáticamente al tamaño
/// real del widget, preservando la estética de pantalla retro.
library;

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../models/pet_action.dart';
import '../models/pet_state.dart';
import '../utils/constants.dart';
import 'components/pet_sprite_component.dart';
import 'components/pixel_grid_component.dart';
import 'components/menu_overlay_component.dart';
import '../providers/menu_provider.dart';

/// Juego Flame que renderiza la pantalla LCD y la mascota.
///
/// Actúa como punto de entrada del motor: crea la cámara con resolución fija,
/// carga los componentes del mundo y expone dos métodos ([onStateChanged] y
/// [onAction]) para que la capa Riverpod le comunique cambios de estado y eventos.
class TamagotchiGame extends FlameGame {
  /// Componente de sprite de la mascota, creado durante [onLoad].
  late PetSpriteComponent _petSprite;

  /// Componente que dibuja el overlay del menú, creado durante [onLoad].
  late MenuOverlayComponent _menuOverlay;

  /// Último estado recibido desde Riverpod.
  PetState _currentState;

  /// Último estado del menú recibido desde Riverpod.
  MenuState _initialMenuState;

  /// Crea el juego con un [initialState] y una cámara de resolución fija.
  ///
  /// La cámara se configura con `CameraComponent.withFixedResolution` a
  /// [Constants.lcdWidth]×[Constants.lcdHeight] (160×144). Esto define un
  /// "viewport" lógico: los componentes se posicionan en esas coordenadas y Flame
  /// escala el resultado al tamaño físico del widget, manteniendo la proporción y
  /// el aspecto de pantalla retro sin importar el tamaño del contenedor.
  TamagotchiGame({
    required PetState initialState,
    required MenuState initialMenuState,
  })  : _currentState = initialState,
        _initialMenuState = initialMenuState,
        super(
          camera: CameraComponent.withFixedResolution(
            width: Constants.lcdWidth.toDouble(),
            height: Constants.lcdHeight.toDouble(),
          ),
        );

  /// Color de fondo de la pantalla LCD (verde Game Boy).
  @override
  Color backgroundColor() => const Color(0xFF9BBC0F);

  /// Carga los componentes iniciales del mundo.
  ///
  /// Los componentes se añaden a [world] (y no directamente a la cámara) porque
  /// [world] es el espacio de coordenadas del juego que la cámara observa y
  /// transforma; solo lo que está en [world] se ve afectado por el viewport y el
  /// ancla de la cámara. La rejilla de píxeles da el aspecto de matriz LCD y el
  /// sprite de la mascota se centra en la pantalla.
  @override
  Future<void> onLoad() async {
    // Ancla el viewfinder arriba-izquierda para que (0,0) sea la esquina
    // superior izquierda de la pantalla lógica.
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PixelGridComponent());

    _petSprite = PetSpriteComponent(
      petState: _currentState,
      position: Vector2(
        Constants.lcdWidth / 2 - 16,
        Constants.lcdHeight / 2 - 16,
      ),
      size: Vector2(32, 32),
    );
    world.add(_petSprite);

    _menuOverlay = MenuOverlayComponent()..updateMenuState(_initialMenuState);
    world.add(_menuOverlay);
  }

  /// Punto de entrada "Riverpod → Flame" para cambios de estado.
  ///
  /// Guarda el nuevo estado y lo propaga al sprite de la mascota para que ajuste
  /// su animación (por ejemplo, dormir o morir).
  void onStateChanged(PetState newState) {
    _currentState = newState;
    _petSprite.updateState(newState);
  }

  /// Punto de entrada "Riverpod → Flame" para eventos de acción.
  ///
  /// Reproduce la animación puntual asociada a [action] en el sprite.
  void onAction(PetAction action) {
    _petSprite.playOneShot(action);
  }

  /// Punto de entrada "Riverpod → Flame" para cambios del menú.
  ///
  /// Empuja el nuevo estado del menú (visibilidad y selección) al overlay.
  void onMenuChanged(MenuState newState) {
    _menuOverlay.updateMenuState(newState);
  }

  /// Punto de entrada "Flutter → Flame" para cambios de idioma.
  ///
  /// Empuja las etiquetas localizadas de las opciones del menú al overlay,
  /// en el mismo orden que `MenuItem.values`.
  void onLocaleChanged(List<String> labels) {
    _menuOverlay.updateLabels(labels);
  }
}
