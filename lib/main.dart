/// Punto de entrada de la aplicación.
///
/// Este archivo contiene la función [main], responsable de arrancar la app. Su
/// cometido es preparar las dependencias globales que deben existir antes de
/// construir cualquier widget: garantiza la inicialización del binding de Flutter
/// e inicializa el servicio de notificaciones. Después envuelve la raíz de la
/// interfaz en un [ProviderScope] de Riverpod, que es el contenedor de todos los
/// proveedores (la fuente de verdad del estado).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/notification_service.dart';

/// Arranque de la aplicación.
///
/// Pasos que realiza, en orden:
///
/// 1. `WidgetsFlutterBinding.ensureInitialized()`: asegura el binding antes de
///    cualquier llamada asíncrona a plugins (necesario porque `main` es `async`).
/// 2. `NotificationService.init()`: inicializa el plugin de notificaciones y la
///    base de datos de zonas horarias antes de poder programar avisos.
/// 3. `runApp`: monta la raíz [TamagotchiApp] dentro de un [ProviderScope], el
///    contenedor de Riverpod que aloja todos los proveedores de la app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const ProviderScope(child: TamagotchiApp()));
}
