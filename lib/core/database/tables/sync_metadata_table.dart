import 'package:drift/drift.dart';

/// Baseline table tracking sync status, timestamps, and schema versioning for local entities.
class SyncMetadataTable extends Table {
  TextColumn get entityType => text().withLength(min: 1, max: 100)();
  TextColumn get entityId => text().withLength(min: 1, max: 100)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {entityType, entityId};
}
