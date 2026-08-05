/// Pantalla "Acerca de" con información de la aplicación.
///
/// Este archivo define [AboutScreen], una pantalla secundaria y estática que
/// muestra el nombre de la app y su versión. Obtiene la versión de forma asíncrona
/// desde `package_info_plus`, que lee los metadatos del paquete nativo. No
/// interactúa con el estado de la mascota ni con Riverpod.
library;

// lib/ui/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Pantalla que muestra el nombre y la versión de la aplicación.
///
/// Usa un [FutureBuilder] para esperar la información del paquete
/// ([PackageInfo.fromPlatform]) y muestra un indicador de carga hasta que esté
/// disponible.
class AboutScreen extends StatelessWidget {
  /// Crea la pantalla "Acerca de".
  const AboutScreen({super.key});

  /// Construye la pantalla con el nombre y la versión de la app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          // Mientras no haya datos, se muestra un indicador de progreso.
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final info = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tamagotchi', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('v${info.version}+${info.buildNumber}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
