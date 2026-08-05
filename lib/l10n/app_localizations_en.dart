// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tamagotchi';

  @override
  String get hunger => 'Hunger';

  @override
  String get happiness => 'Happiness';

  @override
  String get health => 'Health';

  @override
  String get weight => 'Weight';

  @override
  String get age => 'Age';

  @override
  String get menuFood => 'Food';

  @override
  String get menuLight => 'Light';

  @override
  String get menuPlay => 'Play';

  @override
  String get menuMedicine => 'Medicine';

  @override
  String get menuStatus => 'Status';

  @override
  String get menuGame => 'Game';

  @override
  String get petDead => 'Your pet has passed away...';

  @override
  String lastFed(String time) {
    return 'Last fed: $time';
  }
}
