import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Opens an ephemeral in-memory SQLite database connection for unit testing.
DatabaseConnection createInMemoryConnection() {
  return DatabaseConnection(NativeDatabase.memory());
}
