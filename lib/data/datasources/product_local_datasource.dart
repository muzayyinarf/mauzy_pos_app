import 'package:sqflite/sqflite.dart';

import '../models/response/product_response_model.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();

  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProducts = 'products';

  static Database? _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableProducts (
      id INTEGER,
      name TEXT,
      description TEXT,
      price INTEGER,
      stock INTEGER,
      category TEXT,
      image TEXT,
      created_at TEXT,
      updated_at TEXT,
      is_best_seller INTEGER DEFAULT 0
    )
    ''');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // Versi sebelumnya tidak memiliki kolom isBestSeller, tambahkan kolom ini
      await db.execute('''
      ALTER TABLE $tableProducts
      ADD COLUMN is_sync INTEGER DEFAULT 0
    ''');
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos1.db');
    return _database!;
  }

  //REMOVE ALL DATA PRODUCT
  Future<void> removeAllProduct() async {
    final db = await instance.database;
    await db.delete(tableProducts);
  }

  //INSERT DATA PRODUCT FROM LIST
  Future<void> insertAllProduct(List<Product> products) async {
    final db = await instance.database;
    for (var product in products) {
      await db.insert(tableProducts, product.toMap());
    }
  }

  //get all data product
  Future<List<Product>> getAllProduct() async {
    final db = await instance.database;
    final result = await db.query(tableProducts);

    return result.map((e) => Product.fromMap(e)).toList();
  }
}
