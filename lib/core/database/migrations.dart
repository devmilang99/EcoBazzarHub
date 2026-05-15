import 'package:drift/drift.dart';
import 'app_database.dart';

/// Handles database migrations and atomicity for EcoBazzarHub
class AppDatabaseMigration extends MigrationStrategy {
  final AppDatabase db;

  AppDatabaseMigration(this.db)
      : super(
          onCreate: (m) async {
            // Initial creation of all tables
            await m.createAll();
          },
          onUpgrade: (m, from, to) async {
            // Handle table upgrades with atomicity (transactions)
            await db.transaction(() async {
              if (from < 2) {
                // Migration from version 1 to 2
                // Version 1 had 'Todos', which we are removing or migrating
                try {
                  await m.deleteTable('todos');
                } catch (e) {
                  // Table might not exist in some environments
                }
                await m.createTable(db.appSettings);
                await m.createTable(db.cartItems);
                await m.createTable(db.orders);
              }
              if (from < 3) {
                // Version 3 adds OrderItems
                await m.createTable(db.orderItemsTable);
              }
              if (from < 4) {
                // Version 4 adds subtotal, tax, discount, reasons and feedback
                await m.addColumn(db.orders, db.orders.subtotal);
                await m.addColumn(db.orders, db.orders.taxAmount);
                await m.addColumn(db.orders, db.orders.discountAmount);
                await m.addColumn(db.orders, db.orders.cancellationReason);
                await m.addColumn(db.orders, db.orders.rating);
                await m.addColumn(db.orders, db.orders.comment);
              }
            });
          },
          beforeOpen: (details) async {
            // Enable foreign keys if any
            await db.customStatement('PRAGMA foreign_keys = ON');
          },
        );
}
