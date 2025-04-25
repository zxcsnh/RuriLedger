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
      version: 1,
      onCreate: _onCreate,
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
}

Future<void> insertBill(Bill bill) async {
  final db = await DatabaseHelper().database;
  await db.insert('bills', bill.toInsertMap());
}

Future<List<Bill>> getBills() async {
  final db = await DatabaseHelper().database;
  final List<Map<String, Object?>> maps = await db.query('bills');
  return List<Bill>.from(maps.map((map) => Bill.fromMap(map)));
}

Future<List<Bill>> getDayBills(DateTime dateTime) async {
  final db = await DatabaseHelper().database;

  // 格式化日期为 'YYYY-MM-DD'
  final String formattedDate = dateTime.toIso8601String().split('T').first;

  // 查询指定日期的数据
  final List<Map<String, Object?>> maps = await db.query(
    'bills',
    where: "strftime('%Y-%m-%d', date) = ?",
    whereArgs: [formattedDate],
  );

  // 将查询结果转换为 Bill 对象列表
  return List<Bill>.from(maps.map((map) => Bill.fromMap(map)));
}

Future<List<BillSummary>> getMonthBills(DateTime dateTime) async {
  final db = await DatabaseHelper().database;

  // 格式化日期为 'YYYY-MM-DD'
  final String formattedDate = dateTime.year.toString();

  // 查询指定日期的数据
  final List<Map<String, Object?>> maps = await db.rawQuery('''
    SELECT 
      strftime('%m', date) AS month,  -- 按年月分组
      SUM(money) AS money,           -- 计算总金额
      type,
      usefor
    FROM bills
    WHERE strftime('%Y', date) = ?       -- 查询指定年份的数据
    GROUP BY month,type,usefor                       -- 按月份分组
    ORDER BY month ASC
  ''', [formattedDate]);

  // 将查询结果转换为 Bill 对象列表
  return List<BillSummary>.from(maps.map((map) => BillSummary.fromMap(map)));
}

Future<void> updateBill(int id, Bill bill) async {
  final db = await DatabaseHelper().database;
  await db.update(
    'bills',
    bill.toMap(),
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteBill(int id) async {
  final db = await DatabaseHelper().database;
  await db.delete(
    'bills',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteTable(String tableName) async {
  final db = await DatabaseHelper().database;
  await db.execute('DROP TABLE IF EXISTS $tableName');
  print('表 $tableName 已删除');
}
Future<void> createTable() async {
  final db = await DatabaseHelper().database;

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

  print('表已创建');
}