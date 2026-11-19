import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate_sdd/core/database/app_database.dart';
import 'package:flutter_boilerplate_sdd/core/database/connection/in_memory_connection.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() {
      final inMemoryConnection = createInMemoryConnection();
      database = AppDatabase.forTesting(inMemoryConnection);
    });

    tearDown(() async {
      await database.close();
    });

    test('schemaVersion is 1', () {
      expect(database.schemaVersion, equals(1));
    });

    test('inserts and retrieves sync metadata records', () async {
      await database.into(database.syncMetadataTable).insert(
            SyncMetadataTableCompanion.insert(
              entityType: 'user_profile',
              entityId: 'user_1',
              lastSyncedAt: Value(DateTime(2026, 11, 19, 10, 0, 0)),
              syncStatus: const Value('synced'),
            ),
          );

      final records = await database.select(database.syncMetadataTable).get();

      expect(records, hasLength(1));
      expect(records.first.entityType, equals('user_profile'));
      expect(records.first.entityId, equals('user_1'));
      expect(records.first.syncStatus, equals('synced'));
    });
  });
}
