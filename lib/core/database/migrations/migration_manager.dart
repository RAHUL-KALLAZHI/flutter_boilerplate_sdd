import 'package:drift/drift.dart';

import '../app_database.dart';

/// Coordinates versioned schema migrations for [AppDatabase].
class MigrationManager {
  const MigrationManager();

  MigrationStrategy createStrategy(AppDatabase db) {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Sequentially execute migration steps as schema versions evolve
        for (int version = from + 1; version <= to; version++) {
          await _executeStep(m, version);
        }
      },
      beforeOpen: (details) async {
        // Enforce foreign key constraints across all SQLite connections
        await db.customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<void> _executeStep(Migrator m, int targetVersion) async {
    switch (targetVersion) {
      case 1:
        // Version 1 is baseline (all tables created in onCreate)
        break;
      // Future schema migration increments go here:
      // case 2:
      //   await m.addColumn(db.syncMetadataTable, db.syncMetadataTable.newColumn);
      //   break;
      default:
        break;
    }
  }
}
