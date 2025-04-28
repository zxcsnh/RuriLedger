// 主入口文件 - 记账应用
import 'package:flutter/material.dart';
import 'package:myapp/src/utils/db.dart';
import 'package:myapp/src/utils/billListData.dart';
import 'package:myapp/src/app/app.dart';

void main() {
  // 确保Flutter引擎初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  DatabaseHelper().database.then((db) {
    print('Database initialized: $db');
  }).catchError((error) {
    print('Error initializing database: $error');
  });
  
  // 初始化数据映射（建议：添加注释说明generateMappings()的具体作用）
  generateMappings();
  
  runApp(const MyApp());
}