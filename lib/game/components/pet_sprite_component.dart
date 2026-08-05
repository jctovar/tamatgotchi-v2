/// Componente de sprite animado de la mascota.
///
/// Este archivo define [PetSpriteComponent], el componente visual que representa
/// a la mascota dentro del motor Flame. Es un `SpriteAnimationGroupComponent`
/// parametrizado por [PetAction]: mantiene una animación distinta para cada
/// acción y cambia entre ellas según el estado o los eventos recibidos.
///
/// En la arquitectura unidireccional, este componente es puramente reactivo:
/// recibe el estado y las acciones desde [TamagotchiGame] (que a su vez los recibe
/// de Riverpod) y solo cambia su animación, sin mutar ningún estado.
library;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../../models/pet_action.dart';
import '../../models/pet_state.dart';
import '../tamagotchi_game.dart';

/// Sprite animado de la mascota, con una animación por cada [PetAction].
///
/// Usa el mixin `HasGameReference<TamagotchiGame>` para acceder al juego mediante
/// el getter [game]. Este mixin reemplaza al antiguo `HasGameRef`, que está
/// obsoleto (deprecated) a partir de Flame 1.38; `HasGameReference` es la forma
/// recomendada y con tipado fuerte de obtener la referencia al juego padre.
class PetSpriteComponent extends SpriteAnimationGroupComponent<PetAction>
    with HasGameReference<TamagotchiGame> {
  /// Último estado de la mascota recibido desde el juego.
  PetState petState;

  /// Crea el sprite con el estado inicial [petState], [position] y [size].
  PetSpriteComponent({required this.petState, super.position, super.size});

  /// Carga la hoja de sprites y construye el mapa de animaciones.
  ///
  /// La hoja `tamagotchi_spritesheet.png` se divide en celdas de 32×32. Cada fila
  /// corresponde a una acción y se convierte en una animación con su propio número
  /// de fotogramas y velocidad. La animación inicial es la de reposo
  /// ([PetAction.toggleLight], fila 0).
  @override
  Future<void> onLoad() async {
    // `game` proviene de HasGameReference y da acceso al TamagotchiGame padre,
    // incluido su cargador de imágenes.
    final image = await game.images.load('tamagotchi_spritesheet.png');
    final sheet = SpriteSheet(image: image, srcSize: Vector2(32, 32));

    // Mapa acción → animación. Cada fila de la hoja es una acción distinta.
    animations = {
      PetAction.feed: sheet.createAnimation(row: 1, stepTime: 0.15, to: 4),
      PetAction.play: sheet.createAnimation(row: 2, stepTime: 0.12, to: 6),
      PetAction.clean: sheet.createAnimation(row: 3, stepTime: 0.15, to: 4),
      PetAction.medicine: sheet.createAnimation(row: 4, stepTime: 0.2, to: 3),
      PetAction.toggleLight:
          sheet.createAnimation(row: 0, stepTime: 0.3, to: 2),
      PetAction.sleep: sheet.createAnimation(row: 5, stepTime: 0.5, to: 2),
    };

    // Animación de reposo por defecto.
    current = PetAction.toggleLight;
  }

  /// Actualiza el estado y ajusta la animación en consecuencia.
  ///
  /// Si la mascota ha muerto, no cambia la animación (se congela el sprite). Si
  /// está dormida, pasa a la animación de dormir.
  void updateState(PetState newState) {
    petState = newState;
    if (!newState.isAlive) {
      return;
    }
    if (newState.isSleeping) {
      current = PetAction.sleep;
    }
  }

  /// Reproduce la animación puntual asociada a [action].
  ///
  /// Cambia la animación actual a la de la acción recibida; el componente vuelve
  /// después a la animación base mediante [returnToBase].
  void playOneShot(PetAction action) {
    current = action;
  }

  /// Vuelve a la animación base según el estado actual.
  ///
  /// Si la mascota duerme, regresa a la animación de dormir; en caso contrario, a
  /// la animación de reposo ([PetAction.toggleLight]).
  void returnToBase() {
    if (petState.isSleeping) {
      current = PetAction.sleep;
    } else {
      current = PetAction.toggleLight;
    }
  }
}
