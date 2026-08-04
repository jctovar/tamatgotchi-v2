import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/services/persistence_service.dart';

void main() {
  group('PersistenceService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and load roundtrip', () async {
      final state = PetState.initial();
      await PersistenceService.save(state);

      final loaded = await PersistenceService.load();
      expect(loaded, isNotNull);
      expect(loaded!.hunger, state.hunger);
      expect(loaded.stage, state.stage);
    });

    test('load returns null when no data', () async {
      final loaded = await PersistenceService.load();
      expect(loaded, isNull);
    });
  });
}
