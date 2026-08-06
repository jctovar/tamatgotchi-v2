// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tamagotchi';

  @override
  String get hunger => 'Hambre';

  @override
  String get happiness => 'Felicidad';

  @override
  String get health => 'Salud';

  @override
  String get weight => 'Peso';

  @override
  String get age => 'Edad';

  @override
  String get stage => 'Etapa';

  @override
  String get menuFood => 'Comida';

  @override
  String get menuLight => 'Luz';

  @override
  String get menuPlay => 'Jugar';

  @override
  String get menuMedicine => 'Medicina';

  @override
  String get menuStatus => 'Estado';

  @override
  String get menuGame => 'Juego';

  @override
  String get petDead => 'Tu mascota ha fallecido...';

  @override
  String lastFed(String time) {
    return 'Última comida: $time';
  }

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get notificationHungerBody => 'Tu mascota tiene hambre!';

  @override
  String get notificationSickBody => 'Tu mascota está enferma!';
}
