/// Etapas evolutivas de la mascota virtual.
///
/// Este archivo define [PetStage], el enum que modela el ciclo de vida del
/// Tamagotchi. La etapa se calcula exclusivamente en función de la edad
/// (`PetState.age`) dentro de `TimeEngine._calculateStage`, por lo que evoluciona
/// de forma automática con el paso del tiempo (incluso en segundo plano) y no
/// depende de ninguna acción del usuario.
library;

/// Ciclo de vida de la mascota, ordenado de menor a mayor edad.
///
/// Los umbrales de transición se definen en `Constants`:
///
/// * [egg] → [baby] a los 5 minutos de edad.
/// * [baby] → [child] a las 24 horas.
/// * [child] → [teen] a las 72 horas.
/// * [teen] → [adult] a las 168 horas (7 días).
enum PetStage { egg, baby, child, teen, adult }
