abstract final class Constants {
  static const int lcdWidth = 160;
  static const int lcdHeight = 144;

  static const double hungerDecayPerHour = 4.0;
  static const double happinessDecayPerHour = 3.0;
  static const double healthDecayPerHour = 1.5;

  static const double hungerWarningThreshold = 40.0;
  static const double healthWarningThreshold = 30.0;

  static const int maxOfflineHours = 24;

  static const Duration eggHatchTime = Duration(minutes: 5);
  static const Duration babyToChild = Duration(hours: 24);
  static const Duration childToTeen = Duration(hours: 72);
  static const Duration teenToAdult = Duration(hours: 168);
}
