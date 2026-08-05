/// Raíz de la interfaz de la aplicación.
///
/// Este archivo define [TamagotchiApp], el widget raíz que configura el
/// [MaterialApp]: tema oscuro, localizaciones (inglés, español y japonés) y la
/// pantalla de inicio. No contiene estado propio; todo el estado de la app vive
/// en Riverpod, por lo que este widget es únicamente configuración de presentación.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamagotchi/l10n/app_localizations.dart';
import 'ui/screens/home_screen.dart';

/// Widget raíz que construye el [MaterialApp] del Tamagotchi.
///
/// Establece un tema oscuro con Material 3, registra los delegados de
/// localización generados ([AppLocalizations]) junto con los globales de Flutter,
/// declara los idiomas soportados y fija [HomeScreen] como pantalla inicial.
class TamagotchiApp extends StatelessWidget {
  /// Crea el widget raíz de la aplicación.
  const TamagotchiApp({super.key});

  /// Construye el [MaterialApp] con tema, localizaciones y pantalla inicial.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi',
      theme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ja'),
      ],
      home: const HomeScreen(),
    );
  }
}
