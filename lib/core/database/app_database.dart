import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'migrations.dart';

part 'app_database.g.dart';

/// Table to store application settings, replacing SharedPreferences
@DataClassName('AppSettingLocal')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  
  @override
  Set<Column> get primaryKey => {key};
}

/// Table to store cart items for offline shopping persistence
@DataClassName('CartItemLocal')
class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get productPrice => real()();
  TextColumn get productImageUrl => text()();
  TextColumn get description => text().withDefault(const Constant('Premium quality product.'))();
  TextColumn get category => text().withDefault(const Constant('General'))();
  TextColumn get categoryId => text().withDefault(const Constant('all'))();
  IntColumn get quantity => integer()();
  BoolColumn get isSelected => boolean().withDefault(const Constant(true))();
  TextColumn get sellerName => text().withDefault(const Constant('Eco Store'))();
}

/// Table to store orders for offline order history tracking
@DataClassName('OrderLocal')
/// Table to store orders for offline order history tracking
@DataClassName('OrderLocal')
class Orders extends Table {
  TextColumn get id => text()();
  RealColumn get totalAmount => real()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get orderDate => dateTime()();
  IntColumn get status => integer()(); // Enum index
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancellationReason => text().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get comment => text().nullable()();
  DateTimeColumn get placedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table to store items belonging to an order
@DataClassName('OrderItemDb')
class OrderItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text()(); // Simplified to text for now to avoid generation issues
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get productPrice => real()();
  TextColumn get productImageUrl => text()();
  IntColumn get quantity => integer()();
}

@DriftDatabase(tables: [AppSettings, CartItems, Orders, OrderItemsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => AppDatabaseMigration(this);

  // --- Offline Settings Actions (Atomic where necessary) ---

  /// Saves a setting key-value pair atomically using insertOnConflictUpdate.
  Future<void> saveSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  /// Retrieves a setting value by its key.
  Future<String?> getSetting(String key) async {
    final result = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  /// Stream to watch a setting value for reactive UI updates.
  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  // --- Cart Actions (Atomic) ---

  /// Adds or updates an item in the cart atomically.
  Future<void> syncCartItem(CartItemsCompanion item) async {
    await transaction(() async {
      final existing = await (select(cartItems)
            ..where((t) => t.productId.equals(item.productId.value)))
          .getSingleOrNull();

      if (existing != null) {
        await (update(cartItems)..where((t) => t.productId.equals(item.productId.value)))
            .write(item);
      } else {
        await into(cartItems).insert(item);
      }
    });
  }

  /// Clears the entire cart atomically.
  Future<void> clearCart() => delete(cartItems).go();

  // --- Order Actions ---

  /// Saves an order and its items atomically.
  Future<void> saveOrder(OrdersCompanion order, List<OrderItemsTableCompanion> items) async {
    await transaction(() async {
      await into(orders).insert(order);
      for (var item in items) {
        await into(orderItemsTable).insert(item);
      }
    });
  }

  /// Updates an order status (and cancellation info if applicable).
  Future<void> updateOrderStatus(String orderId, int status,
      {DateTime? cancelledAt, String? reason}) async {
    await (update(orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        status: Value(status),
        cancelledAt: Value(cancelledAt),
        cancellationReason: Value(reason),
      ),
    );
  }

  /// Updates order feedback (rating and comment).
  Future<void> updateOrderFeedback(String orderId, int rating, String comment) async {
    await (update(orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        rating: Value(rating),
        comment: Value(comment),
      ),
    );
  }

  /// Deletes a specific order and its items.
  Future<void> deleteOrder(String orderId) async {
    await transaction(() async {
      await (delete(orderItemsTable)..where((t) => t.orderId.equals(orderId))).go();
      await (delete(orders)..where((t) => t.id.equals(orderId))).go();
    });
  }

  /// Deletes all orders with a specific status.
  Future<void> deleteOrdersByStatus(int status) async {
    await transaction(() async {
      final ordersToDelete = await (select(orders)..where((t) => t.status.equals(status))).get();
      for (final order in ordersToDelete) {
        await (delete(orderItemsTable)..where((t) => t.orderId.equals(order.id))).go();
      }
      await (delete(orders)..where((t) => t.status.equals(status))).go();
    });
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      // Intentionally not deleting appSettings so permissions, theme, etc are kept
      await delete(cartItems).go();
      await delete(orderItemsTable).go();
      await delete(orders).go();
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'eco_bazzar_db',
  );
}
