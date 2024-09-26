import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/customer.dart';
import '../models/inventory.dart';
import '../models/khata.dart';
import '../models/product.dart';
import '../models/transaction.dart' as app_transaction;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    return _database!;
  }

  Future<List<String>> getAllProductNames() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('products', columns: ['name']);
    return result.map((row) => row['name'] as String).toList();
  }

  Future<int> getRemainingProductQuantity(String productName) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'LOWER(name) = ?',
      whereArgs: [productName.toLowerCase()],
    );

    if (result.isNotEmpty) {
      return result.first['quantity'] as int;
    } else {
      return 0; // Return 0 if the product is not found
    }
  }

  Future<void> createKhataForCustomer(int customerId) async {
    final db = await database;
    final khata = Khata(
      customerId: customerId,
      startDate: DateTime.now(),
      paymentDueDate: DateTime.now().add(const Duration(days: 30)), // Example
      totalAmount: 0.0,
      remainingAmount: 0.0,
    );
    await db.insert('khata', khata.toMap());
  }

  Future<sqflite.Database> _initDatabase() async {
    return await sqflite.openDatabase(
      join(await sqflite.getDatabasesPath(), 'inventory.db'),
      version: 5, // Increment the version number if necessary
      onCreate: (db, version) async {
        // Create Customers table
        await db.execute(
          '''
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            phoneNumber TEXT
          )
          ''',
        );

        // Create Inventories table
        await db.execute(
          '''
          CREATE TABLE inventories(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            color INTEGER
          )
          ''',
        );

        // Create Products table
        await db.execute(
          '''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            imagePath TEXT, 
            quantity INTEGER, 
            unitValue REAL, 
            unit TEXT, 
            costPrice REAL, 
            sellingPrice REAL, 
            lastUpdated TEXT, 
            inventoryId INTEGER, 
            totalInvestment REAL, 
            salesHistory TEXT, 
            investmentHistory TEXT
          )
          ''',
        );

        // Create Khata table
        await db.execute(
          '''
          CREATE TABLE khata(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            customerId INTEGER, 
            startDate TEXT, 
            paymentDueDate TEXT, 
            totalAmount REAL, 
            remainingAmount REAL,
            FOREIGN KEY(customerId) REFERENCES customers(id)
          )
          ''',
        );

        // Create Transactions table
        await db.execute(
          '''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            khataId INTEGER, 
            productId INTEGER, 
            amountPaid REAL, 
            remainingAmount REAL, 
            transactionDate TEXT,
            isCredit INTEGER,  -- 0 for false, 1 for true
            FOREIGN KEY(khataId) REFERENCES khata(id),
            FOREIGN KEY(productId) REFERENCES products(id)
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE transactions ADD COLUMN isCredit INTEGER",
          );
        }
      },
    );
  }

  // Inventory-related methods
  Future<void> insertInventory(Inventory inventory) async {
    final db = await database;
    await db.insert(
      'inventories',
      inventory.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Inventory>> fetchInventories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('inventories');
    return List.generate(maps.length, (i) {
      return Inventory.fromMap(maps[i]);
    });
  }

  Future<void> deleteInventory(int id) async {
    final db = await database;
    await db.delete(
      'inventories',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateInventory(Inventory inventory) async {
    final db = await database;
    await db.update(
      'inventories',
      inventory.toMap(),
      where: "id = ?",
      whereArgs: [inventory.id],
    );
  }

  // Product-related methods
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> fetchProducts(int inventoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: "inventoryId = ?",
      whereArgs: [inventoryId],
    );
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: "id = ?",
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> fetchAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Khata-related methods
  Future<void> insertKhata(Khata khata) async {
    final db = await database;
    await db.insert(
      'khata',
      khata.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Khata>> fetchKhataForCustomer(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'khata',
      where: "customerId = ?",
      whereArgs: [customerId],
    );
    return List.generate(maps.length, (i) {
      return Khata.fromMap(maps[i]);
    });
  }

  Future<void> deleteKhata(int id) async {
    final db = await database;
    await db.delete(
      'khata',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Customer-related methods
  Future<void> insertCustomer(Customer customer) async {
    final db = await database;
    print('Inserting customer: ${customer.name}');
    try {
      await db.insert(
        'customers',
        customer.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      print('Customer inserted successfully');
    } catch (e) {
      print('Error inserting customer: $e');
    }
  }

  Future<List<Customer>> fetchCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<void> deleteCustomer(int id) async {
    final db = await database;
    await db.delete('customers', where: "id = ?", whereArgs: [id]);
  }

  // Transaction-related methods
  Future<void> insertTransaction(
      app_transaction.Transaction transaction) async {
    final db = await database;
    try {
      // Check if khata exists
      final List<Map<String, dynamic>> khataCheck = await db.query(
        'khata',
        where: 'customerId = ?',
        whereArgs: [transaction.khataId], // Assuming khataId is customerId
      );

      if (khataCheck.isEmpty) {
        await createKhataForCustomer(transaction.khataId);
      }

      final result = await db.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      print('Transaction inserted with ID: $result');

      // Debugging prints
      final List<Map<String, dynamic>> khataMaps = await db.query('khata');
      print('Khata in DB: $khataMaps');
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM transactions WHERE khataId = ?',
        [transaction.khataId],
      );
      print('Transactions for khataId ${transaction.khataId}: $maps');
    } catch (e) {
      print('Error inserting transaction: $e');
    }
  }

  Future<List<app_transaction.Transaction>> fetchTransactionsForKhata(
      int khataId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: "khataId = ?",
      whereArgs: [khataId],
    );
    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  Future<List<app_transaction.Transaction>> fetchTransactionsForCustomer(
      int customerId) async {
    final db = await database;
    print('Fetching transactions for customer ID: $customerId');

    // Check the contents of the khata table
    final List<Map<String, dynamic>> khataMaps = await db.query('khata');
    print('Khata in DB: $khataMaps');

    // Manually verify the khataId linkage
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT * FROM transactions
    WHERE khataId = ?
    ''',
      [1], // Replace with dynamic khataId as needed
    );
    print('Transactions for khataId 1: $maps');

    // Fetch transactions using the current query
    final List<Map<String, dynamic>> resultMaps = await db.rawQuery(
      '''
    SELECT transactions.* FROM transactions
    INNER JOIN khata ON transactions.khataId = khata.id
    WHERE khata.customerId = ?
    ''',
      [customerId],
    );
    print('Raw query result: $resultMaps');

    return List.generate(resultMaps.length, (i) {
      return app_transaction.Transaction.fromMap(resultMaps[i]);
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
