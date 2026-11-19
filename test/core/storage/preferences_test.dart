import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_boilerplate_sdd/core/storage/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 'dark',
        'is_onboarded': true,
        'app_counter': 42,
      });
      final prefs = await SharedPreferences.getInstance();
      service = PreferencesService(prefs);
    });

    test('reads initial mock values correctly', () {
      expect(service.getString('theme_mode'), equals('dark'));
      expect(service.getBool('is_onboarded'), isTrue);
      expect(service.getInt('app_counter'), equals(42));
      expect(service.getBool('missing_flag', defaultValue: false), isFalse);
    });

    test('writes and updates values', () async {
      await service.setString('theme_mode', 'light');
      expect(service.getString('theme_mode'), equals('light'));

      await service.setBool('notifications_enabled', true);
      expect(service.getBool('notifications_enabled'), isTrue);

      await service.setInt('user_level', 5);
      expect(service.getInt('user_level'), equals(5));

      await service.setStringList('tags', ['flutter', 'clean_architecture']);
      expect(service.getStringList('tags'), equals(['flutter', 'clean_architecture']));
    });

    test('remove and clear operate correctly', () async {
      await service.remove('theme_mode');
      expect(service.containsKey('theme_mode'), isFalse);

      await service.clear();
      expect(service.containsKey('is_onboarded'), isFalse);
      expect(service.containsKey('app_counter'), isFalse);
    });
  });
}
