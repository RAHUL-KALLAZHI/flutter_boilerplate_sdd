import 'package:drift/drift.dart';

import 'connection/connection.dart' as impl;
import 'migrations/migration_manager.dart';
import 'tables/sync_metadata_table.dart';

part 'app_database.g.dart';

/// Centralized Drift relational database for LifeHub.
@DriftDatabase(tables: [SyncMetadataTable])
class AppDatabase extends _$AppDatabase {
  final MigrationManager _migrationManager;

  /// Default constructor using platform-specific SQLite file opener.
  AppDatabase([QueryExecutor? executor, MigrationManager? migrationManager])
      : _migrationManager = migrationManager ?? const MigrationManager(),
        super(executor ?? impl.openConnection());

  /// Named constructor specifically for in-memory or customized connection testing.
  AppDatabase.forTesting(
    super.connection, {
    MigrationManager? migrationManager,
  }) : _migrationManager = migrationManager ?? const MigrationManager();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => _migrationManager.createStrategy(this);
}
