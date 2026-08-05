// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'たまごっち';

  @override
  String get hunger => 'おなか';

  @override
  String get happiness => 'しあわせ';

  @override
  String get health => 'けんこう';

  @override
  String get weight => 'たいじゅう';

  @override
  String get age => 'ねんれい';

  @override
  String get menuFood => 'ごはん';

  @override
  String get menuLight => 'ライト';

  @override
  String get menuPlay => 'あそぶ';

  @override
  String get menuMedicine => 'くすり';

  @override
  String get menuStatus => 'ステータス';

  @override
  String get menuGame => 'ゲーム';

  @override
  String get petDead => 'ペットは天国に旅立ちました...';

  @override
  String lastFed(String time) {
    return '最後の食事: $time';
  }
}
