import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 获取数据库路径
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_db.db');

    // 打开或创建数据库
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // 新增：升级处理
    );
  }

  // 数据库创建时的回调
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        money REAL,
        date TEXT,
        savetime TEXT,
        usefor TEXT,
        source TEXT,
        remark TEXT
      )
    ''');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('''
      CREATE TABLE bill_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tablename TEXT,
        name TEXT,
        savetime TEXT,
        remark TEXT
      )
    ''');
    await db.insert('bill_categories', {'tablename': 'bills', 'name': '主账单', 'savetime': DateTime.now().toIso8601String(), 'remark': ''});
  }

}

Future<void> insertBill(Bill bill, {String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;
  await db.insert(tableName, bill.toInsertMap());
}

Future<List<Bill>> getBills({String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;
  final List<Map<String, Object?>> maps = await db.query(tableName);
  return List<Bill>.from(maps.map((map) => Bill.fromMap(map)));
}

Future<List<Bill>> getDayBills(DateTime dateTime, {String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;

  final String formattedDate = dateTime.toIso8601String().split('T').first;

  final List<Map<String, Object?>> maps = await db.query(
    tableName,
    where: "strftime('%Y-%m-%d', date) = ?",
    whereArgs: [formattedDate],
    orderBy: 'date DESC',
  );
  return List<Bill>.from(maps.map((map) => Bill.fromMap(map)));
}

Future<List<BillSummary>> getMonthBills(DateTime dateTime, {String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;

  final String formattedYear = dateTime.year.toString();

  final List<Map<String, Object?>> maps = await db.rawQuery('''
    SELECT 
      strftime('%m', date) AS month,
      SUM(money) AS money,
      type,
      usefor
    FROM $tableName
    WHERE strftime('%Y', date) = ?
    GROUP BY month, type, usefor
    ORDER BY month ASC
  ''', [formattedYear]);

  return List<BillSummary>.from(maps.map((map) => BillSummary.fromMap(map)));
}

Future<void> updateBill(int id, Bill bill, {String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;
  await db.update(
    tableName,
    bill.toMap(),
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteBill(int id, {String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;
  await db.delete(
    tableName,
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteTable(String tableName) async {
  final db = await DatabaseHelper().database;
  await db.execute('DROP TABLE IF EXISTS $tableName');
  await db.delete(
    'bill_categories',
    where: 'tablename = ?',
    whereArgs: [tableName],
  );
  print('表 $tableName 已删除');
}

Future<void> createTable(String tableName, String name, String remark) async {
  final db = await DatabaseHelper().database;
  String sql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        money REAL,
        date TEXT,
        savetime TEXT,
        usefor TEXT,
        source TEXT,
        remark TEXT
    )
  ''';
  await db.execute(sql);
  await db.insert('bill_categories', {'tablename': tableName, 'name': name, 'savetime': DateTime.now().toIso8601String(), 'remark': remark});
  print('表已创建');
}

Future<List<BillCategory>> getTableInfo() async {
  print("获取表数据");
  final db = await DatabaseHelper().database;
  final List<Map<String, Object?>> maps = await db.query("bill_categories");
  print(maps.length);
  return List<BillCategory>.from(maps.map((map) => BillCategory.fromMap(map)));
}

Future<List<double>> getSumBills({String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;

  final List<Map<String, Object?>> maps = await db.rawQuery('''
    SELECT 
      SUM(money) AS money,
      type
    FROM $tableName
    GROUP BY type
  ''');

  double pay = 0.0;
  double income = 0.0;

  for (final map in maps) {
    final type = map['type']?.toString();
    final money = (map['money'] as num?)?.toDouble() ?? 0.0;

    if (type == 'pay') {
      pay += money;
    } else {
      income += money;
    }
  }

  return [pay, income];
}
