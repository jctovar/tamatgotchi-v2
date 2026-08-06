// test/providers/flame_action_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_action.dart';
import 'package:tamagotchi/providers/flame_action_provider.dart';

void main() {
  group('FlameActionNotifier', () {
    test('starts with no action and zero timestamp', () {
      final notifier = FlameActionNotifier();
      expect(notifier.lastAction, isNull);
      expect(notifier.timestamp, 0);
    });

    test('trigger stores the action and a non-zero timestamp', () {
      final notifier = FlameActionNotifier();
      notifier.trigger(PetAction.feed);
      expect(notifier.lastAction, PetAction.feed);
      expect(notifier.timestamp, greaterThan(0));
    });

    test('trigger updates the timestamp on each call', () {
      final notifier = FlameActionNotifier();
      notifier.trigger(PetAction.feed);
      final first = notifier.timestamp;
      notifier.trigger(PetAction.feed);
      expect(notifier.timestamp, greaterThanOrEqualTo(first));
    });
  });
}