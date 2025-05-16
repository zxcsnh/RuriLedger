import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
    // 主账单表
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
    // 账单分类表
    await db.execute('''
      CREATE TABLE bill_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tablename TEXT,
        name TEXT,
        savetime TEXT,
        remark TEXT
      )
    ''');
    // 插入默认数据
    await db.insert('bill_categories', {'tablename': 'bills', 'name': '主账单', 'savetime': DateTime.now().toIso8601String(), 'remark': ''});
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

Future<List<Bill>> getMonthBills(DateTime dateTime, {String tableName = 'bills'}) async {
  final db = await DatabaseHelper().database;
  // 格式化日期为 "yyyy-MM"
  final String formattedDate = DateFormat('yyyy-MM').format(dateTime);
  final List<Map<String, Object?>> maps = await db.query(
    tableName,
    where: "strftime('%Y-%m', date) = ?",
    whereArgs: [formattedDate],
    orderBy: 'date DESC',
  );
  return List<Bill>.from(maps.map((map) => Bill.fromMap(map)));
}

Future<List<BillSummary>> getYearBills(DateTime dateTime, {String tableName = 'bills'}) async {
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
Future<void> updateTable(String tableName, String name, String remark) async {
  final db = await DatabaseHelper().database;
  await db.update(
    'bill_categories',
    {'tablename': tableName, 'name': name, 'savetime': DateTime.now().toIso8601String(), 'remark': remark},
    where: 'tablename = ?',
    whereArgs: [tableName],
  );
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

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    int sdkInt = (await Permission.storage.status).isGranted
        ? (await Permission.storage.status).hashCode
        : 0;

    if (sdkInt >= 30) {
      // Android 11 及以上
      var status = await Permission.manageExternalStorage.status;
      if (status.isGranted) {
        return true;
      } else {
        // 请求管理所有文件权限
        status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    } else {
      // Android 10 及以下
      var status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      } else {
        status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    }
  } else {
    // 非 Android 平台不处理
    return true;
  }
}


Future<void> exportDatabaseToCustomPath() async {
  try {
    // 检查存储权限
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      print("没有存储权限");
      return;
    }
    final dbFile = File(p.join(await getDatabasesPath(), 'my_db.db'));
    if (!await dbFile.exists()) {
      print("数据库文件不存在");
      return;
    }

    // 让用户选择一个目录
    String? selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir == null) {
      print("用户取消选择目录");
      return;
    }

    // 手动构造备份路径（包含文件名）
    final backupFileName = 'my_db_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';
    final backupPath = p.join(selectedDir, backupFileName);

    // 执行复制
    await dbFile.copy(backupPath);
    print("导出成功：$backupPath");
  } catch (e) {
    print('导出失败: $e');
  }
}



Future<void> importDatabase(String backupFilePath) async {
  try {
    final dbPath = await getDatabasesPath();
    final targetPath = p.join(dbPath, 'my_db.db');

    final backupFile = File(backupFilePath);
    if (await backupFile.exists()) {
      await backupFile.copy(targetPath);
      print('数据库已恢复');
    } else {
      print('备份文件不存在');
    }
  } catch (e) {
    print('导入失败: $e');
  }
}

Future<void> pickAndImportDatabase() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        await importDatabase(path);
      }
    } else {
      print('未选择文件');
    }
  } catch (e) {
    print('选择文件失败: $e');
  }
}
Future<void> exportDatabaseToExternalDir() async {
  final dbFile = File(p.join(await getDatabasesPath(), 'my_db.db'));
  if (!await dbFile.exists()) return;

  final externalDir = await getExternalStorageDirectory(); // App可访问的外部路径
  final fileName = 'my_db_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';
  final fullPath = p.join(externalDir!.path, fileName);

  await dbFile.copy(fullPath);
  print('数据库成功导出到：$fullPath');
}
